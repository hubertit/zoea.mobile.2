import apiClient from './client';

export type MediaCategory = 'listing' | 'event' | 'tour' | 'user' | 'merchant' | 'other';
export type MediaType = 'image' | 'video' | 'document' | 'audio';

export interface Media {
  id: string;
  url: string;
  thumbnailUrl?: string | null;
  type: MediaType;
  category?: string | null;
  altText?: string | null;
  title?: string | null;
  fileName: string;
  fileSize: number;
  mimeType: string;
  width?: number | null;
  height?: number | null;
  storageProvider: string;
  uploadedBy: string;
  createdAt: string;
  updatedAt: string;
}

export interface UploadMediaParams {
  file: File;
  category?: MediaCategory;
  altText?: string;
  title?: string;
  folder?: string;
}

export interface MediaAccount {
  name: string;
  usedStorage: number;
  maxStorage: number;
  availableStorage: number;
  fileCount: number;
  isActive: boolean;
}

export const MediaAPI = {
  /**
   * Upload a single file
   */
  upload: async (params: UploadMediaParams): Promise<Media> => {
    const formData = new FormData();
    formData.append('file', params.file);
    if (params.category) formData.append('category', params.category);
    if (params.altText) formData.append('altText', params.altText);
    if (params.title) formData.append('title', params.title);
    if (params.folder) formData.append('folder', params.folder);

    const response = await apiClient.post<Media>('/media/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  /**
   * Get storage account statistics
   */
  getAccountStats: async (): Promise<MediaAccount[]> => {
    const response = await apiClient.get<MediaAccount[]>('/media/accounts');
    return response.data;
  },
};

