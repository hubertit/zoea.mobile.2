import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, payment_status, transaction_status } from '@prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AdminListTransactionsDto } from './dto/list-transactions.dto';
import { AdminUpdateTransactionStatusDto } from './dto/update-transaction-status.dto';
import { AdminListPayoutsDto } from './dto/list-payouts.dto';
import { AdminUpdatePayoutStatusDto } from './dto/update-payout-status.dto';

@Injectable()
export class AdminPaymentsService {
  constructor(private readonly prisma: PrismaService) {}

  async listTransactions(dto: AdminListTransactionsDto) {
    const page = dto.page ?? 1;
    const limit = dto.limit ?? 20;
    const skip = (page - 1) * limit;

    const where: Prisma.TransactionWhereInput = {};
    const andFilters: Prisma.TransactionWhereInput[] = [];

    if (dto.type) andFilters.push({ type: dto.type });
    if (dto.status) andFilters.push({ status: dto.status });
    if (dto.merchantId) andFilters.push({ merchantId: dto.merchantId });
    if (dto.userId) andFilters.push({ userId: dto.userId });
    if (dto.search) {
      const search = dto.search.trim();
      andFilters.push({
        OR: [
          { reference: { contains: search, mode: 'insensitive' } },
          { description: { contains: search, mode: 'insensitive' } },
        ],
      });
    }

    if (andFilters.length) where.AND = andFilters;

    const [data, total] = await Promise.all([
      this.prisma.transaction.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          type: true,
          status: true,
          amount: true,
          currency: true,
          reference: true,
          description: true,
          createdAt: true,
          merchant: { select: { id: true, businessName: true } },
          user: { select: { id: true, fullName: true } },
        },
      }),
      this.prisma.transaction.count({ where }),
    ]);

    return {
      data,
      meta: { total, page, limit, totalPages: Math.max(Math.ceil(total / limit), 1) },
    };
  }

  async getTransaction(id: string) {
    const transaction = await this.prisma.transaction.findUnique({
      where: { id },
      include: {
        merchant: { select: { id: true, businessName: true } },
        user: { select: { id: true, fullName: true, email: true } },
        booking: { select: { id: true, bookingNumber: true } },
      },
    });
    if (!transaction) throw new NotFoundException('Transaction not found');
    return transaction;
  }

  async updateTransactionStatus(id: string, dto: AdminUpdateTransactionStatusDto) {
    await this.ensureTransactionExists(id);

    const updated = await this.prisma.transaction.update({
      where: { id },
      data: { status: dto.status as transaction_status },
      select: { id: true, status: true },
    });

    return updated;
  }

  async listPayouts(dto: AdminListPayoutsDto) {
    const page = dto.page ?? 1;
    const limit = dto.limit ?? 20;
    const skip = (page - 1) * limit;

    const where: Prisma.payoutsWhereInput = {};
    const andFilters: Prisma.payoutsWhereInput[] = [];

    if (dto.status) andFilters.push({ status: dto.status });
    if (dto.merchantId) andFilters.push({ merchant_id: dto.merchantId });
    if (dto.search) {
      const search = dto.search.trim();
      andFilters.push({
        OR: [
          { payout_number: { contains: search, mode: 'insensitive' } },
          { payment_reference: { contains: search, mode: 'insensitive' } },
        ],
      });
    }

    if (andFilters.length) where.AND = andFilters;

    const [data, total] = await Promise.all([
      this.prisma.payouts.findMany({
        where,
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        select: {
          id: true,
          payout_number: true,
          status: true,
          net_amount: true,
          currency: true,
          period_start: true,
          period_end: true,
          merchant_profiles: { select: { id: true, businessName: true } },
        },
      }),
      this.prisma.payouts.count({ where }),
    ]);

    return {
      data,
      meta: { total, page, limit, totalPages: Math.max(Math.ceil(total / limit), 1) },
    };
  }

  async getPayout(id: string) {
    const payout = await this.prisma.payouts.findUnique({
      where: { id },
      include: {
        merchant_profiles: { select: { id: true, businessName: true } },
      },
    });
    if (!payout) throw new NotFoundException('Payout not found');
    return payout;
  }

  async updatePayoutStatus(id: string, dto: AdminUpdatePayoutStatusDto) {
    await this.ensurePayoutExists(id);

    const data: Prisma.payoutsUpdateInput = {};
    if (dto.status) data.status = dto.status as payment_status;
    if (dto.paymentReference !== undefined) data.payment_reference = dto.paymentReference;
    if (dto.notes !== undefined) data.notes = dto.notes;
    if (dto.status === 'completed') {
      data.paid_at = new Date();
    }

    const updated = await this.prisma.payouts.update({
      where: { id },
      data,
      select: {
        id: true,
        status: true,
        payment_reference: true,
        notes: true,
        paid_at: true,
      },
    });

    return updated;
  }

  private async ensureTransactionExists(id: string) {
    const exists = await this.prisma.transaction.findUnique({ where: { id }, select: { id: true } });
    if (!exists) throw new NotFoundException('Transaction not found');
  }

  private async ensurePayoutExists(id: string) {
    const exists = await this.prisma.payouts.findUnique({ where: { id }, select: { id: true } });
    if (!exists) throw new NotFoundException('Payout not found');
  }
}


