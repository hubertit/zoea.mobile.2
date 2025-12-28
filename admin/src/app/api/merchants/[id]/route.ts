import { NextResponse, NextRequest } from 'next/server';
import { getMerchantById } from '@/lib/mockMerchants';

// GET single merchant by ID (using dummy data)
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const merchant_id = parseInt(id);
    const merchant = getMerchantById(merchant_id);

    if (!merchant) {
      return NextResponse.json(
        { error: 'Merchant not found' },
        { status: 404 }
      );
    }

    return NextResponse.json(merchant);
  } catch (error) {
    console.error('Error fetching merchant:', error);
    return NextResponse.json(
      { error: 'Failed to fetch merchant' },
      { status: 500 }
    );
  }
}

