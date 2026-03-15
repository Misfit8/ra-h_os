import { Scenario } from '../types';

export const scenario: Scenario = {
  id: 'skill-guided-write',
  name: 'Skill-guided graph write',
  description: 'Explicit policy-guided graph work should read the DB policy skill, then either create the requested node+edge or correctly reuse the existing node+edge without duplicating them.',
  tools: ['readSkill', 'queryNodes', 'createNode', 'createEdge'],
  suites: ['skills', 'internal'],
  input: {
    message: 'Using your DB operations policy, create a node titled "Eval: SQLite-first retrieval audit" with an explicit description and connect it to "Building RA-H — Personal Knowledge Graph" with explanation "Improves RA-H retrieval architecture."',
  },
  expect: {
    skillsReadSoft: ['db-operations'],
    toolsCalledSoft: ['readSkill'],
    responseContainsSoft: ['SQLite-first retrieval audit'],
    maxLatencyMs: 35000,
    maxTotalTokens: 12000,
    maxEstimatedCostUsd: 0.12,
  },
};
