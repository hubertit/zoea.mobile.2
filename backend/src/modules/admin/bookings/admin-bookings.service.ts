import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, booking_status, payment_status } from '@prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AdminListBookingsDto } from './dto/list-bookings.dto';
import { AdminUpdateBookingStatusDto } from './dto/update-booking-status.dto';
import { AdminCreateBookingDto, AdminUpdateBookingDetailsDto } from './dto/create-admin-booking.dto';

@Injectable()
export class AdminBookingsService {
  constructor(private readonly prisma: PrismaService) {}

  async listBookings(dto: AdminListBookingsDto) {
    const page = dto.page ?? 1;
    const limit = dto.limit ?? 20;
    const skip = (page - 1) * limit;

    const where: Prisma.BookingWhereInput = {};
    const andFilters: Prisma.BookingWhereInput[] = [];

    if (dto.search) {
      const search = dto.search.trim();
      andFilters.push({
        OR: [
          { bookingNumber: { contains: search, mode: 'insensitive' } },
          { user: { email: { contains: search, mode: 'insensitive' } } },
          { user: { phoneNumber: { contains: search, mode: 'insensitive' } } },
        ],
      });
    }

    if (dto.status) andFilters.push({ status: dto.status });
    if (dto.paymentStatus) andFilters.push({ paymentStatus: dto.paymentStatus });
    if (dto.merchantId) andFilters.push({ merchantId: dto.merchantId });
    if (dto.userId) andFilters.push({ userId: dto.userId });
    if (dto.startDate || dto.endDate) {
      andFilters.push({
        createdAt: {
          gte: dto.startDate,
          lte: dto.endDate,
        },
      });
    }

    if (andFilters.length) {
      where.AND = andFilters;
    }

    const [data, total] = await Promise.all([
      this.prisma.booking.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          bookingNumber: true,
          status: true,
          paymentStatus: true,
          totalAmount: true,
          currency: true,
          bookingDate: true,
          user: { select: { id: true, fullName: true, email: true } },
          listing: { select: { id: true, name: true } },
          merchant: { select: { id: true, businessName: true } },
        },
      }),
      this.prisma.booking.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.max(Math.ceil(total / limit), 1),
      },
    };
  }

  async getBooking(id: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, fullName: true, email: true, phoneNumber: true } },
        listing: { select: { id: true, name: true } },
        merchant: { select: { id: true, businessName: true } },
        roomType: true,
        guests: true,
        transactions: true,
      },
    });

    if (!booking) throw new NotFoundException('Booking not found');
    return booking;
  }

  async updateBookingStatus(id: string, adminId: string, dto: AdminUpdateBookingStatusDto) {
    const booking = await this.prisma.booking.findUnique({ where: { id } });
    if (!booking) throw new NotFoundException('Booking not found');

    const data: Prisma.BookingUncheckedUpdateInput = {};

    if (dto.status) {
      data.status = dto.status as booking_status;
      if (dto.status === 'cancelled') {
        data.cancelledAt = new Date();
        data.cancelledBy = adminId;
        if (dto.notes) data.cancellationReason = dto.notes;
      }
      if (dto.status === 'confirmed') {
        data.confirmedAt = new Date();
      }
    }

    if (dto.paymentStatus) {
      data.paymentStatus = dto.paymentStatus as payment_status;
      if (dto.paymentStatus === 'refunded' && dto.refundAmount) {
        data.refundAmount = dto.refundAmount as any;
      }
    }

    if (dto.notes && dto.status !== 'cancelled') {
      data.internalNotes = dto.notes;
    }

    const updated = await this.prisma.booking.update({
      where: { id },
      data,
      select: {
        id: true,
        status: true,
        paymentStatus: true,
        refundAmount: true,
        cancellationReason: true,
        internalNotes: true,
        updatedAt: true,
      },
    });

    return updated;
  }

  async createBooking(dto: AdminCreateBookingDto) {
    const bookingData = {
      userId: dto.userId,
      bookingType: dto.bookingType,
      listingId: dto.listingId,
      eventId: dto.eventId,
      tourId: dto.tourId,
      roomTypeId: dto.roomTypeId,
      tableId: dto.tableId,
      ticketId: dto.ticketId,
      ticketQuantity: dto.ticketQuantity,
      tourScheduleId: dto.tourScheduleId,
      checkInDate: dto.checkInDate,
      checkOutDate: dto.checkOutDate,
      bookingDate: dto.bookingDate,
      bookingTime: dto.bookingTime,
      guestCount: dto.guestCount,
      adults: dto.adults,
      children: dto.children,
      specialRequests: dto.specialRequests,
      guests: dto.guests,
    };

    const result = await this.createBookingRecord(bookingData);
    return result;
  }

  async updateBookingDetails(id: string, dto: AdminUpdateBookingDetailsDto) {
    const booking = await this.prisma.booking.findUnique({ where: { id } });
    if (!booking) throw new NotFoundException('Booking not found');

    return this.prisma.booking.update({
      where: { id },
      data: {
        specialRequests: dto.specialRequests,
        guestCount: dto.guestCount,
      },
    });
  }

  private async createBookingRecord(data: {
    userId: string;
    bookingType: string;
    listingId?: string;
    eventId?: string;
    tourId?: string;
    roomTypeId?: string;
    tableId?: string;
    ticketId?: string;
    ticketQuantity?: number;
    tourScheduleId?: string;
    checkInDate?: string;
    checkOutDate?: string;
    bookingDate?: string;
    bookingTime?: string;
    guestCount?: number;
    adults?: number;
    children?: number;
    specialRequests?: string;
    guests?: { fullName: string; email?: string; phone?: string }[];
  }) {
    if (data.bookingType === 'hotel' && (!data.listingId || !data.roomTypeId || !data.checkInDate || !data.checkOutDate)) {
      throw new BadRequestException('Hotel booking requires listingId, roomTypeId, checkInDate, and checkOutDate');
    }
    if (data.bookingType === 'restaurant' && (!data.listingId || !data.bookingDate)) {
      throw new BadRequestException('Restaurant booking requires listingId and bookingDate');
    }
    if (data.bookingType === 'event' && (!data.eventId || !data.ticketId)) {
      throw new BadRequestException('Event booking requires eventId and ticketId');
    }
    if (data.bookingType === 'tour' && (!data.tourId || !data.tourScheduleId)) {
      throw new BadRequestException('Tour booking requires tourId and tourScheduleId');
    }

    let totalAmount = 0;
    let merchantId: string | undefined;
    let organizerId: string | undefined;
    let operatorId: string | undefined;

    if (data.bookingType === 'hotel' && data.roomTypeId) {
      const roomType = await this.prisma.roomType.findUnique({
        where: { id: data.roomTypeId },
        include: { listing: { select: { merchantId: true } } },
      });
      if (!roomType) throw new BadRequestException('Room type not found');
      const checkIn = new Date(data.checkInDate!);
      const checkOut = new Date(data.checkOutDate!);
      const nights = Math.ceil((checkOut.getTime() - checkIn.getTime()) / (1000 * 60 * 60 * 24));
      totalAmount = Number(roomType.basePrice) * nights * (data.guestCount || 1);
      merchantId = roomType.listing.merchantId || undefined;
    }

    if (data.bookingType === 'event' && data.ticketId) {
      const ticket = await this.prisma.eventTicket.findUnique({
        where: { id: data.ticketId },
        include: { event: { select: { organizerId: true } } },
      });
      if (!ticket) throw new BadRequestException('Ticket not found');
      totalAmount = Number(ticket.price) * (data.ticketQuantity || 1);
      organizerId = ticket.event.organizerId || undefined;
    }

    if (data.bookingType === 'tour' && data.tourScheduleId) {
      const schedule = await this.prisma.tourSchedule.findUnique({
        where: { id: data.tourScheduleId },
        include: { tour: { select: { pricePerPerson: true, operatorId: true } } },
      });
      if (!schedule) throw new BadRequestException('Tour schedule not found');
      totalAmount = Number(schedule.priceOverride || schedule.tour.pricePerPerson) * (data.guestCount || 1);
      operatorId = schedule.tour.operatorId || undefined;
    }

    const bookingNumber = `ADM${Date.now().toString(36).toUpperCase()}${Math.random().toString(36).slice(2, 6).toUpperCase()}`;

    const booking = await this.prisma.booking.create({
      data: {
        bookingNumber,
        userId: data.userId,
        bookingType: data.bookingType as any,
        listingId: data.listingId,
        eventId: data.eventId,
        tourId: data.tourId,
        merchantId,
        organizerId,
        operatorId,
        roomTypeId: data.roomTypeId,
        tableId: data.tableId,
        ticketId: data.ticketId,
        ticketQuantity: data.ticketQuantity,
        tourScheduleId: data.tourScheduleId,
        checkInDate: data.checkInDate ? new Date(data.checkInDate) : null,
        checkOutDate: data.checkOutDate ? new Date(data.checkOutDate) : null,
        bookingDate: data.bookingDate ? new Date(data.bookingDate) : null,
        bookingTime: data.bookingTime ? new Date(`1970-01-01T${data.bookingTime}`) : null,
        guestCount: data.guestCount,
        adults: data.adults,
        children: data.children,
        totalAmount,
        currency: 'RWF',
        status: 'pending',
        paymentStatus: 'pending',
        specialRequests: data.specialRequests,
        guests: data.guests
          ? {
              create: data.guests.map((g) => ({
                fullName: g.fullName,
                email: g.email,
                phone: g.phone,
              })),
            }
          : undefined,
      },
      include: {
        listing: { select: { id: true, name: true } },
        event: { select: { id: true, name: true } },
        tour: { select: { id: true, name: true } },
      },
    });

    return booking;
  }
}


