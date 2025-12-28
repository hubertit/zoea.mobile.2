import { NextResponse, NextRequest } from 'next/server';
import { getListingsByMerchantId } from '@/lib/mockMerchants';

// GET all listings for a merchant (using dummy data)
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const merchant_id = parseInt(id);
    const searchParams = request.nextUrl.searchParams;
    const listing_type = searchParams.get('type');
    const status = searchParams.get('status');

    let listings = getListingsByMerchantId(merchant_id);

    // Filter by listing type
    if (listing_type && listing_type !== 'all') {
      listings = listings.filter(l => l.listing_type === listing_type);
    }

    // Filter by status
    if (status && status !== 'all') {
      listings = listings.filter(l => l.status === status);
    }

    return NextResponse.json(listings);
  } catch (error) {
    console.error('Error fetching merchant listings:', error);
    return NextResponse.json(
      { error: 'Failed to fetch listings' },
      { status: 500 }
    );
  }
}

// POST create new listing for a merchant (using dummy data - simulated)
export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const body = await request.json();
    const {
      listing_type,
      listing_name,
      description,
      price
    } = body;

    // Validate required fields
    if (!listing_type || !listing_name || !description || price === undefined) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    // Simulate delay
    await new Promise(resolve => setTimeout(resolve, 500));

    return NextResponse.json(
      { 
        message: 'Listing created successfully (dummy data)',
        listing_id: Math.floor(Math.random() * 1000) + 100
      },
      { status: 201 }
    );
  } catch (error) {
    console.error('Error creating listing:', error);
    return NextResponse.json(
      { error: 'Failed to create listing' },
      { status: 500 }
    );
  }
}

