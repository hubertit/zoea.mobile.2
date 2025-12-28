import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsDate, IsOptional, IsString, MaxLength } from 'class-validator';
import { Transform } from 'class-transformer';

export class AdminCreateBroadcastDto {
  @ApiProperty({ description: 'Notification title' })
  @IsString()
  @MaxLength(255)
  title: string;

  @ApiProperty({ description: 'Notification body/content' })
  @IsString()
  body: string;

  @ApiProperty({ description: 'Target segment descriptor (audience type)' })
  @IsString()
  targetType: string;

  @ApiProperty({ description: 'Optional JSON filters', required: false, type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  segments?: string[];

  @ApiProperty({ description: 'Optional action URL', required: false })
  @IsOptional()
  @IsString()
  actionUrl?: string;

  @ApiProperty({ description: 'Schedule send datetime', required: false, type: String, format: 'date-time' })
  @IsOptional()
  @Transform(({ value }) => (value ? new Date(value) : undefined))
  @IsDate()
  scheduleAt?: Date;
}


