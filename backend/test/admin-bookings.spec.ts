import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as request from 'supertest';
import { AdminModule } from '../src/modules/admin/admin.module';
import { AdminBookingsService } from '../src/modules/admin/bookings/admin-bookings.service';
import { JwtAuthGuard } from '../src/modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '../src/common/guards/roles.guard';
import { PrismaService } from '../src/prisma/prisma.service';

describe('AdminBookingsController (e2e)', () => {
  let app: INestApplication;
  const serviceMocks = {
    listBookings: jest.fn().mockResolvedValue({
      data: [],
      meta: { total: 0, page: 1, limit: 20, totalPages: 1 },
    }),
    getBooking: jest.fn().mockResolvedValue({ id: 'booking-1' }),
    createBooking: jest.fn().mockResolvedValue({ id: 'booking-1' }),
    updateBookingDetails: jest.fn().mockResolvedValue({ id: 'booking-1' }),
    updateBookingStatus: jest.fn().mockResolvedValue({
      id: 'booking-1',
      status: 'confirmed',
    }),
  };
  const mockAdminBookingsService = serviceMocks as unknown as AdminBookingsService;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AdminModule],
    })
      .overrideProvider(AdminBookingsService)
      .useValue(mockAdminBookingsService)
      .overrideProvider(PrismaService)
      .useValue({
        user: { findUnique: jest.fn().mockResolvedValue({ roles: ['admin'] }) },
      })
      .overrideGuard(JwtAuthGuard)
      .useValue({
        canActivate: (context) => {
          context.switchToHttp().getRequest().user = { id: 'admin-1', roles: ['admin'] };
          return true;
        },
      })
      .overrideGuard(RolesGuard)
      .useValue({ canActivate: () => true })
      .compile();

    app = moduleRef.createNestApplication();
    await app.init();
  });

  afterEach(() => jest.clearAllMocks());

  afterAll(async () => {
    await app.close();
  });

  it('GET /admin/bookings returns list', async () => {
    await request(app.getHttpServer()).get('/admin/bookings').expect(200);
    expect(serviceMocks.listBookings).toHaveBeenCalled();
  });

  it('GET /admin/bookings/:id returns detail', async () => {
    await request(app.getHttpServer()).get('/admin/bookings/booking-1').expect(200);
    expect(serviceMocks.getBooking).toHaveBeenCalledWith('booking-1');
  });

  it('PATCH /admin/bookings/:id/status updates booking', async () => {
    await request(app.getHttpServer())
      .patch('/admin/bookings/booking-1/status')
      .send({ status: 'confirmed' })
      .expect(200);

    expect(serviceMocks.updateBookingStatus).toHaveBeenCalled();
  });
  it('POST /admin/bookings creates booking', async () => {
    await request(app.getHttpServer())
      .post('/admin/bookings')
      .send({ userId: 'user-1', bookingType: 'hotel', listingId: 'listing-1', roomTypeId: 'room-1', checkInDate: '2025-12-01', checkOutDate: '2025-12-03' })
      .expect(201);
    expect(serviceMocks.createBooking).toHaveBeenCalled();
  });

  it('PUT /admin/bookings/:id updates booking details', async () => {
    await request(app.getHttpServer())
      .put('/admin/bookings/booking-1')
      .send({ specialRequests: 'Need crib' })
      .expect(200);
    expect(serviceMocks.updateBookingDetails).toHaveBeenCalledWith('booking-1', { specialRequests: 'Need crib' });
  });
});


