import { Body, Controller, Get, Param, Patch, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminPaymentsService } from './admin-payments.service';
import { AdminListTransactionsDto } from './dto/list-transactions.dto';
import { AdminUpdateTransactionStatusDto } from './dto/update-transaction-status.dto';
import { AdminListPayoutsDto } from './dto/list-payouts.dto';
import { AdminUpdatePayoutStatusDto } from './dto/update-payout-status.dto';

@ApiTags('Admin - Payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'super_admin')
@Controller('admin/payments')
export class AdminPaymentsController {
  constructor(private readonly adminPaymentsService: AdminPaymentsService) {}

  @Get('transactions')
  @ApiOperation({ summary: 'List financial transactions' })
  async listTransactions(@Query() query: AdminListTransactionsDto) {
    return this.adminPaymentsService.listTransactions(query);
  }

  @Get('transactions/:id')
  @ApiOperation({ summary: 'Get transaction detail' })
  async getTransaction(@Param('id') id: string) {
    return this.adminPaymentsService.getTransaction(id);
  }

  @Patch('transactions/:id/status')
  @ApiOperation({ summary: 'Update transaction status' })
  async updateTransaction(
    @Param('id') id: string,
    @Body() dto: AdminUpdateTransactionStatusDto,
  ) {
    return this.adminPaymentsService.updateTransactionStatus(id, dto);
  }

  @Get('payouts')
  @ApiOperation({ summary: 'List merchant payouts' })
  async listPayouts(@Query() query: AdminListPayoutsDto) {
    return this.adminPaymentsService.listPayouts(query);
  }

  @Get('payouts/:id')
  @ApiOperation({ summary: 'Get payout detail' })
  async getPayout(@Param('id') id: string) {
    return this.adminPaymentsService.getPayout(id);
  }

  @Patch('payouts/:id/status')
  @ApiOperation({ summary: 'Update payout status / reference' })
  async updatePayout(
    @Param('id') id: string,
    @Body() dto: AdminUpdatePayoutStatusDto,
  ) {
    return this.adminPaymentsService.updatePayoutStatus(id, dto);
  }
}


