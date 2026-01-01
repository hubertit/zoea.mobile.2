import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsUUID, IsBoolean, IsArray, IsEnum, IsObject, Min } from 'class-validator';
import { Transform } from 'class-transformer';

export enum CartItemType {
  PRODUCT = 'product',
  SERVICE = 'service',
  MENU_ITEM = 'menu_item',
}

export class AddToCartDto {
  @ApiProperty({ enum: CartItemType, description: 'Type of item to add' })
  @IsEnum(CartItemType)
  itemType: CartItemType;

  @ApiPropertyOptional({ description: 'Product ID (if itemType is product)' })
  @IsUUID()
  @IsOptional()
  productId?: string;

  @ApiPropertyOptional({ description: 'Product variant ID (if itemType is product with variant)' })
  @IsUUID()
  @IsOptional()
  productVariantId?: string;

  @ApiPropertyOptional({ description: 'Service ID (if itemType is service)' })
  @IsUUID()
  @IsOptional()
  serviceId?: string;

  @ApiPropertyOptional({ description: 'Menu item ID (if itemType is menu_item)' })
  @IsUUID()
  @IsOptional()
  menuItemId?: string;

  @ApiProperty({ example: 1, default: 1, minimum: 1 })
  @IsNumber()
  @Min(1)
  quantity: number;

  @ApiPropertyOptional({ 
    example: { size: 'M', color: 'Red' },
    description: 'Customization options (for menu items)'
  })
  @IsObject()
  @IsOptional()
  customization?: any;

  @ApiPropertyOptional({ 
    example: '2025-01-15T14:00:00Z',
    description: 'Service booking date (if itemType is service)'
  })
  @IsString()
  @IsOptional()
  serviceBookingDate?: string;

  @ApiPropertyOptional({ 
    example: '14:00',
    description: 'Service booking time (if itemType is service)'
  })
  @IsString()
  @IsOptional()
  serviceBookingTime?: string;
}

export class UpdateCartItemDto {
  @ApiProperty({ example: 2, minimum: 1 })
  @IsNumber()
  @Min(1)
  quantity: number;

  @ApiPropertyOptional()
  @IsObject()
  @IsOptional()
  customization?: any;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  serviceBookingDate?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  serviceBookingTime?: string;
}

