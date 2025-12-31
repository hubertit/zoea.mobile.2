'use client';

import { useState, useEffect } from 'react';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import { Button, Input, Select } from '@/app/components';
import Icon, { faImage, faUpload, faTrash, faDownload, faFileAlt, faTimes, faSearch } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { MediaAPI, type Media, type MediaCategory } from '@/src/lib/api';
import PageSkeleton from '@/app/components/PageSkeleton';

export default function MediaPage() {
  const [uploading, setUploading] = useState(false);
  const [loading, setLoading] = useState(false);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [mediaFiles, setMediaFiles] = useState<Media[]>([]);
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState<MediaCategory | ''>('');
  const [uploadCategory, setUploadCategory] = useState<MediaCategory>('other');
  const [altText, setAltText] = useState('');
  const [title, setTitle] = useState('');

  useEffect(() => {
    // Note: There's no list media endpoint yet, so we'll show upload functionality only
    // When the endpoint is available, we can fetch and display media files here
  }, [search, category]);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      // Validate file type - allow images, videos, documents, audio
      const validTypes = [
        'image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml',
        'video/mp4', 'video/quicktime', 'video/x-msvideo',
        'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'audio/mpeg', 'audio/wav', 'audio/ogg'
      ];
      if (!validTypes.includes(file.type)) {
        toast.error('Please select a valid file (image, video, document, or audio)');
        return;
      }
      // Validate file size (max 50MB)
      if (file.size > 50 * 1024 * 1024) {
        toast.error('File size must be less than 50MB');
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
      const uploadedMedia = await MediaAPI.upload({
        file: selectedFile,
        category: uploadCategory,
        altText: altText || undefined,
        title: title || undefined,
      });
      
      toast.success('File uploaded successfully');
      setSelectedFile(null);
      setAltText('');
      setTitle('');
      // Reset file input
      const fileInput = document.getElementById('file-input') as HTMLInputElement;
      if (fileInput) fileInput.value = '';
      
      // Refresh media list if we have it
      // setMediaFiles([uploadedMedia, ...mediaFiles]);
    } catch (error: any) {
      console.error('Upload failed:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to upload file');
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
                Select File <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-4">
                <input
                  id="file-input"
                  type="file"
                  accept="image/*,video/*,application/pdf,application/msword,audio/*"
                  onChange={handleFileSelect}
                  className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-sm file:border-0 file:text-sm file:font-medium file:bg-[#0e1a30] file:text-white hover:file:bg-[#0e1a30]/90"
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">Supported: Images, Videos, Documents, Audio (max 50MB)</p>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Category
                </label>
                <Select
                  value={uploadCategory}
                  onChange={(e) => setUploadCategory(e.target.value as MediaCategory)}
                  options={[
                    { value: 'listing', label: 'Listing' },
                    { value: 'event', label: 'Event' },
                    { value: 'tour', label: 'Tour' },
                    { value: 'user', label: 'User' },
                    { value: 'merchant', label: 'Merchant' },
                    { value: 'other', label: 'Other' },
                  ]}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Title (Optional)
                </label>
                <Input
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="Enter title"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Alt Text (Optional)
              </label>
              <Input
                value={altText}
                onChange={(e) => setAltText(e.target.value)}
                placeholder="Enter alt text for accessibility"
              />
            </div>

            {selectedFile && (
              <div className="p-3 bg-gray-50 rounded-sm">
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

            <div className="flex items-center gap-2 pt-2">
              <Button
                onClick={handleUpload}
                disabled={!selectedFile || uploading}
                loading={uploading}
                icon={faUpload}
              >
                Upload
              </Button>
            </div>
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
