import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsBoolean, IsOptional, IsObject, IsNotEmpty } from 'class-validator';

export class CreateIntegrationDto {
  @ApiProperty({ 
    description: 'Unique integration name (e.g., openai, visit_rwanda)',
    example: 'openai'
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ 
    description: 'Display name for the integration',
    example: 'OpenAI'
  })
  @IsString()
  @IsNotEmpty()
  displayName: string;

  @ApiPropertyOptional({ 
    description: 'Description of the integration',
    example: 'OpenAI GPT-4 integration for AI assistant'
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ 
    description: 'Whether the integration is active',
    example: true,
    default: true
  })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @ApiProperty({ 
    description: 'Integration configuration (JSON)',
    example: { apiKey: 'sk-...', model: 'gpt-4-turbo' }
  })
  @IsObject()
  @IsNotEmpty()
  config: Record<string, any>;
}

export class UpdateIntegrationDto {
  @ApiPropertyOptional({ 
    description: 'Display name for the integration',
    example: 'OpenAI GPT-4'
  })
  @IsString()
  @IsOptional()
  displayName?: string;

  @ApiPropertyOptional({ 
    description: 'Description of the integration',
    example: 'OpenAI GPT-4 Turbo integration'
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ 
    description: 'Whether the integration is active',
    example: true
  })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @ApiPropertyOptional({ 
    description: 'Integration configuration (JSON)',
    example: { apiKey: 'sk-...', model: 'gpt-4-turbo', temperature: 0.7 }
  })
  @IsObject()
  @IsOptional()
  config?: Record<string, any>;
}

