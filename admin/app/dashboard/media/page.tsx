'use client';

import { useState } from 'react';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import { Button } from '@/app/components';
import Icon, { faImage, faUpload, faTrash, faDownload, faFileAlt, faTimes } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';

export default function MediaPage() {
  const [uploading, setUploading] = useState(false);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      // Validate file type
      const validTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml'];
      if (!validTypes.includes(file.type)) {
        toast.error('Please select a valid image file (JPEG, PNG, GIF, WebP, or SVG)');
        return;
      }
      // Validate file size (max 10MB)
      if (file.size > 10 * 1024 * 1024) {
        toast.error('File size must be less than 10MB');
        return;
      }
      setSelectedFile(file);
    }
  };

  const handleUpload = async () => {
    if (!selectedFile) {
      toast.error('Please select a file to upload');
      return;
    }

    setUploading(true);
    try {
      // TODO: Implement actual upload API call
      // const formData = new FormData();
      // formData.append('file', selectedFile);
      // await apiClient.post('/admin/media/upload', formData, {
      //   headers: { 'Content-Type': 'multipart/form-data' },
      // });

      // Simulate upload
      await new Promise((resolve) => setTimeout(resolve, 1000));
      
      toast.success('File uploaded successfully');
      setSelectedFile(null);
      // Reset file input
      const fileInput = document.getElementById('file-input') as HTMLInputElement;
      if (fileInput) fileInput.value = '';
    } catch (error: any) {
      console.error('Upload failed:', error);
      toast.error(error?.message || 'Failed to upload file');
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Media Library</h1>
          <p className="text-gray-600 mt-1">Manage media files and uploads</p>
        </div>
      </div>

      {/* Upload Section */}
      <Card>
        <CardHeader>
          <div className="flex items-center gap-2">
            <Icon icon={faUpload} className="text-[#0e1a30]" size="sm" />
            <h2 className="text-lg font-semibold text-gray-900">Upload Media</h2>
          </div>
        </CardHeader>
        <CardBody>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Select File
              </label>
              <div className="flex items-center gap-4">
                <input
                  id="file-input"
                  type="file"
                  accept="image/*"
                  onChange={handleFileSelect}
                  className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-sm file:border-0 file:text-sm file:font-medium file:bg-[#0e1a30] file:text-white hover:file:bg-[#0e1a30]/90"
                />
              </div>
              {selectedFile && (
                <div className="mt-3 p-3 bg-gray-50 rounded-sm">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Icon icon={faFileAlt} className="text-gray-600" size="sm" />
                      <span className="text-sm text-gray-900">{selectedFile.name}</span>
                      <span className="text-xs text-gray-500">
                        ({(selectedFile.size / 1024 / 1024).toFixed(2)} MB)
                      </span>
                    </div>
                    <Button
                      onClick={() => {
                        setSelectedFile(null);
                        const fileInput = document.getElementById('file-input') as HTMLInputElement;
                        if (fileInput) fileInput.value = '';
                      }}
                      variant="ghost"
                      size="sm"
                    >
                      <Icon icon={faTimes} size="xs" />
                    </Button>
                  </div>
                </div>
              )}
            </div>
            <div className="flex items-center gap-2">
              <Button
                onClick={handleUpload}
                disabled={!selectedFile || uploading}
                className="flex items-center gap-2"
              >
                <Icon icon={faUpload} size="sm" />
                {uploading ? 'Uploading...' : 'Upload'}
              </Button>
            </div>
            <p className="text-xs text-gray-500">
              Supported formats: JPEG, PNG, GIF, WebP, SVG. Maximum file size: 10MB
            </p>
          </div>
        </CardBody>
      </Card>

      {/* Media Library Info */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Media Library</h2>
        </CardHeader>
        <CardBody>
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Icon icon={faImage} className="text-gray-400" size="2x" />
            </div>
            <p className="text-gray-600 mb-2">Media library management coming soon</p>
            <p className="text-sm text-gray-500">
              This feature will allow you to browse, search, and manage all uploaded media files.
            </p>
          </div>
        </CardBody>
      </Card>
    </div>
  );
}
