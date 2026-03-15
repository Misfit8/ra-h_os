import { NextRequest, NextResponse } from 'next/server';
import { getSQLiteClient } from '@/services/database/sqlite-client';

export const runtime = 'nodejs';

export async function GET() {
  try {
    return getPopularDimensionsSQLite();
  } catch (error) {
    console.error('Error fetching popular dimensions:', error);
    
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch popular dimensions'
    }, { status: 500 });
  }
}

// PostgreSQL path removed in SQLite-only consolidation

async function getPopularDimensionsSQLite() {
  const sqlite = getSQLiteClient();
  
  const result = sqlite.query(`
    WITH dimension_counts AS (
      SELECT nd.dimension, COUNT(*) AS count 
      FROM node_dimensions nd 
      GROUP BY nd.dimension
    ),
    all_dimensions AS (
      SELECT DISTINCT dimension AS name FROM node_dimensions
      UNION
      SELECT name FROM dimensions
    )
    SELECT ad.name AS dimension, 
           COALESCE(dc.count, 0) AS count, 
           dim.description
    FROM all_dimensions ad
    LEFT JOIN dimension_counts dc ON dc.dimension = ad.name
    LEFT JOIN dimensions dim ON dim.name = ad.name
    WHERE ad.name IS NOT NULL
    ORDER BY LOWER(ad.name) ASC
  `);

  return NextResponse.json({
    success: true,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    data: result.rows.map((row: any) => ({
      dimension: row.dimension,
      count: Number(row.count),
      isPriority: false,
      description: row.description || null
    }))
  });
}

export async function POST(request: NextRequest) {
  try {
    const { dimension } = await request.json();
    
    if (!dimension || typeof dimension !== 'string') {
      return NextResponse.json({ 
        success: false, 
        error: 'Dimension name is required' 
      }, { status: 400 });
    }

    return NextResponse.json({
      success: true,
      data: {
        dimension,
        is_priority: false
      },
      message: 'Priority dimensions are no longer part of the product model.'
    });
  } catch (error) {
    console.error('Error toggling dimension priority:', error);
    return NextResponse.json({ 
      success: false, 
      error: 'Internal server error' 
    }, { status: 500 });
  }
}
