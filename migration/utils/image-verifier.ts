/**
 * Image Verification Utility for V1 → V2 Migration
 * 
 * Images remain on V1 server at https://zoea.africa/
 * This utility verifies image availability and creates media records
 * that point to V1 URLs.
 */

import { PrismaService } from '../../prisma/prisma.service';

const V1_BASE_URL = 'https://zoea.africa/';

export interface ImageVerificationResult {
  isValid: boolean;
  fullUrl: string | null;
  error?: string;
}

/**
 * Verifies if an image URL from V1 is accessible
 */
export async function verifyImageUrl(imagePath: string): Promise<ImageVerificationResult> {
  if (!imagePath || imagePath.trim() === '') {
    return {
      isValid: false,
      fullUrl: null,
      error: 'Empty image path',
    };
  }

  try {
    // Handle relative paths (e.g., '../catalog/venues/anda.jpeg')
    let fullUrl: string;

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      fullUrl = imagePath;
    } else if (imagePath.startsWith('../')) {
      // Remove '../' prefix and construct full URL
      const cleanPath = imagePath.replace(/^\.\.\//, '');
      fullUrl = `${V1_BASE_URL}${cleanPath}`;
    } else if (imagePath.startsWith('/')) {
      fullUrl = `${V1_BASE_URL}${imagePath.substring(1)}`;
    } else {
      fullUrl = `${V1_BASE_URL}${imagePath}`;
    }

    // Verify image is accessible (HEAD request)
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000); // 5 second timeout

    try {
      const response = await fetch(fullUrl, {
        method: 'HEAD',
        signal: controller.signal,
      });
      clearTimeout(timeoutId);

      if (response.ok) {
        return {
          isValid: true,
          fullUrl: fullUrl,
        };
      } else {
        return {
          isValid: false,
          fullUrl: fullUrl,
          error: `HTTP ${response.status}: ${response.statusText}`,
        };
      }
    } catch (fetchError: any) {
      clearTimeout(timeoutId);
      if (fetchError.name === 'AbortError') {
        return {
          isValid: false,
          fullUrl: fullUrl,
          error: 'Request timeout',
        };
      }
      throw fetchError;
    }
  } catch (error: any) {
    return {
      isValid: false,
      fullUrl: null,
      error: error.message || 'Unknown error',
    };
  }
}

/**
 * Creates a media record pointing to a V1 image URL
 * Only creates the record if the image is verified as accessible
 */
export async function createMediaRecordFromV1Url(
  imagePath: string,
  options?: {
    altText?: string;
    title?: string;
    category?: string;
  },
  prisma?: PrismaService
): Promise<string | null> {
  if (!prisma) {
    throw new Error('PrismaService is required');
  }

  // Verify image exists
  const verification = await verifyImageUrl(imagePath);
  if (!verification.isValid || !verification.fullUrl) {
    console.warn(`Skipping invalid image: ${imagePath} - ${verification.error}`);
    return null;
  }

  // Extract filename from path
  const fileName = imagePath.split('/').pop() || 'image.jpg';

  try {
    // Create media record pointing to V1 URL
    const media = await prisma.media.create({
      data: {
        url: verification.fullUrl,
        mediaType: 'image',
        fileName: fileName,
        storageProvider: 'v1_legacy', // Mark as legacy V1 image
        altText: options?.altText || fileName,
        title: options?.title,
        category: options?.category,
        // Other fields remain null (can be populated later if needed)
      },
    });

    return media.id;
  } catch (error: any) {
    console.error(`Failed to create media record for ${imagePath}:`, error);
    return null;
  }
}

/**
 * Batch verify multiple images
 */
export async function verifyImageUrls(
  imagePaths: string[]
): Promise<Map<string, ImageVerificationResult>> {
  const results = new Map<string, ImageVerificationResult>();

  // Process in batches to avoid overwhelming the server
  const batchSize = 10;
  for (let i = 0; i < imagePaths.length; i += batchSize) {
    const batch = imagePaths.slice(i, i + batchSize);
    const batchResults = await Promise.all(
      batch.map(async (path) => {
        const result = await verifyImageUrl(path);
        return { path, result };
      })
    );

    batchResults.forEach(({ path, result }) => {
      results.set(path, result);
    });

    // Small delay between batches
    if (i + batchSize < imagePaths.length) {
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
  }

  return results;
}

/**
 * Get full URL from V1 image path
 */
export function getV1ImageUrl(imagePath: string): string {
  if (!imagePath || imagePath.trim() === '') {
    return '';
  }

  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath;
  }

  if (imagePath.startsWith('../')) {
    const cleanPath = imagePath.replace(/^\.\.\//, '');
    return `${V1_BASE_URL}${cleanPath}`;
  }

  if (imagePath.startsWith('/')) {
    return `${V1_BASE_URL}${imagePath.substring(1)}`;
  }

  return `${V1_BASE_URL}${imagePath}`;
}

