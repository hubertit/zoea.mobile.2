import { Controller, Get, Post, Query, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ZoeaCardService } from './zoea-card.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { DepositDto, WithdrawDto, PayDto } from './dto/zoea-card.dto';

@ApiTags('Zoea Card')
@Controller('zoea-card')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ZoeaCardController {
  constructor(private zoeaCardService: ZoeaCardService) {}

  @Get()
  @ApiOperation({ summary: 'Get my Zoea Card details' })
  async getCard(@Request() req) {
    return this.zoeaCardService.getCard(req.user.id);
  }

  @Get('balance')
  @ApiOperation({ summary: 'Get card balance' })
  async getBalance(@Request() req) {
    return this.zoeaCardService.getBalance(req.user.id);
  }

  @Get('transactions')
  @ApiOperation({ summary: 'Get transaction history' })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  @ApiQuery({ name: 'type', required: false, enum: ['deposit', 'withdrawal', 'payment', 'refund'] })
  async getTransactions(
    @Request() req,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('type') type?: string,
  ) {
    return this.zoeaCardService.getTransactions(req.user.id, {
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      type,
    });
  }

  @Post('deposit')
  @ApiOperation({ summary: 'Deposit funds to card' })
  async deposit(@Request() req, @Body() data: DepositDto) {
    return this.zoeaCardService.deposit(req.user.id, data.amount, data.description);
  }

  @Post('withdraw')
  @ApiOperation({ summary: 'Withdraw funds from card' })
  async withdraw(@Request() req, @Body() data: WithdrawDto) {
    return this.zoeaCardService.withdraw(req.user.id, data.amount, data.description);
  }

  @Post('pay')
  @ApiOperation({ summary: 'Pay using card' })
  async pay(@Request() req, @Body() data: PayDto) {
    return this.zoeaCardService.pay(req.user.id, data);
  }
}

