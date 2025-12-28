import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as request from 'supertest';
import { AdminModule } from '../src/modules/admin/admin.module';
import { AdminMerchantsService } from '../src/modules/admin/merchants/admin-merchants.service';
import { JwtAuthGuard } from '../src/modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '../src/common/guards/roles.guard';
import { PrismaService } from '../src/prisma/prisma.service';

describe('AdminMerchantsController (e2e)', () => {
  let app: INestApplication;
  const serviceMocks = {
    listMerchants: jest.fn().mockResolvedValue({
      data: [],
      meta: { total: 0, page: 1, limit: 20, totalPages: 1 },
    }),
    getMerchantById: jest.fn().mockResolvedValue({ id: 'merchant-1' }),
    createMerchant: jest.fn().mockResolvedValue({ id: 'merchant-1' }),
    updateMerchant: jest.fn().mockResolvedValue({ id: 'merchant-1', businessName: 'Updated' }),
    updateMerchantStatus: jest.fn().mockResolvedValue({
      id: 'merchant-1',
      registrationStatus: 'approved',
    }),
    updateMerchantSettings: jest.fn().mockResolvedValue({
      id: 'merchant-1',
      commissionRate: 12.5,
    }),
    deleteMerchant: jest.fn().mockResolvedValue({ id: 'merchant-1', deletedAt: new Date().toISOString() }),
    restoreMerchant: jest.fn().mockResolvedValue({ id: 'merchant-1', deletedAt: null }),
  };

  const mockAdminMerchantsService = serviceMocks as unknown as AdminMerchantsService;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AdminModule],
    })
      .overrideProvider(AdminMerchantsService)
      .useValue(mockAdminMerchantsService)
      .overrideProvider(PrismaService)
      .useValue({
        user: { findUnique: jest.fn().mockResolvedValue({ roles: ['admin'] }) },
      })
      .overrideGuard(JwtAuthGuard)
      .useValue({
        canActivate: (context) => {
          const req = context.switchToHttp().getRequest();
          req.user = { id: 'admin-1', roles: ['admin'] };
          return true;
        },
      })
      .overrideGuard(RolesGuard)
      .useValue({ canActivate: () => true })
      .compile();

    app = moduleRef.createNestApplication();
    await app.init();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /admin/merchants returns list', async () => {
    await request(app.getHttpServer()).get('/admin/merchants').expect(200).expect({
      data: [],
      meta: { total: 0, page: 1, limit: 20, totalPages: 1 },
    });

    expect(serviceMocks.listMerchants).toHaveBeenCalled();
  });

  it('GET /admin/merchants/:id returns detail', async () => {
    await request(app.getHttpServer()).get('/admin/merchants/merchant-1').expect(200).expect({ id: 'merchant-1' });
    expect(serviceMocks.getMerchantById).toHaveBeenCalledWith('merchant-1');
  });

  it('PATCH /admin/merchants/:id/status updates status', async () => {
    await request(app.getHttpServer())
      .patch('/admin/merchants/merchant-1/status')
      .send({ registrationStatus: 'approved' })
      .expect(200)
      .expect({ id: 'merchant-1', registrationStatus: 'approved' });

    expect(serviceMocks.updateMerchantStatus).toHaveBeenCalled();
  });

  it('PATCH /admin/merchants/:id/settings updates settings', async () => {
    await request(app.getHttpServer())
      .patch('/admin/merchants/merchant-1/settings')
      .send({ commissionRate: 12.5 })
      .expect(200)
      .expect({ id: 'merchant-1', commissionRate: 12.5 });

    expect(serviceMocks.updateMerchantSettings).toHaveBeenCalled();
  });
  it('POST /admin/merchants creates merchant', async () => {
    await request(app.getHttpServer())
      .post('/admin/merchants')
      .send({ userId: 'user-1', businessName: 'New Biz' })
      .expect(201);

    expect(serviceMocks.createMerchant).toHaveBeenCalledWith({ userId: 'user-1', businessName: 'New Biz' });
  });

  it('PUT /admin/merchants/:id updates merchant', async () => {
    await request(app.getHttpServer())
      .put('/admin/merchants/merchant-1')
      .send({ businessName: 'Updated' })
      .expect(200);

    expect(serviceMocks.updateMerchant).toHaveBeenCalled();
  });

  it('DELETE /admin/merchants/:id soft deletes merchant', async () => {
    await request(app.getHttpServer()).delete('/admin/merchants/merchant-1').expect(200);
    expect(serviceMocks.deleteMerchant).toHaveBeenCalledWith('merchant-1');
  });

  it('PATCH /admin/merchants/:id/restore restores merchant', async () => {
    await request(app.getHttpServer()).patch('/admin/merchants/merchant-1/restore').expect(200);
    expect(serviceMocks.restoreMerchant).toHaveBeenCalledWith('merchant-1');
  });
});


