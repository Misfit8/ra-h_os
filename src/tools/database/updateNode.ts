import { tool } from 'ai';
import { z } from 'zod';
import { getInternalApiBaseUrl } from '@/services/runtime/apiBase';
import { normalizeDimensions, validateExplicitDescription } from '@/services/database/quality';

export const updateNodeTool = tool({
  description: 'Update node fields. Description is REQUIRED on every update and must explicitly state WHAT this is + WHY it matters.',
  inputSchema: z.object({
    id: z.number().describe('The ID of the node to update'),
    updates: z.object({
      title: z.string().optional().describe('New title'),
      notes: z.string().optional().describe('User notes/analysis to append. USE THIS for workflow outputs, briefs, research notes, etc.'),
      description: z.string().max(280).describe('REQUIRED on every update. Explicitly state WHAT this is + WHY it matters. No "discusses/explores".'),
      link: z.string().optional().describe('New link'),
      event_date: z.string().optional().describe('When the thing actually happened (ISO 8601). Not when it was added to the graph.'),
      dimensions: z.array(z.string()).optional().describe('New dimension tags - completely replaces existing dimensions'),
      chunk: z.string().optional().describe('DO NOT USE - raw source text that triggers re-embedding. Only for source corrections.'),
      metadata: z.record(z.any()).optional().describe('New metadata - completely replaces existing metadata')
    }).describe('Object containing the fields to update. For adding notes/analysis, always use "notes" field.')
  }),
  execute: async ({ id, updates }) => {
    try {
      if (!updates || Object.keys(updates).length === 0) {
        return {
          success: false,
          error: 'updateNode requires at least one field in the updates object.',
          data: null
        };
      }

      if (!updates.description) {
        return {
          success: false,
          error: 'Every node update requires an explicit description (WHAT this is + WHY it matters).',
          data: null
        };
      }
      const descriptionError = validateExplicitDescription(updates.description);
      if (descriptionError) {
        return {
          success: false,
          error: descriptionError,
          data: null
        };
      }

      // FORCE APPEND for notes field - fetch existing and append new notes
      if (updates.notes) {
        const fetchResponse = await fetch(`${getInternalApiBaseUrl()}/api/nodes/${id}`);
        if (fetchResponse.ok) {
          const { node } = await fetchResponse.json();
          const existingNotes = (node?.notes || '').trim();
          const newNotes = updates.notes.trim();

          // Skip if new notes are identical to existing (model sent duplicate)
          if (existingNotes === newNotes) {
            console.log(`[updateNode] ERROR - new notes identical to existing (${existingNotes.length} chars). Model should NOT call updateNode again.`);
            return {
              success: false,
              error: 'Notes already up to date - do not call updateNode again. Move to next step.',
              data: null
            };
          }

          // Detect if adding a section that already exists (e.g., ## Integration Analysis)
          const newSectionMatch = newNotes.match(/^##\s+(.+)$/m);
          if (newSectionMatch && existingNotes) {
            const sectionHeader = newSectionMatch[0]; // e.g., "## Integration Analysis"
            if (existingNotes.includes(sectionHeader)) {
              console.log(`[updateNode] ERROR - Section "${sectionHeader}" already exists in node`);
              return {
                success: false,
                error: `Section "${sectionHeader}" already exists in this node. Cannot append duplicate section.`,
                data: null
              };
            }
          }

          // Detect if model included existing notes + new notes
          if (existingNotes && newNotes.startsWith(existingNotes)) {
            // Extract only the new part
            const actualNewNotes = newNotes.substring(existingNotes.length).trim();
            console.log(`[updateNode] Model included existing notes - extracting new part only (${actualNewNotes.length} chars)`);
            const separator = existingNotes.endsWith('\n\n') ? '' : '\n\n';
            updates.notes = `${existingNotes}${separator}${actualNewNotes}`;
          } else if (existingNotes) {
            // Normal append
            const separator = existingNotes.endsWith('\n\n') ? '' : '\n\n';
            updates.notes = `${existingNotes}${separator}${newNotes}`;
            console.log(`[updateNode] Appended notes: ${existingNotes.length} + ${newNotes.length} = ${updates.notes.length} chars`);
          } else {
            console.log(`[updateNode] No existing notes, using new notes as-is (${newNotes.length} chars)`);
          }
        }
      }

      if (Array.isArray(updates.dimensions)) {
        updates.dimensions = normalizeDimensions(updates.dimensions, 5);
      }

      // Call the nodes API endpoint
      const response = await fetch(`${getInternalApiBaseUrl()}/api/nodes/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates)
      });

      const result = await response.json();
      
      if (!response.ok) {
        return {
          success: false,
          error: result.error || 'Failed to update node',
          data: null
        };
      }

      return {
        success: true,
        data: result.node,
        message: `Updated node ID ${id}${updates.dimensions ? ` with dimensions: ${updates.dimensions.join(', ')}` : ''}`
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Failed to update node',
        data: null
        };
    }
  }
});

// Legacy export for backwards compatibility
export const updateItemTool = updateNodeTool;
