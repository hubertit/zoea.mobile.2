import { 
  Controller, 
  Get, 
  Post, 
  Put, 
  Delete, 
  Body, 
  Param, 
  UseGuards,
  HttpCode,
  HttpStatus
} from '@nestjs/common';
import { 
  ApiTags, 
  ApiOperation, 
  ApiBearerAuth, 
  ApiResponse,
  ApiParam
} from '@nestjs/swagger';
import { IntegrationsService } from './integrations.service';
import { CreateIntegrationDto, UpdateIntegrationDto } from './dto/integration.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

@ApiTags('Integrations')
@Controller('integrations')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class IntegrationsController {
  constructor(private integrationsService: IntegrationsService) {}

  @Get()
  @Roles('admin')
  @ApiOperation({ 
    summary: 'Get all integrations',
    description: 'Retrieve all configured integrations. Admin only.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Integrations retrieved successfully'
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin only' })
  async findAll() {
    return this.integrationsService.findAll();
  }

  @Get(':id')
  @Roles('admin')
  @ApiOperation({ 
    summary: 'Get integration by ID',
    description: 'Retrieve a specific integration by ID. Admin only.'
  })
  @ApiParam({ name: 'id', description: 'Integration UUID' })
  @ApiResponse({ 
    status: 200, 
    description: 'Integration retrieved successfully'
  })
  @ApiResponse({ status: 404, description: 'Integration not found' })
  async findById(@Param('id') id: string) {
    return this.integrationsService.findById(id);
  }

  @Post()
  @Roles('admin')
  @ApiOperation({ 
    summary: 'Create a new integration',
    description: 'Create a new integration configuration. Admin only.'
  })
  @ApiResponse({ 
    status: 201, 
    description: 'Integration created successfully'
  })
  @ApiResponse({ status: 400, description: 'Bad request - Integration already exists' })
  async create(@Body() createDto: CreateIntegrationDto) {
    return this.integrationsService.create(createDto);
  }

  @Put(':id')
  @Roles('admin')
  @ApiOperation({ 
    summary: 'Update an integration',
    description: 'Update an existing integration configuration. Admin only.'
  })
  @ApiParam({ name: 'id', description: 'Integration UUID' })
  @ApiResponse({ 
    status: 200, 
    description: 'Integration updated successfully'
  })
  @ApiResponse({ status: 404, description: 'Integration not found' })
  async update(
    @Param('id') id: string,
    @Body() updateDto: UpdateIntegrationDto
  ) {
    return this.integrationsService.update(id, updateDto);
  }

  @Delete(':id')
  @Roles('admin')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Delete an integration',
    description: 'Delete an integration configuration. Admin only.'
  })
  @ApiParam({ name: 'id', description: 'Integration UUID' })
  @ApiResponse({ 
    status: 200, 
    description: 'Integration deleted successfully'
  })
  @ApiResponse({ status: 404, description: 'Integration not found' })
  async delete(@Param('id') id: string) {
    return this.integrationsService.delete(id);
  }
}

