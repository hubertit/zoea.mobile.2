# Test Image Upload - Browser Method

## Quick Test Steps:

1. **Open Admin Portal**
   - URL: http://159.198.65.38:3010
   - Login with your admin credentials

2. **Navigate to Listings**
   - Click "Listings" in the sidebar
   - Click "Create Listing" button

3. **Upload Image**
   - Scroll to the "Images" section
   - Click "Upload Images (max 10MB, auto-compressed to <1MB)"
   - Select an image from your desktop
   - Wait for upload to complete
   - You should see:
     - ✅ Success message: "X image(s) uploaded and compressed successfully"
     - Image preview appears
     - Image URL visible

4. **Verify in Cloudinary**
   - Go to: https://console.cloudinary.com/console/c/dzcvbnvh3
   - Login to Cloudinary dashboard
   - Check "Media Library" → "zoea/listing" folder
   - Your uploaded image should appear there

5. **Check Backend Logs** (optional)
   ```bash
   ssh qt@172.16.40.61
   cd ~/zoea-backend
   docker-compose logs -f api | grep -i "cloudinary\|upload\|media"
   ```

## Expected Behavior:

- ✅ Image uploads successfully
- ✅ Image is compressed to <1MB (if original >1MB)
- ✅ Image appears in Cloudinary dashboard
- ✅ Image preview shows in admin portal
- ✅ No errors in browser console

## Troubleshooting:

If upload fails:
1. Check browser console for errors
2. Check network tab for API response
3. Verify Cloudinary integration is active in database
4. Check backend logs for errors

