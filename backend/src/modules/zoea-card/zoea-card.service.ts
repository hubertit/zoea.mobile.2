import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Decimal } from '@prisma/client/runtime/library';

@Injectable()
export class ZoeaCardService {
  constructor(private prisma: PrismaService) {}

  async getCard(userId: string) {
    let card = await this.prisma.zoeaCard.findUnique({
      where: { userId },
    });

    if (!card) {
      // Create card for user
      card = await this.prisma.zoeaCard.create({
        data: {
          userId,
          cardNumber: this.generateCardNumber(),
          balance: 0,
          currency: 'RWF',
          status: 'active',
        },
      });
    }

    return card;
  }

  async getTransactions(userId: string, params: { page?: number; limit?: number; type?: string }) {
    const { page = 1, limit = 20, type } = params;
    const skip = (page - 1) * limit;

    const card = await this.getCard(userId);

    const where = {
      cardId: card.id,
      ...(type && { type: type as any }),
    };

    const [transactions, total] = await Promise.all([
      this.prisma.transaction.findMany({
        where,
        skip,
        take: limit,
        include: {
          booking: { select: { id: true, bookingNumber: true, bookingType: true } },
          merchant: { select: { id: true, businessName: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.transaction.count({ where }),
    ]);

    return {
      data: transactions,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async deposit(userId: string, amount: number, reference: string) {
    if (amount <= 0) throw new BadRequestException('Amount must be positive');

    const card = await this.getCard(userId);
    const balanceBefore = card.balance;
    const balanceAfter = new Decimal(balanceBefore || 0).add(amount);

    await this.prisma.$transaction([
      this.prisma.zoeaCard.update({
        where: { id: card.id },
        data: { balance: balanceAfter },
      }),
      this.prisma.transaction.create({
        data: {
          cardId: card.id,
          userId,
          type: 'deposit',
          amount,
          currency: 'RWF',
          balanceBefore,
          balanceAfter,
          description: 'Deposit to Zoea Card',
          reference,
          status: 'completed',
        },
      }),
    ]);

    return { success: true, balance: balanceAfter };
  }

  async withdraw(userId: string, amount: number, reference: string) {
    if (amount <= 0) throw new BadRequestException('Amount must be positive');

    const card = await this.getCard(userId);
    const balanceBefore = card.balance;

    if (new Decimal(balanceBefore || 0).lessThan(amount)) {
      throw new BadRequestException('Insufficient balance');
    }

    const balanceAfter = new Decimal(balanceBefore || 0).sub(amount);

    await this.prisma.$transaction([
      this.prisma.zoeaCard.update({
        where: { id: card.id },
        data: { balance: balanceAfter },
      }),
      this.prisma.transaction.create({
        data: {
          cardId: card.id,
          userId,
          type: 'withdrawal',
          amount: -amount,
          currency: 'RWF',
          balanceBefore,
          balanceAfter,
          description: 'Withdrawal from Zoea Card',
          reference,
          status: 'completed',
        },
      }),
    ]);

    return { success: true, balance: balanceAfter };
  }

  async pay(userId: string, data: {
    amount: number;
    bookingId?: string;
    merchantId?: string;
    description: string;
  }) {
    if (data.amount <= 0) throw new BadRequestException('Amount must be positive');

    const card = await this.getCard(userId);
    const balanceBefore = card.balance;

    if (new Decimal(balanceBefore || 0).lessThan(data.amount)) {
      throw new BadRequestException('Insufficient balance');
    }

    const balanceAfter = new Decimal(balanceBefore || 0).sub(data.amount);

    const [, transaction] = await this.prisma.$transaction([
      this.prisma.zoeaCard.update({
        where: { id: card.id },
        data: { balance: balanceAfter },
      }),
      this.prisma.transaction.create({
        data: {
          cardId: card.id,
          userId,
          type: 'payment',
          amount: -data.amount,
          currency: 'RWF',
          balanceBefore,
          balanceAfter,
          description: data.description,
          bookingId: data.bookingId,
          merchantId: data.merchantId,
          status: 'completed',
        },
      }),
    ]);

    return { success: true, balance: balanceAfter, transactionId: transaction.id };
  }

  async getBalance(userId: string) {
    const card = await this.getCard(userId);
    return { balance: card.balance, currency: card.currency };
  }

  private generateCardNumber(): string {
    // Generate 16-digit card number starting with 9999 (Zoea prefix)
    const prefix = '9999';
    const random = Math.floor(Math.random() * 1000000000000).toString().padStart(12, '0');
    return prefix + random;
  }
}

