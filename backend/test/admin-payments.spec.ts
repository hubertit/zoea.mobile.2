import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as request from 'supertest';
import { AdminModule } from '../src/modules/admin/admin.module';
import { AdminPaymentsService } from '../src/modules/admin/payments/admin-payments.service';
import { JwtAuthGuard } from '../src/modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '../src/common/guards/roles.guard';
import { PrismaService } from '../src/prisma/prisma.service';

describe('AdminPaymentsController (e2e)', () => {
  let app: INestApplication;
  const serviceMocks = {
    listTransactions: jest.fn().mockResolvedValue({
      data: [],
      meta: { total: 0, page: 1, limit: 20, totalPages: 1 },
    }),
    getTransaction: jest.fn().mockResolvedValue({ id: 'tx-1' }),
    updateTransactionStatus: jest.fn().mockResolvedValue({ id: 'tx-1', status: 'completed' }),
    listPayouts: jest.fn().mockResolvedValue({
      data: [],
      meta: { total: 0, page: 1, limit: 20, totalPages: 1 },
    }),
    getPayout: jest.fn().mockResolvedValue({ id: 'payout-1' }),
    updatePayoutStatus: jest.fn().mockResolvedValue({ id: 'payout-1', status: 'completed' }),
  };
  const mockService = serviceMocks as unknown as AdminPaymentsService;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AdminModule],
    })
      .overrideProvider(AdminPaymentsService)
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

  it('GET /admin/payments/transactions lists transactions', async () => {
    await request(app.getHttpServer()).get('/admin/payments/transactions').expect(200);
    expect(serviceMocks.listTransactions).toHaveBeenCalled();
  });

  it('GET /admin/payments/transactions/:id fetches detail', async () => {
    await request(app.getHttpServer()).get('/admin/payments/transactions/tx-1').expect(200);
    expect(serviceMocks.getTransaction).toHaveBeenCalledWith('tx-1');
  });

  it('PATCH /admin/payments/transactions/:id/status updates status', async () => {
    await request(app.getHttpServer())
      .patch('/admin/payments/transactions/tx-1/status')
      .send({ status: 'completed' })
      .expect(200);
    expect(serviceMocks.updateTransactionStatus).toHaveBeenCalled();
  });

  it('GET /admin/payments/payouts lists payouts', async () => {
    await request(app.getHttpServer()).get('/admin/payments/payouts').expect(200);
    expect(serviceMocks.listPayouts).toHaveBeenCalled();
  });

  it('GET /admin/payments/payouts/:id fetches payout', async () => {
    await request(app.getHttpServer()).get('/admin/payments/payouts/payout-1').expect(200);
    expect(serviceMocks.getPayout).toHaveBeenCalledWith('payout-1');
  });

  it('PATCH /admin/payments/payouts/:id/status updates payout', async () => {
    await request(app.getHttpServer())
      .patch('/admin/payments/payouts/payout-1/status')
      .send({ status: 'completed' })
      .expect(200);
    expect(serviceMocks.updatePayoutStatus).toHaveBeenCalled();
  });
});


