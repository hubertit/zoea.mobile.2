import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as request from 'supertest';
import { AdminModule } from '../src/modules/admin/admin.module';
import { AdminEventsService } from '../src/modules/admin/events/admin-events.service';
import { JwtAuthGuard } from '../src/modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '../src/common/guards/roles.guard';
import { PrismaService } from '../src/prisma/prisma.service';

describe('AdminEventsController (e2e)', () => {
  let app: INestApplication;
  const serviceMocks = {
    listEvents: jest.fn().mockResolvedValue({
      data: [],
      meta: { total: 0, page: 1, limit: 20, totalPages: 1 },
    }),
    getEvent: jest.fn().mockResolvedValue({ id: 'event-1' }),
    createEvent: jest.fn().mockResolvedValue({ id: 'event-1' }),
    updateEvent: jest.fn().mockResolvedValue({ id: 'event-1' }),
    updateEventStatus: jest.fn().mockResolvedValue({ id: 'event-1', status: 'published' }),
    deleteEvent: jest.fn().mockResolvedValue({ id: 'event-1', deletedAt: new Date().toISOString() }),
    restoreEvent: jest.fn().mockResolvedValue({ id: 'event-1', deletedAt: null }),
  };
  const mockService = serviceMocks as unknown as AdminEventsService;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AdminModule],
    })
      .overrideProvider(AdminEventsService)
      .useValue(mockService)
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

  afterAll(async () => app.close());

  it('GET /admin/events lists events', async () => {
    await request(app.getHttpServer()).get('/admin/events').expect(200);
    expect(serviceMocks.listEvents).toHaveBeenCalled();
  });

  it('GET /admin/events/:id returns detail', async () => {
    await request(app.getHttpServer()).get('/admin/events/event-1').expect(200);
    expect(serviceMocks.getEvent).toHaveBeenCalledWith('event-1');
  });

  it('PATCH /admin/events/:id/status updates event', async () => {
    await request(app.getHttpServer())
      .patch('/admin/events/event-1/status')
      .send({ status: 'published' })
      .expect(200);
    expect(serviceMocks.updateEventStatus).toHaveBeenCalled();
  });
  it('POST /admin/events creates event', async () => {
    await request(app.getHttpServer())
      .post('/admin/events')
      .send({ organizerId: 'org-1', name: 'Admin Event' })
      .expect(201);
    expect(serviceMocks.createEvent).toHaveBeenCalled();
  });

  it('PUT /admin/events/:id updates event', async () => {
    await request(app.getHttpServer())
      .put('/admin/events/event-1')
      .send({ name: 'Updated Event' })
      .expect(200);
    expect(serviceMocks.updateEvent).toHaveBeenCalled();
  });

  it('DELETE /admin/events/:id soft deletes event', async () => {
    await request(app.getHttpServer()).delete('/admin/events/event-1').expect(200);
    expect(serviceMocks.deleteEvent).toHaveBeenCalledWith('event-1');
  });

  it('PATCH /admin/events/:id/restore restores event', async () => {
    await request(app.getHttpServer()).patch('/admin/events/event-1/restore').expect(200);
    expect(serviceMocks.restoreEvent).toHaveBeenCalledWith('event-1');
  });
});


