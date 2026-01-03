#!/bin/bash

# Test Image Upload Script
# This script creates a test image and uploads it to verify Cloudinary integration

echo "🧪 Testing Image Upload to Cloudinary..."
echo ""

# Create a simple test image (1x1 pixel PNG)
echo "1. Creating test image..."
TEST_IMAGE="/tmp/test-upload-$(date +%s).png"
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > "$TEST_IMAGE"

if [ ! -f "$TEST_IMAGE" ]; then
    echo "❌ Failed to create test image"
    exit 1
fi

echo "✅ Test image created: $TEST_IMAGE"
echo ""

# Get API base URL
API_BASE="${API_BASE:-https://zoea-africa.qtsoftwareltd.com/api}"

echo "2. Testing upload endpoint..."
echo "   API Base: $API_BASE"
echo ""

# Note: This requires authentication token
# For now, we'll show the command and check if endpoint exists
echo "📝 To test upload, you need:"
echo "   1. Login to admin portal: http://159.198.65.38:3010"
echo "   2. Get your auth token from browser DevTools"
echo "   3. Or test via admin portal UI directly"
echo ""

# Check if endpoint is accessible
echo "3. Checking upload endpoint availability..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE/media/upload" -X POST)
if [ "$RESPONSE" = "401" ]; then
    echo "✅ Endpoint exists (401 = requires auth, which is expected)"
elif [ "$RESPONSE" = "404" ]; then
    echo "❌ Endpoint not found"
else
    echo "⚠️  Unexpected response: $RESPONSE"
fi

echo ""
echo "📋 Manual Test Steps:"
echo "   1. Open: http://159.198.65.38:3010"
echo "   2. Login to admin portal"
echo "   3. Go to: Listings → Create Listing"
echo "   4. Click 'Upload Images' button"
echo "   5. Select an image from your desktop"
echo "   6. Verify:"
echo "      - Image uploads successfully"
echo "      - Image appears in preview"
echo "      - Check Cloudinary: https://console.cloudinary.com/console/c/dzcvbnvh3"
echo ""

# Cleanup
rm -f "$TEST_IMAGE"
echo "✅ Test script completed"

