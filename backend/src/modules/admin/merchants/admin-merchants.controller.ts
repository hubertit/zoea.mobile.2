import { Body, Controller, Delete, Get, Param, Patch, Post, Put, Query, UseGuards, Request } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminMerchantsService } from './admin-merchants.service';
import { AdminListMerchantsDto } from './dto/list-merchants.dto';
import { AdminUpdateMerchantStatusDto } from './dto/update-merchant-status.dto';
import { AdminUpdateMerchantSettingsDto } from './dto/update-merchant-settings.dto';
import { AdminCreateMerchantDto } from './dto/create-merchant.dto';
import { AdminUpdateMerchantDto } from './dto/update-merchant.dto';

@ApiTags('Admin - Merchants')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'super_admin')
@Controller('admin/merchants')
export class AdminMerchantsController {
  constructor(private readonly adminMerchantsService: AdminMerchantsService) {}

  @Get()
  @ApiOperation({ summary: 'List merchant profiles with filters' })
  async listMerchants(@Query() query: AdminListMerchantsDto) {
    return this.adminMerchantsService.listMerchants(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get merchant profile detail' })
  async getMerchant(@Param('id') id: string) {
    return this.adminMerchantsService.getMerchantById(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create merchant profile on behalf of a user' })
  async createMerchant(@Body() dto: AdminCreateMerchantDto) {
    return this.adminMerchantsService.createMerchant(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update merchant profile details' })
  async updateMerchant(@Param('id') id: string, @Body() dto: AdminUpdateMerchantDto) {
    return this.adminMerchantsService.updateMerchant(id, dto);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Update merchant registration status' })
  async updateStatus(
    @Param('id') id: string,
    @Request() req,
    @Body() dto: AdminUpdateMerchantStatusDto,
  ) {
    return this.adminMerchantsService.updateMerchantStatus(id, req.user.id, dto);
  }

  @Patch(':id/settings')
  @ApiOperation({ summary: 'Update merchant commission, payout & verification settings' })
  async updateSettings(
    @Param('id') id: string,
    @Request() req,
    @Body() dto: AdminUpdateMerchantSettingsDto,
  ) {
    return this.adminMerchantsService.updateMerchantSettings(id, req.user.id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft delete merchant profile' })
  async delete(@Param('id') id: string) {
    return this.adminMerchantsService.deleteMerchant(id);
  }

  @Patch(':id/restore')
  @ApiOperation({ summary: 'Restore soft-deleted merchant profile' })
  async restore(@Param('id') id: string) {
    return this.adminMerchantsService.restoreMerchant(id);
  }
}


