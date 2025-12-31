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
  @ApiOperation({ 
    summary: 'Get my Zoea Card details',
    description: 'Retrieves the authenticated user\'s Zoea Card information including card number, balance, status, and account details. Zoea Card is a digital wallet for making payments within the platform.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Zoea Card details retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        userId: { type: 'string' },
        cardNumber: { type: 'string', example: '1234-5678-9012-3456', description: 'Masked card number' },
        balance: { type: 'number', example: 500.00, description: 'Current card balance' },
        currency: { type: 'string', example: 'RWF', description: 'Card currency' },
        status: { type: 'string', enum: ['active', 'suspended', 'closed'], example: 'active' },
        createdAt: { type: 'string' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Zoea Card not found - Card will be created automatically on first use' })
  async getCard(@Request() req) {
    return this.zoeaCardService.getCard(req.user.id);
  }

  @Get('balance')
  @ApiOperation({ 
    summary: 'Get card balance',
    description: 'Retrieves the current balance of the authenticated user\'s Zoea Card. Returns balance in the card\'s currency.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Card balance retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        balance: { type: 'number', example: 500.00, description: 'Current card balance' },
        currency: { type: 'string', example: 'RWF', description: 'Card currency' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Zoea Card not found' })
  async getBalance(@Request() req) {
    return this.zoeaCardService.getBalance(req.user.id);
  }

  @Get('transactions')
  @ApiOperation({ 
    summary: 'Get transaction history',
    description: 'Retrieves paginated transaction history for the authenticated user\'s Zoea Card. Supports filtering by transaction type. Transactions are sorted by date (newest first).'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'type', required: false, enum: ['deposit', 'withdrawal', 'payment', 'refund'], description: 'Filter by transaction type', example: 'payment' })
  @ApiResponse({ 
    status: 200, 
    description: 'Transaction history retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { 
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'string' },
              type: { type: 'string', enum: ['deposit', 'withdrawal', 'payment', 'refund'] },
              amount: { type: 'number', example: 100.00 },
              currency: { type: 'string', example: 'RWF' },
              description: { type: 'string', example: 'Payment for booking' },
              balanceAfter: { type: 'number', example: 400.00 },
              createdAt: { type: 'string' }
            }
          }
        },
        total: { type: 'number', example: 50 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
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
  @ApiOperation({ 
    summary: 'Deposit funds to card',
    description: 'Adds funds to the authenticated user\'s Zoea Card. Requires amount and optional description. The card balance will be increased by the deposit amount.'
  })
  @ApiBody({ type: DepositDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Funds deposited successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Funds deposited successfully' },
        transaction: { type: 'object' },
        newBalance: { type: 'number', example: 600.00, description: 'Card balance after deposit' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid amount or insufficient payment method' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async deposit(@Request() req, @Body() data: DepositDto) {
    return this.zoeaCardService.deposit(req.user.id, data.amount, data.description);
  }

  @Post('withdraw')
  @ApiOperation({ 
    summary: 'Withdraw funds from card',
    description: 'Withdraws funds from the authenticated user\'s Zoea Card. Requires amount and optional description. The card balance must be sufficient for the withdrawal.'
  })
  @ApiBody({ type: WithdrawDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Funds withdrawn successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Funds withdrawn successfully' },
        transaction: { type: 'object' },
        newBalance: { type: 'number', example: 400.00, description: 'Card balance after withdrawal' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid amount or insufficient balance' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 402, description: 'Payment Required - Insufficient balance' })
  async withdraw(@Request() req, @Body() data: WithdrawDto) {
    return this.zoeaCardService.withdraw(req.user.id, data.amount, data.description);
  }

  @Post('pay')
  @ApiOperation({ 
    summary: 'Pay using card',
    description: 'Makes a payment using the Zoea Card. Can be used to pay for bookings, services, or other platform transactions. Requires booking ID or payment reference and amount. Card balance must be sufficient.'
  })
  @ApiBody({ type: PayDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Payment processed successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Payment processed successfully' },
        transaction: { type: 'object' },
        booking: { type: 'object', nullable: true, description: 'Updated booking if payment was for a booking' },
        newBalance: { type: 'number', example: 350.00, description: 'Card balance after payment' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid payment details or insufficient balance' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 402, description: 'Payment Required - Insufficient balance' })
  @ApiResponse({ status: 404, description: 'Booking or payment reference not found' })
  async pay(@Request() req, @Body() data: PayDto) {
    return this.zoeaCardService.pay(req.user.id, data);
  }
}

