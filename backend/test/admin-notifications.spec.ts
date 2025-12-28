import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as request from 'supertest';
import { AdminModule } from '../src/modules/admin/admin.module';
import { AdminNotificationsService } from '../src/modules/admin/notifications/admin-notifications.service';
import { JwtAuthGuard } from '../src/modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '../src/common/guards/roles.guard';
import { PrismaService } from '../src/prisma/prisma.service';

describe('AdminNotificationsController (e2e)', () => {
  let app: INestApplication;
  const serviceMocks = {
    listRequests: jest.fn().mockResolvedValue({
      data: [],
      meta: { total: 0, page: 1, limit: 20, totalPages: 1 },
    }),
    updateRequest: jest.fn().mockResolvedValue({ id: 'req-1', status: 'approved' }),
    createBroadcast: jest.fn().mockResolvedValue({ id: 'req-2', status: 'approved' }),
  };
  const mockService = serviceMocks as unknown as AdminNotificationsService;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AdminModule],
    })
      .overrideProvider(AdminNotificationsService)
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

  it('GET /admin/notifications/requests lists requests', async () => {
    await request(app.getHttpServer()).get('/admin/notifications/requests').expect(200);
    expect(serviceMocks.listRequests).toHaveBeenCalled();
  });

  it('PATCH /admin/notifications/requests/:id/status updates request', async () => {
    await request(app.getHttpServer())
      .patch('/admin/notifications/requests/req-1/status')
      .send({ status: 'approved' })
      .expect(200);
    expect(serviceMocks.updateRequest).toHaveBeenCalled();
  });

  it('POST /admin/notifications/broadcast creates broadcast', async () => {
    await request(app.getHttpServer())
      .post('/admin/notifications/broadcast')
      .send({ title: 'Hello', body: 'World', targetType: 'all' })
      .expect(201);
    expect(serviceMocks.createBroadcast).toHaveBeenCalled();
  });
});


