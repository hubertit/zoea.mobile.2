import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  Request,
  UseInterceptors,
  UploadedFile,
  UploadedFiles,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiConsumes,
  ApiBody,
  ApiQuery,
  ApiParam,
} from '@nestjs/swagger';
import { MediaService } from './media.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UploadMediaDto, UploadFromUrlDto, UpdateMediaDto, MediaCategory } from './dto/media.dto';

@ApiTags('Media')
@Controller('media')
export class MediaController {
  constructor(private readonly mediaService: MediaService) {}

  @Get('accounts')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get storage accounts status (admin)',
    description: 'Retrieves storage account statistics including used storage, available storage, file counts, and account status. Requires admin privileges. Useful for monitoring storage usage across Cloudinary accounts.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Storage account statistics retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          name: { type: 'string', example: 'zoea-production' },
          usedStorage: { type: 'number', example: 52428800, description: 'Used storage in bytes' },
          maxStorage: { type: 'number', example: 1073741824, description: 'Maximum storage in bytes' },
          availableStorage: { type: 'number', example: 1021313024, description: 'Available storage in bytes' },
          fileCount: { type: 'number', example: 1250, description: 'Total number of files' },
          isActive: { type: 'boolean', example: true }
        }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  async getAccountStats() {
    return this.mediaService.getAccountStats();
  }

  @Post('upload')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @UseInterceptors(FileInterceptor('file'))
  @ApiOperation({ 
    summary: 'Upload a single file',
    description: 'Uploads a single file (image, video, document, or audio) to cloud storage (Cloudinary). Supports images, videos, documents, and audio files. The file is automatically processed, optimized, and stored. Returns media metadata including URLs for accessing the file.'
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: { 
          type: 'string', 
          format: 'binary',
          description: 'File to upload (image, video, document, or audio). Maximum file size depends on storage provider limits.'
        },
        category: { 
          type: 'string', 
          enum: Object.values(MediaCategory),
          description: 'Media category for organization',
          example: 'listing',
          default: 'other'
        },
        altText: { 
          type: 'string',
          description: 'Alt text for accessibility (especially important for images)',
          example: 'Grand Hotel Kigali exterior view'
        },
        title: { 
          type: 'string',
          description: 'Optional title for the media',
          example: 'Hotel Main Entrance'
        },
        folder: { 
          type: 'string',
          description: 'Folder path in storage for organization (e.g., "listings/hotels")',
          example: 'listings/hotels'
        },
      },
      required: ['file'],
    },
  })
  @ApiResponse({ 
    status: 201, 
    description: 'File uploaded successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid', example: '123e4567-e89b-12d3-a456-426614174000' },
        url: { type: 'string', example: 'https://res.cloudinary.com/example/image/upload/v1234567890/image.jpg' },
        thumbnailUrl: { type: 'string', nullable: true, example: 'https://res.cloudinary.com/example/image/upload/c_thumb,w_200/v1234567890/image.jpg' },
        type: { type: 'string', enum: ['image', 'video', 'document', 'audio'], example: 'image' },
        category: { type: 'string', enum: Object.values(MediaCategory), example: 'listing' },
        altText: { type: 'string', nullable: true },
        title: { type: 'string', nullable: true },
        fileName: { type: 'string', example: 'hotel-image.jpg' },
        fileSize: { type: 'number', example: 245760, description: 'File size in bytes' },
        mimeType: { type: 'string', example: 'image/jpeg' },
        width: { type: 'number', nullable: true, example: 1920, description: 'Image/video width in pixels' },
        height: { type: 'number', nullable: true, example: 1080, description: 'Image/video height in pixels' },
        storageProvider: { type: 'string', example: 'cloudinary' },
        createdAt: { type: 'string', format: 'date-time' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid file type, file too large, or missing file' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 413, description: 'Payload Too Large - File exceeds maximum size limit' })
  async upload(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
    @Body() body: UploadMediaDto,
  ) {
    return this.mediaService.upload(file, req.user.id, {
      category: body.category,
      altText: body.altText,
      title: body.title,
      folder: body.folder,
    });
  }

  @Post('upload/multiple')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @UseInterceptors(FilesInterceptor('files', 10))
  @ApiOperation({ 
    summary: 'Upload multiple files (max 10)',
    description: 'Uploads up to 10 files in a single request. All files will be processed and stored with the same category and folder. Useful for bulk uploads like listing image galleries. Files are uploaded in parallel for better performance.'
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        files: { 
          type: 'array', 
          items: { type: 'string', format: 'binary' },
          description: 'Array of files to upload (maximum 10 files)',
          maxItems: 10
        },
        category: { 
          type: 'string', 
          enum: Object.values(MediaCategory),
          description: 'Media category applied to all files',
          example: 'listing',
          default: 'other'
        },
        folder: { 
          type: 'string',
          description: 'Folder path in storage for organization',
          example: 'listings/hotels'
        },
      },
      required: ['files'],
    },
  })
  @ApiResponse({ 
    status: 201, 
    description: 'Files uploaded successfully',
    schema: {
      type: 'object',
      properties: {
        uploaded: { type: 'number', example: 5, description: 'Number of files successfully uploaded' },
        files: { 
          type: 'array',
          items: { type: 'object' },
          description: 'Array of uploaded media objects with metadata'
        }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Too many files, invalid file types, or missing files' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 413, description: 'Payload Too Large - Total file size exceeds limit' })
  async uploadMultiple(
    @Request() req,
    @UploadedFiles() files: Express.Multer.File[],
    @Body() body: { category?: MediaCategory; folder?: string },
  ) {
    const results = await Promise.all(
      files.map(file =>
        this.mediaService.upload(file, req.user.id, {
          category: body.category,
          folder: body.folder,
        }),
      ),
    );
    return { uploaded: results.length, files: results };
  }

  @Post('upload/url')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Upload from external URL',
    description: 'Downloads a file from an external URL and uploads it to cloud storage. The file is fetched from the provided URL, processed, and stored. Useful for importing images from external sources or migrating media from other platforms.'
  })
  @ApiBody({ type: UploadFromUrlDto })
  @ApiResponse({ 
    status: 201, 
    description: 'File uploaded from URL successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid' },
        url: { type: 'string', example: 'https://res.cloudinary.com/example/image/upload/v1234567890/image.jpg' },
        type: { type: 'string', enum: ['image', 'video', 'document', 'audio'] },
        category: { type: 'string', enum: Object.values(MediaCategory) },
        fileName: { type: 'string' },
        fileSize: { type: 'number' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid URL, inaccessible URL, or unsupported file type' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'File not found at the provided URL' })
  async uploadFromUrl(@Request() req, @Body() body: UploadFromUrlDto) {
    return this.mediaService.uploadFromUrl(body.url, req.user.id, {
      category: body.category,
      altText: body.altText,
      title: body.title,
      folder: body.folder,
    });
  }

  @Get('my')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get my uploaded media',
    description: 'Retrieves paginated list of media files uploaded by the authenticated user. Supports filtering by media type and category. Useful for managing user\'s media library and selecting previously uploaded files.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'type', required: false, enum: ['image', 'video', 'document', 'audio'], description: 'Filter by media type', example: 'image' })
  @ApiQuery({ name: 'category', required: false, enum: Object.values(MediaCategory), description: 'Filter by media category', example: 'listing' })
  @ApiResponse({ 
    status: 200, 
    description: 'User media retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { 
          type: 'array',
          items: { type: 'object' }
        },
        total: { type: 'number', example: 50 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getMyMedia(
    @Request() req,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('type') type?: string,
    @Query('category') category?: string,
  ) {
    return this.mediaService.findByUser(req.user.id, {
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      type,
      category,
    });
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Get media by ID',
    description: 'Retrieves detailed information about a specific media file including URLs, metadata, dimensions, file size, and storage information. This endpoint is public and does not require authentication.'
  })
  @ApiParam({ name: 'id', type: String, format: 'uuid', description: 'Media UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Media retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid' },
        url: { type: 'string', example: 'https://res.cloudinary.com/example/image/upload/v1234567890/image.jpg' },
        thumbnailUrl: { type: 'string', nullable: true },
        type: { type: 'string', enum: ['image', 'video', 'document', 'audio'] },
        category: { type: 'string', enum: Object.values(MediaCategory) },
        altText: { type: 'string', nullable: true },
        title: { type: 'string', nullable: true },
        fileName: { type: 'string' },
        fileSize: { type: 'number' },
        mimeType: { type: 'string' },
        width: { type: 'number', nullable: true },
        height: { type: 'number', nullable: true },
        storageProvider: { type: 'string' },
        createdAt: { type: 'string', format: 'date-time' }
      }
    }
  })
  @ApiResponse({ status: 404, description: 'Media not found' })
  async findOne(@Param('id') id: string) {
    return this.mediaService.findOne(id);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update media metadata',
    description: 'Updates metadata for a media file (alt text, title, category). Only the media owner can update their media. The actual file cannot be changed; only metadata can be updated.'
  })
  @ApiParam({ name: 'id', type: String, format: 'uuid', description: 'Media UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateMediaDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Media metadata updated successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid' },
        altText: { type: 'string', nullable: true },
        title: { type: 'string', nullable: true },
        category: { type: 'string', enum: Object.values(MediaCategory) },
        updatedAt: { type: 'string', format: 'date-time' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to update this media' })
  @ApiResponse({ status: 404, description: 'Media not found' })
  async update(@Request() req, @Param('id') id: string, @Body() body: UpdateMediaDto) {
    return this.mediaService.update(id, req.user.id, body);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Delete media',
    description: 'Deletes a media file from cloud storage. Only the media owner can delete their media. The file is permanently removed from storage and cannot be recovered. This action cannot be undone.'
  })
  @ApiParam({ name: 'id', type: String, format: 'uuid', description: 'Media UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Media deleted successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Media deleted successfully' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to delete this media' })
  @ApiResponse({ status: 404, description: 'Media not found' })
  async delete(@Request() req, @Param('id') id: string) {
    return this.mediaService.delete(id, req.user.id);
  }
}

