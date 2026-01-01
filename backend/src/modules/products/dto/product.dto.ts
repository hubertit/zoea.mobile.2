import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsUUID, IsBoolean, IsArray, IsEnum, IsObject, Min, Max } from 'class-validator';
import { Transform } from 'class-transformer';

export enum ProductStatus {
  DRAFT = 'draft',
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  OUT_OF_STOCK = 'out_of_stock',
}

export class CreateProductDto {
  @ApiProperty({ description: 'Listing ID that owns this product' })
  @IsUUID()
  listingId: string;

  @ApiProperty({ example: 'Handmade Leather Bag' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'handmade-leather-bag' })
  @IsString()
  @IsOptional()
  slug?: string;

  @ApiPropertyOptional({ example: 'Beautiful handmade leather bag with intricate designs' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: 'Handmade leather bag', maxLength: 500 })
  @IsString()
  @IsOptional()
  shortDescription?: string;

  @ApiProperty({ example: 50000, description: 'Base price in smallest currency unit' })
  @IsNumber()
  @Min(0)
  basePrice: number;

  @ApiPropertyOptional({ example: 60000, description: 'Compare at price (for showing discounts)' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  compareAtPrice?: number;

  @ApiPropertyOptional({ example: 'RWF', default: 'RWF' })
  @IsString()
  @IsOptional()
  currency?: string;

  @ApiPropertyOptional({ example: 30000, description: 'Cost price for profit calculation' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  costPrice?: number;

  @ApiPropertyOptional({ example: 'BAG-001', description: 'Stock Keeping Unit' })
  @IsString()
  @IsOptional()
  sku?: string;

  @ApiPropertyOptional({ example: true, default: true })
  @IsBoolean()
  @IsOptional()
  trackInventory?: boolean;

  @ApiPropertyOptional({ example: 10, default: 0 })
  @IsNumber()
  @IsOptional()
  @Min(0)
  inventoryQuantity?: number;

  @ApiPropertyOptional({ example: 5, default: 5 })
  @IsNumber()
  @IsOptional()
  @Min(0)
  lowStockThreshold?: number;

  @ApiPropertyOptional({ example: false, default: false })
  @IsBoolean()
  @IsOptional()
  allowBackorders?: boolean;

  @ApiPropertyOptional({ example: 0.5, description: 'Weight in kg' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  weight?: number;

  @ApiPropertyOptional({ example: { length: 30, width: 20, height: 15, unit: 'cm' }, description: 'Product dimensions' })
  @IsObject()
  @IsOptional()
  dimensions?: any;

  @ApiPropertyOptional({ example: 'apparel', description: 'Product category' })
  @IsString()
  @IsOptional()
  category?: string;

  @ApiPropertyOptional({ example: ['handmade', 'leather', 'bag'], description: 'Product tags' })
  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({ example: false, default: false })
  @IsBoolean()
  @IsOptional()
  hasVariants?: boolean;

  @ApiPropertyOptional({ 
    example: { size: ['S', 'M', 'L'], color: ['Red', 'Blue'] }, 
    description: 'Variant options configuration' 
  })
  @IsObject()
  @IsOptional()
  variantOptions?: any;

  @ApiPropertyOptional({ example: 'draft', enum: ProductStatus, default: 'draft' })
  @IsEnum(ProductStatus)
  @IsOptional()
  status?: ProductStatus;

  @ApiPropertyOptional({ example: false, default: false })
  @IsBoolean()
  @IsOptional()
  isFeatured?: boolean;

  @ApiPropertyOptional({ example: ['uuid1', 'uuid2'], description: 'Array of media IDs for product images' })
  @IsArray()
  @IsOptional()
  @IsUUID(undefined, { each: true })
  images?: string[];
}

export class UpdateProductDto {
  @ApiProperty({ description: 'Listing ID for authorization' })
  @IsUUID()
  listingId: string;

  @ApiPropertyOptional({ example: 'Updated Product Name' })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  slug?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  shortDescription?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  basePrice?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  compareAtPrice?: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  currency?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  costPrice?: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  sku?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  trackInventory?: boolean;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  inventoryQuantity?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  lowStockThreshold?: number;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  allowBackorders?: boolean;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  weight?: number;

  @ApiPropertyOptional()
  @IsObject()
  @IsOptional()
  dimensions?: any;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  category?: string;

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  hasVariants?: boolean;

  @ApiPropertyOptional()
  @IsObject()
  @IsOptional()
  variantOptions?: any;

  @ApiPropertyOptional({ enum: ProductStatus })
  @IsEnum(ProductStatus)
  @IsOptional()
  status?: ProductStatus;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isFeatured?: boolean;

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  @IsUUID(undefined, { each: true })
  images?: string[];
}

export class ProductQueryDto {
  @ApiPropertyOptional({ example: 1, default: 1 })
  @Transform(({ value }) => parseInt(value))
  @IsNumber()
  @IsOptional()
  page?: number;

  @ApiPropertyOptional({ example: 20, default: 20 })
  @Transform(({ value }) => parseInt(value))
  @IsNumber()
  @IsOptional()
  limit?: number;

  @ApiPropertyOptional({ description: 'Filter by listing ID' })
  @IsUUID()
  @IsOptional()
  listingId?: string;

  @ApiPropertyOptional({ enum: ProductStatus, description: 'Filter by status' })
  @IsEnum(ProductStatus)
  @IsOptional()
  status?: ProductStatus;

  @ApiPropertyOptional({ example: 'bag', description: 'Search in name and description' })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({ example: 'apparel', description: 'Filter by category' })
  @IsString()
  @IsOptional()
  category?: string;

  @ApiPropertyOptional({ example: 10000, description: 'Minimum price' })
  @Transform(({ value }) => parseFloat(value))
  @IsNumber()
  @IsOptional()
  minPrice?: number;

  @ApiPropertyOptional({ example: 100000, description: 'Maximum price' })
  @Transform(({ value }) => parseFloat(value))
  @IsNumber()
  @IsOptional()
  maxPrice?: number;

  @ApiPropertyOptional({ example: true, description: 'Filter featured products only' })
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  @IsOptional()
  isFeatured?: boolean;

  @ApiPropertyOptional({ 
    example: 'popular', 
    enum: ['popular', 'name_asc', 'name_desc', 'price_asc', 'price_desc', 'createdAt_desc', 'createdAt_asc'],
    description: 'Sort order'
  })
  @IsString()
  @IsOptional()
  sortBy?: string;
}

export class CreateProductVariantDto {
  @ApiProperty({ example: 'M - Red' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'BAG-001-M-RED' })
  @IsString()
  @IsOptional()
  sku?: string;

  @ApiPropertyOptional({ example: 50000, description: 'Override product base price if set' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  price?: number;

  @ApiPropertyOptional({ example: 60000 })
  @IsNumber()
  @IsOptional()
  @Min(0)
  compareAtPrice?: number;

  @ApiProperty({ example: { size: 'M', color: 'Red' }, description: 'Variant attributes' })
  @IsObject()
  attributes: any;

  @ApiPropertyOptional({ example: 10, default: 0 })
  @IsNumber()
  @IsOptional()
  @Min(0)
  inventoryQuantity?: number;

  @ApiPropertyOptional({ example: true, default: true })
  @IsBoolean()
  @IsOptional()
  trackInventory?: boolean;

  @ApiPropertyOptional({ description: 'Variant-specific image ID' })
  @IsUUID()
  @IsOptional()
  imageId?: string;

  @ApiPropertyOptional({ example: true, default: true })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}

export class UpdateProductVariantDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  sku?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  price?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  compareAtPrice?: number;

  @ApiPropertyOptional()
  @IsObject()
  @IsOptional()
  attributes?: any;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  inventoryQuantity?: number;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  trackInventory?: boolean;

  @ApiPropertyOptional()
  @IsUUID()
  @IsOptional()
  imageId?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}

