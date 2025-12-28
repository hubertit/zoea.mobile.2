import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsArray, IsDateString, IsEnum, IsNumber, IsOptional, IsString, IsUUID, ValidateNested } from 'class-validator';
import { booking_type } from '@prisma/client';
import { Type } from 'class-transformer';

class AdminBookingGuestDto {
  @ApiProperty()
  @IsString()
  fullName: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  email?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  phone?: string;
}

export class AdminCreateBookingDto {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  userId: string;

  @ApiProperty({ enum: booking_type })
  @IsEnum(booking_type)
  bookingType: booking_type;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  listingId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  eventId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  tourId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  roomTypeId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  tableId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  ticketId?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  ticketQuantity?: number;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  tourScheduleId?: string;

  @ApiPropertyOptional()
  @IsDateString()
  @IsOptional()
  checkInDate?: string;

  @ApiPropertyOptional()
  @IsDateString()
  @IsOptional()
  checkOutDate?: string;

  @ApiPropertyOptional()
  @IsDateString()
  @IsOptional()
  bookingDate?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  bookingTime?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  guestCount?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  adults?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  children?: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  specialRequests?: string;

  @ApiPropertyOptional({ type: [AdminBookingGuestDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AdminBookingGuestDto)
  @IsOptional()
  guests?: AdminBookingGuestDto[];
}

export class AdminUpdateBookingDetailsDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  specialRequests?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  guestCount?: number;
}


