import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as request from 'supertest';
import { AdminModule } from '../src/modules/admin/admin.module';
import { AdminUsersService } from '../src/modules/admin/users/admin-users.service';
import { JwtAuthGuard } from '../src/modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '../src/common/guards/roles.guard';
import { PrismaService } from '../src/prisma/prisma.service';

describe('AdminUsersController (e2e)', () => {
  let app: INestApplication;
  let adminUsersService: AdminUsersService;
  const adminUsersServiceMocks = {
    listUsers: jest.fn().mockResolvedValue({
      data: [],
      meta: { total: 0, page: 1, limit: 20, totalPages: 1 },
    }),
    getUserById: jest.fn().mockResolvedValue({ id: 'user-1' }),
    updateUserStatus: jest.fn().mockResolvedValue({
      id: 'user-1',
      isActive: true,
      isBlocked: false,
      verificationStatus: 'verified',
    }),
    updateUserRoles: jest.fn().mockResolvedValue({
      id: 'user-1',
      roles: ['admin'],
    }),
  };
  const mockAdminUsersService = adminUsersServiceMocks as unknown as AdminUsersService;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AdminModule],
    })
      .overrideProvider(AdminUsersService)
      .useValue(mockAdminUsersService)
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

    adminUsersService = moduleRef.get(AdminUsersService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /admin/users returns paginated users', async () => {
    await request(app.getHttpServer()).get('/admin/users').expect(200).expect({
      data: [],
      meta: { total: 0, page: 1, limit: 20, totalPages: 1 },
    });

    expect(adminUsersServiceMocks.listUsers).toHaveBeenCalled();
  });

  it('GET /admin/users/:id returns user details', async () => {
    await request(app.getHttpServer()).get('/admin/users/user-1').expect(200).expect({ id: 'user-1' });

    expect(adminUsersServiceMocks.getUserById).toHaveBeenCalledWith('user-1');
  });

  it('PATCH /admin/users/:id/status updates status', async () => {
    await request(app.getHttpServer())
      .patch('/admin/users/user-1/status')
      .send({ isActive: true })
      .expect(200)
      .expect({
        id: 'user-1',
        isActive: true,
        isBlocked: false,
        verificationStatus: 'verified',
      });

    expect(adminUsersServiceMocks.updateUserStatus).toHaveBeenCalledWith('user-1', { isActive: true });
  });

  it('PATCH /admin/users/:id/roles updates roles', async () => {
    await request(app.getHttpServer())
      .patch('/admin/users/user-1/roles')
      .send({ roles: ['admin'] })
      .expect(200)
      .expect({
        id: 'user-1',
        roles: ['admin'],
      });

    expect(adminUsersServiceMocks.updateUserRoles).toHaveBeenCalledWith('user-1', { roles: ['admin'] });
  });
});


