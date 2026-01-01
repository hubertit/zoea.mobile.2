import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsUUID, IsBoolean, IsArray, IsEnum, IsObject, Min, Max } from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateMenuDto {
  @ApiProperty({ description: 'Listing ID (restaurant) that owns this menu' })
  @IsUUID()
  listingId: string;

  @ApiProperty({ example: 'Lunch Menu' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'Our delicious lunch offerings' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ 
    example: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
    description: 'Days when this menu is available'
  })
  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  availableDays?: string[];

  @ApiPropertyOptional({ example: '11:00', description: 'Start time (HH:mm)' })
  @IsString()
  @IsOptional()
  startTime?: string;

  @ApiPropertyOptional({ example: '15:00', description: 'End time (HH:mm)' })
  @IsString()
  @IsOptional()
  endTime?: string;

  @ApiPropertyOptional({ example: true, default: true })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @ApiPropertyOptional({ example: false, default: false, description: 'Set as default menu for the restaurant' })
  @IsBoolean()
  @IsOptional()
  isDefault?: boolean;

  @ApiPropertyOptional({ example: 0, default: 0 })
  @IsNumber()
  @IsOptional()
  sortOrder?: number;
}

export class UpdateMenuDto {
  @ApiProperty({ description: 'Listing ID for authorization' })
  @IsUUID()
  listingId: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  availableDays?: string[];

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  startTime?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  endTime?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isDefault?: boolean;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  sortOrder?: number;
}

export class CreateMenuCategoryDto {
  @ApiProperty({ example: 'Appetizers' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'Start your meal with our delicious appetizers' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: 0, default: 0 })
  @IsNumber()
  @IsOptional()
  sortOrder?: number;
}

export class UpdateMenuCategoryDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  sortOrder?: number;
}

export class CreateMenuItemDto {
  @ApiProperty({ description: 'Menu ID' })
  @IsUUID()
  menuId: string;

  @ApiPropertyOptional({ description: 'Menu category ID' })
  @IsUUID()
  @IsOptional()
  categoryId?: string;

  @ApiProperty({ example: 'Grilled Chicken' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'Tender grilled chicken with herbs' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({ example: 15000 })
  @IsNumber()
  @Min(0)
  price: number;

  @ApiPropertyOptional({ example: 'RWF', default: 'RWF' })
  @IsString()
  @IsOptional()
  currency?: string;

  @ApiPropertyOptional({ example: 18000, description: 'Compare at price (for showing discounts)' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  compareAtPrice?: number;

  @ApiPropertyOptional({ example: ['vegetarian', 'gluten-free'], description: 'Dietary tags' })
  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  dietaryTags?: string[];

  @ApiPropertyOptional({ example: ['nuts', 'dairy'], description: 'Allergens' })
  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  allergens?: string[];

  @ApiPropertyOptional({ example: 'medium', enum: ['mild', 'medium', 'hot'] })
  @IsString()
  @IsOptional()
  spiceLevel?: string;

  @ApiPropertyOptional({ example: true, default: true })
  @IsBoolean()
  @IsOptional()
  isAvailable?: boolean;

  @ApiPropertyOptional({ example: false, default: false })
  @IsBoolean()
  @IsOptional()
  isPopular?: boolean;

  @ApiPropertyOptional({ example: false, default: false })
  @IsBoolean()
  @IsOptional()
  isChefSpecial?: boolean;

  @ApiPropertyOptional({ example: false, default: false })
  @IsBoolean()
  @IsOptional()
  allowCustomization?: boolean;

  @ApiPropertyOptional({ 
    example: { 
      add_ons: [{ name: 'Extra cheese', price: 2000 }],
      sides: [{ name: 'Fries', price: 3000 }]
    },
    description: 'Customization options'
  })
  @IsObject()
  @IsOptional()
  customizationOptions?: any;

  @ApiPropertyOptional({ description: 'Image media ID' })
  @IsUUID()
  @IsOptional()
  imageId?: string;

  @ApiPropertyOptional({ example: 20, description: 'Estimated preparation time in minutes' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  estimatedPrepTime?: number;

  @ApiPropertyOptional({ example: 0, default: 0 })
  @IsNumber()
  @IsOptional()
  sortOrder?: number;
}

export class UpdateMenuItemDto {
  @ApiProperty({ description: 'Menu ID for authorization' })
  @IsUUID()
  menuId: string;

  @ApiPropertyOptional()
  @IsUUID()
  @IsOptional()
  categoryId?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  price?: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  currency?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  compareAtPrice?: number;

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  dietaryTags?: string[];

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  allergens?: string[];

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  spiceLevel?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isAvailable?: boolean;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isPopular?: boolean;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isChefSpecial?: boolean;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  allowCustomization?: boolean;

  @ApiPropertyOptional()
  @IsObject()
  @IsOptional()
  customizationOptions?: any;

  @ApiPropertyOptional()
  @IsUUID()
  @IsOptional()
  imageId?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  estimatedPrepTime?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  sortOrder?: number;
}

export class MenuQueryDto {
  @ApiPropertyOptional({ description: 'Filter by listing ID' })
  @IsUUID()
  @IsOptional()
  listingId?: string;

  @ApiPropertyOptional({ example: true, description: 'Filter active menus only' })
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}

