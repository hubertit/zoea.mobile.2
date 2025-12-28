import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsEnum, IsUUID } from 'class-validator';

export enum MediaType {
  IMAGE = 'image',
  VIDEO = 'video',
  DOCUMENT = 'document',
  AUDIO = 'audio',
}

export enum MediaCategory {
  PROFILE = 'profile',
  LISTING = 'listing',
  EVENT = 'event',
  TOUR = 'tour',
  REVIEW = 'review',
  BUSINESS = 'business',
  OTHER = 'other',
}

export class UploadMediaDto {
  @ApiProperty({ type: 'string', format: 'binary', description: 'File to upload' })
  file: Express.Multer.File;

  @ApiPropertyOptional({ enum: MediaCategory, default: MediaCategory.OTHER })
  @IsEnum(MediaCategory) @IsOptional()
  category?: MediaCategory;

  @ApiPropertyOptional({ description: 'Alt text for accessibility' })
  @IsString() @IsOptional()
  altText?: string;

  @ApiPropertyOptional({ description: 'Optional title' })
  @IsString() @IsOptional()
  title?: string;

  @ApiPropertyOptional({ description: 'Folder path in storage' })
  @IsString() @IsOptional()
  folder?: string;
}

export class UploadFromUrlDto {
  @ApiProperty({ example: 'https://example.com/image.jpg' })
  @IsString()
  url: string;

  @ApiPropertyOptional({ enum: MediaCategory, default: MediaCategory.OTHER })
  @IsEnum(MediaCategory) @IsOptional()
  category?: MediaCategory;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  altText?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  title?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  folder?: string;
}

export class UpdateMediaDto {
  @ApiPropertyOptional()
  @IsString() @IsOptional()
  altText?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  title?: string;

  @ApiPropertyOptional({ enum: MediaCategory })
  @IsEnum(MediaCategory) @IsOptional()
  category?: MediaCategory;
}

export class MediaResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  url: string;

  @ApiPropertyOptional()
  thumbnailUrl?: string;

  @ApiProperty({ enum: MediaType })
  type: MediaType;

  @ApiPropertyOptional({ enum: MediaCategory })
  category?: MediaCategory;

  @ApiPropertyOptional()
  altText?: string;

  @ApiPropertyOptional()
  title?: string;

  @ApiProperty()
  fileName: string;

  @ApiProperty()
  fileSize: number;

  @ApiPropertyOptional()
  mimeType?: string;

  @ApiPropertyOptional()
  width?: number;

  @ApiPropertyOptional()
  height?: number;

  @ApiProperty()
  storageProvider: string;

  @ApiProperty()
  createdAt: Date;
}

export class CloudinaryAccountDto {
  @ApiProperty()
  name: string;

  @ApiProperty()
  usedStorage: number;

  @ApiProperty()
  maxStorage: number;

  @ApiProperty()
  availableStorage: number;

  @ApiProperty()
  fileCount: number;

  @ApiProperty()
  isActive: boolean;
}

