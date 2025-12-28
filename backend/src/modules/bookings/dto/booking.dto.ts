import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsUUID, IsDateString, IsArray, ValidateNested } from 'class-validator';
import { Type, Transform } from 'class-transformer';

class BookingGuestDto {
  @ApiProperty({ example: 'John Doe' })
  @IsString()
  fullName: string;

  @ApiPropertyOptional({ example: 'john@example.com' })
  @IsString() @IsOptional()
  email?: string;

  @ApiPropertyOptional({ example: '+250788000000' })
  @IsString() @IsOptional()
  phone?: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  isPrimary?: boolean;
}

export class CreateBookingDto {
  @ApiProperty({ enum: ['hotel', 'restaurant', 'event', 'tour'] })
  @IsString()
  bookingType: string;

  @ApiPropertyOptional({ description: 'Required for hotel/restaurant bookings' })
  @IsUUID() @IsOptional()
  listingId?: string;

  @ApiPropertyOptional({ description: 'Required for event bookings' })
  @IsUUID() @IsOptional()
  eventId?: string;

  @ApiPropertyOptional({ description: 'Required for tour bookings' })
  @IsUUID() @IsOptional()
  tourId?: string;

  @ApiPropertyOptional({ description: 'Required for hotel bookings' })
  @IsUUID() @IsOptional()
  roomTypeId?: string;

  @ApiPropertyOptional({ description: 'For restaurant bookings' })
  @IsUUID() @IsOptional()
  tableId?: string;

  @ApiPropertyOptional({ description: 'Required for event bookings' })
  @IsUUID() @IsOptional()
  ticketId?: string;

  @ApiPropertyOptional({ example: 2, description: 'Number of tickets for events' })
  @IsNumber() @IsOptional()
  ticketQuantity?: number;

  @ApiPropertyOptional({ description: 'Required for tour bookings' })
  @IsUUID() @IsOptional()
  tourScheduleId?: string;

  @ApiPropertyOptional({ example: '2025-12-01', description: 'Check-in date for hotels' })
  @IsDateString() @IsOptional()
  checkInDate?: string;

  @ApiPropertyOptional({ example: '2025-12-05', description: 'Check-out date for hotels' })
  @IsDateString() @IsOptional()
  checkOutDate?: string;

  @ApiPropertyOptional({ example: '2025-12-01', description: 'Booking date for restaurants' })
  @IsDateString() @IsOptional()
  bookingDate?: string;

  @ApiPropertyOptional({ example: '19:00', description: 'Booking time for restaurants' })
  @IsString() @IsOptional()
  bookingTime?: string;

  @ApiPropertyOptional({ example: 2 })
  @IsNumber() @IsOptional()
  guestCount?: number;

  @ApiPropertyOptional({ example: 2 })
  @IsNumber() @IsOptional()
  adults?: number;

  @ApiPropertyOptional({ example: 0 })
  @IsNumber() @IsOptional()
  children?: number;

  @ApiPropertyOptional({ example: 4, description: 'Party size for restaurant bookings' })
  @IsNumber() @IsOptional()
  partySize?: number;

  @ApiPropertyOptional({ example: 'Late checkout requested' })
  @IsString() @IsOptional()
  specialRequests?: string;

  @ApiPropertyOptional({ type: [BookingGuestDto] })
  @IsArray() @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => BookingGuestDto)
  guests?: BookingGuestDto[];
}

export class UpdateBookingDto {
  @ApiPropertyOptional({ example: 'Early check-in requested' })
  @IsString() @IsOptional()
  specialRequests?: string;

  @ApiPropertyOptional({ example: 3 })
  @IsNumber() @IsOptional()
  guestCount?: number;
}

export class CancelBookingDto {
  @ApiPropertyOptional({ example: 'Change of plans' })
  @IsString() @IsOptional()
  reason?: string;
}

export class ConfirmPaymentDto {
  @ApiProperty({ example: 'card', enum: ['card', 'momo', 'bank_transfer', 'cash', 'zoea_card'] })
  @IsString()
  paymentMethod: string;

  @ApiProperty({ example: 'PAY-123456' })
  @IsString()
  paymentReference: string;
}

export class BookingQueryDto {
  @ApiPropertyOptional({ example: 1 })
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  @IsNumber() @IsOptional()
  page?: number;

  @ApiPropertyOptional({ example: 20 })
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  @IsNumber() @IsOptional()
  limit?: number;

  @ApiPropertyOptional({ enum: ['pending', 'confirmed', 'completed', 'cancelled'] })
  @IsString() @IsOptional()
  status?: string;

  @ApiPropertyOptional({ enum: ['hotel', 'restaurant', 'event', 'tour'] })
  @IsString() @IsOptional()
  type?: string;
}

