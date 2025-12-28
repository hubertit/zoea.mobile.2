import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as request from 'supertest';
import { AdminModule } from '../src/modules/admin/admin.module';
import { AdminListingsService } from '../src/modules/admin/listings/admin-listings.service';
import { JwtAuthGuard } from '../src/modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '../src/common/guards/roles.guard';
import { PrismaService } from '../src/prisma/prisma.service';

describe('AdminListingsController (e2e)', () => {
  let app: INestApplication;
  const serviceMocks = {
    listListings: jest.fn().mockResolvedValue({
      data: [],
      meta: { total: 0, page: 1, limit: 20, totalPages: 1 },
    }),
    getListingById: jest.fn().mockResolvedValue({ id: 'listing-1' }),
    createListing: jest.fn().mockResolvedValue({ id: 'listing-1' }),
    updateListing: jest.fn().mockResolvedValue({ id: 'listing-1' }),
    updateListingStatus: jest.fn().mockResolvedValue({
      id: 'listing-1',
      status: 'active',
    }),
    deleteListing: jest.fn().mockResolvedValue({ id: 'listing-1', deletedAt: new Date().toISOString() }),
    restoreListing: jest.fn().mockResolvedValue({ id: 'listing-1', deletedAt: null }),
  };
  const mockAdminListingsService = serviceMocks as unknown as AdminListingsService;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AdminModule],
    })
      .overrideProvider(AdminListingsService)
      .useValue(mockAdminListingsService)
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

  afterEach(() => {
    jest.clearAllMocks();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /admin/listings returns list', async () => {
    await request(app.getHttpServer()).get('/admin/listings').expect(200);
    expect(serviceMocks.listListings).toHaveBeenCalled();
  });

  it('GET /admin/listings/:id returns detail', async () => {
    await request(app.getHttpServer()).get('/admin/listings/listing-1').expect(200);
    expect(serviceMocks.getListingById).toHaveBeenCalledWith('listing-1');
  });

  it('PATCH /admin/listings/:id/status updates listing', async () => {
    await request(app.getHttpServer())
      .patch('/admin/listings/listing-1/status')
      .send({ status: 'active' })
      .expect(200);

    expect(serviceMocks.updateListingStatus).toHaveBeenCalled();
  });
  it('POST /admin/listings creates listing', async () => {
    await request(app.getHttpServer())
      .post('/admin/listings')
      .send({ merchantId: 'merchant-1', name: 'New Listing' })
      .expect(201);

    expect(serviceMocks.createListing).toHaveBeenCalled();
  });

  it('PUT /admin/listings/:id updates listing', async () => {
    await request(app.getHttpServer())
      .put('/admin/listings/listing-1')
      .send({ name: 'Updated' })
      .expect(200);
    expect(serviceMocks.updateListing).toHaveBeenCalled();
  });

  it('DELETE /admin/listings/:id soft deletes listing', async () => {
    await request(app.getHttpServer()).delete('/admin/listings/listing-1').expect(200);
    expect(serviceMocks.deleteListing).toHaveBeenCalledWith('listing-1');
  });

  it('PATCH /admin/listings/:id/restore restores listing', async () => {
    await request(app.getHttpServer()).patch('/admin/listings/listing-1/restore').expect(200);
    expect(serviceMocks.restoreListing).toHaveBeenCalledWith('listing-1');
  });
});


