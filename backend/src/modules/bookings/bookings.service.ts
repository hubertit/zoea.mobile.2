import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class BookingsService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string, params: { page?: number; limit?: number; status?: string; type?: string }) {
    const { page = 1, limit = 20, status, type } = params;
    const skip = (page - 1) * limit;

    const where = {
      userId,
      ...(status && { status: status as any }),
      ...(type && { bookingType: type as any }),
    };

    const [bookings, total] = await Promise.all([
      this.prisma.booking.findMany({
        where,
        skip,
        take: limit,
        include: {
          listing: {
            select: {
              id: true,
              name: true,
              slug: true,
              type: true,
              images: { include: { media: true }, take: 1, where: { isPrimary: true } },
            },
          },
          event: {
            select: {
              id: true,
              name: true,
              slug: true,
              startDate: true,
              locationName: true,
              attachments: { include: { media: true }, take: 1, where: { isMainFlyer: true } },
            },
          },
          tour: {
            select: {
              id: true,
              name: true,
              slug: true,
              images: { include: { media: true }, take: 1, where: { isPrimary: true } },
            },
          },
          roomType: { select: { id: true, name: true } },
          ticket: { select: { id: true, name: true, price: true } },
          tourSchedule: { select: { id: true, date: true, startTime: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.booking.count({ where }),
    ]);

    return {
      data: bookings,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async findOne(id: string, userId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, fullName: true, email: true, phoneNumber: true } },
        listing: {
          select: {
            id: true,
            name: true,
            slug: true,
            type: true,
            address: true,
            contactPhone: true,
            contactEmail: true,
            city: { select: { name: true } },
            images: { include: { media: true }, take: 3 },
          },
        },
        event: {
          select: {
            id: true,
            name: true,
            slug: true,
            startDate: true,
            endDate: true,
            locationName: true,
            venueName: true,
            address: true,
            attachments: { include: { media: true }, take: 1 },
          },
        },
        tour: {
          select: {
            id: true,
            name: true,
            slug: true,
            startLocationName: true,
            images: { include: { media: true }, take: 1 },
          },
        },
        roomType: true,
        room: true,
        table: true,
        ticket: true,
        tourSchedule: true,
        guests: true,
        attendees: true,
        transactions: { orderBy: { createdAt: 'desc' } },
      },
    });

    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.userId !== userId) throw new BadRequestException('Not authorized');

    return booking;
  }

  async create(userId: string, data: {
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
    partySize?: number;
    specialRequests?: string;
    guests?: { fullName: string; email?: string; phone?: string; isPrimary?: boolean }[];
  }) {
    // Validate booking type requirements
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

    // Calculate total amount
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

    // Generate booking number
    const bookingNumber = `ZOE${Date.now().toString(36).toUpperCase()}${Math.random().toString(36).substring(2, 6).toUpperCase()}`;

    const booking = await this.prisma.booking.create({
      data: {
        bookingNumber,
        userId,
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
        partySize: data.partySize,
        totalAmount,
        currency: 'RWF',
        status: 'pending',
        paymentStatus: 'pending',
        specialRequests: data.specialRequests,
        guests: data.guests ? {
          create: data.guests.map(g => ({
            fullName: g.fullName,
            email: g.email,
            phone: g.phone,
            isPrimary: g.isPrimary,
          })),
        } : undefined,
      },
      include: {
        listing: { select: { id: true, name: true } },
        event: { select: { id: true, name: true } },
        tour: { select: { id: true, name: true } },
        guests: true,
      },
    });

    return booking;
  }

  async update(id: string, userId: string, data: { specialRequests?: string; guestCount?: number }) {
    const booking = await this.prisma.booking.findUnique({ where: { id } });
    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.userId !== userId) throw new BadRequestException('Not authorized');
    if (['cancelled', 'completed', 'refunded'].includes(booking.status!)) {
      throw new BadRequestException('Cannot update this booking');
    }

    return this.prisma.booking.update({
      where: { id },
      data: {
        specialRequests: data.specialRequests,
        guestCount: data.guestCount,
      },
    });
  }

  async cancel(id: string, userId: string, reason?: string) {
    const booking = await this.prisma.booking.findUnique({ where: { id } });
    
    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.userId !== userId) throw new BadRequestException('Not authorized');
    if (['cancelled', 'completed', 'refunded'].includes(booking.status!)) {
      throw new BadRequestException('Cannot cancel this booking');
    }

    const updated = await this.prisma.booking.update({
      where: { id },
      data: {
        status: 'cancelled',
        cancelledAt: new Date(),
        cancelledBy: userId,
        cancellationReason: reason,
      },
    });

    // TODO: Process refund if paid

    return updated;
  }

  async confirmPayment(id: string, paymentMethod: string, paymentReference: string) {
    const booking = await this.prisma.booking.findUnique({ where: { id } });
    
    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.paymentStatus === 'completed') {
      throw new BadRequestException('Payment already completed');
    }

    const confirmationCode = Math.random().toString(36).substring(2, 8).toUpperCase();

    const updated = await this.prisma.booking.update({
      where: { id },
      data: {
        status: 'confirmed',
        paymentStatus: 'completed',
        paymentMethod: paymentMethod as any,
        paymentReference,
        paidAt: new Date(),
        confirmedAt: new Date(),
        confirmationCode,
      },
    });

    // Create attendees for event bookings
    if (booking.bookingType === 'event' && booking.ticketQuantity) {
      const guests = await this.prisma.bookingGuest.findMany({
        where: { bookingId: id },
      });

      for (let i = 0; i < booking.ticketQuantity; i++) {
        const guest = guests[i];
        await this.prisma.eventAttendee.create({
          data: {
            eventId: booking.eventId!,
            userId: booking.userId,
            bookingId: id,
            ticketId: booking.ticketId,
            fullName: guest?.fullName,
            email: guest?.email,
            phone: guest?.phone,
            ticketCode: `${confirmationCode}-${i + 1}`,
          },
        });
      }

      // Update ticket sold count
      await this.prisma.eventTicket.update({
        where: { id: booking.ticketId! },
        data: { soldQuantity: { increment: booking.ticketQuantity } },
      });
    }

    return updated;
  }

  async getUpcoming(userId: string, limit = 5) {
    return this.prisma.booking.findMany({
      where: {
        userId,
        status: { in: ['pending', 'confirmed'] },
        OR: [
          { checkInDate: { gte: new Date() } },
          { bookingDate: { gte: new Date() } },
          { event: { startDate: { gte: new Date() } } },
          { tourSchedule: { date: { gte: new Date() } } },
        ],
      },
      take: limit,
      include: {
        listing: { select: { id: true, name: true, type: true } },
        event: { select: { id: true, name: true, startDate: true } },
        tour: { select: { id: true, name: true } },
        tourSchedule: { select: { date: true } },
      },
      orderBy: [
        { checkInDate: 'asc' },
        { bookingDate: 'asc' },
      ],
    });
  }
}
