import { NextResponse, NextRequest } from 'next/server';
import { Merchant } from '@/types';
import { mockMerchants } from '@/lib/mockMerchants';

// GET all merchants (using dummy data)
export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const status = searchParams.get('status');
    const type = searchParams.get('type');
    const limit = parseInt(searchParams.get('limit') || '100');

    let filteredMerchants = [...mockMerchants];

    // Filter by status
    if (status && status !== 'all') {
      filteredMerchants = filteredMerchants.filter(m => m.status === status);
    }

    // Filter by type (check if type is in merchant_types array)
    if (type && type !== 'all') {
      filteredMerchants = filteredMerchants.filter(m => 
        m.merchant_types.includes(type as any)
      );
    }

    // Apply limit
    filteredMerchants = filteredMerchants.slice(0, limit);

    return NextResponse.json(filteredMerchants);
  } catch (error) {
    console.error('Error fetching merchants:', error);
    return NextResponse.json(
      { error: 'Failed to fetch merchants' },
      { status: 500 }
    );
  }
}

// POST create new merchant (using dummy data - simulated)
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const {
      merchant_name,
      merchant_types,
      business_email,
      business_phone,
      business_address,
      business_description,
      tax_id,
      license_number,
      status = 'pending'
    } = body;

    // Validate required fields
    if (!merchant_name || !merchant_types || !business_email || !business_phone || !business_address) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    // Simulate creating a merchant (in real app, this would save to database)
    const newMerchantId = mockMerchants.length + 1;

    // Simulate delay
    await new Promise(resolve => setTimeout(resolve, 500));

    return NextResponse.json(
      { 
        message: 'Merchant created successfully (dummy data)',
        merchant_id: newMerchantId
      },
      { status: 201 }
    );
  } catch (error) {
    console.error('Error creating merchant:', error);
    return NextResponse.json(
      { error: 'Failed to create merchant' },
      { status: 500 }
    );
  }
}

// PUT update merchant (using dummy data - simulated)
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json();
    const { merchant_id } = body;

    if (!merchant_id) {
      return NextResponse.json(
        { error: 'Merchant ID is required' },
        { status: 400 }
      );
    }

    // Simulate delay
    await new Promise(resolve => setTimeout(resolve, 500));

    return NextResponse.json({ 
      message: 'Merchant updated successfully (dummy data)' 
    });
  } catch (error) {
    console.error('Error updating merchant:', error);
    return NextResponse.json(
      { error: 'Failed to update merchant' },
      { status: 500 }
    );
  }
}

// DELETE merchant (using dummy data - simulated)
export async function DELETE(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const merchant_id = searchParams.get('merchant_id');

    if (!merchant_id) {
      return NextResponse.json(
        { error: 'Merchant ID is required' },
        { status: 400 }
      );
    }

    // Simulate delay
    await new Promise(resolve => setTimeout(resolve, 500));

    return NextResponse.json({ 
      message: 'Merchant deleted successfully (dummy data)' 
    });
  } catch (error) {
    console.error('Error deleting merchant:', error);
    return NextResponse.json(
      { error: 'Failed to delete merchant' },
      { status: 500 }
    );
  }
}

