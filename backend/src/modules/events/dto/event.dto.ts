import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsUUID } from 'class-validator';

export class CreateEventCommentDto {
  @ApiProperty({ example: 'Great event! Looking forward to it.' })
  @IsString()
  content: string;

  @ApiPropertyOptional({ description: 'Parent comment ID for replies' })
  @IsUUID() @IsOptional()
  parentId?: string;
}

