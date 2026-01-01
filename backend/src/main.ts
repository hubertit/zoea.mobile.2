import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Security - disable CSP for Swagger UI
  app.use(
    helmet({
      contentSecurityPolicy: false,
      crossOriginEmbedderPolicy: false,
    }),
  );
  app.enableCors({
    origin: process.env.CORS_ORIGIN || '*',
    credentials: true,
  });

  // Validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  // API prefix
  app.setGlobalPrefix('api');

  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('Zoea API')
    .setDescription('Zoea Platform API Documentation')
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('Health', 'Health check and system status endpoints')
    .addTag('Auth', 'Authentication and authorization endpoints')
    .addTag('Users', 'User profile and preferences management')
    .addTag('Listings', 'Listings (hotels, restaurants, attractions) management')
    .addTag('Events', 'Events discovery and management')
    .addTag('Tours', 'Tours and tour schedules management')
    .addTag('Bookings', 'Booking creation and management')
    .addTag('Reviews', 'Reviews and ratings management')
    .addTag('Favorites', 'Favorites and saved items management')
    .addTag('Search', 'Search functionality and history')
    .addTag('Categories', 'Categories, amenities, and tags management')
    .addTag('Countries & Cities', 'Countries, cities, and location data')
    .addTag('Media', 'Media upload and management')
    .addTag('Merchants', 'Merchant business and listing management')
    .addTag('Notifications', 'User notifications management')
    .addTag('Zoea Card', 'Zoea Card digital wallet operations')
    .addTag('Analytics', 'Analytics and tracking endpoints')
    .addTag('Products', 'Product catalog and inventory management for marketplace/shop')
    .addTag('Services', 'Service offerings and booking management')
    .addTag('Menus', 'Restaurant menu and menu item management')
    .addTag('Cart', 'Shopping cart management for products, services, and menu items')
    .addTag('Orders', 'E-commerce order creation, tracking, and fulfillment')
    .addTag('Admin - Users', 'Admin user management endpoints')
    .addTag('Admin - Bookings', 'Admin booking management endpoints')
    .addTag('Admin - Listings', 'Admin listing management endpoints')
    .addTag('Admin - Merchants', 'Admin merchant management endpoints')
    .addTag('Admin - Events', 'Admin event management endpoints')
    .addTag('Admin - Payments', 'Admin payment and transaction management')
    .addTag('Admin - Notifications', 'Admin notification management endpoints')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    swaggerOptions: {
      tagsSorter: (a, b) => {
        // Custom tag order
        const tagOrder = [
          'Health',
          'Auth',
          'Users',
          'Listings',
          'Events',
          'Tours',
          'Bookings',
          'Reviews',
          'Favorites',
          'Search',
          'Categories',
          'Countries & Cities',
          'Media',
          'Merchants',
          'Notifications',
          'Zoea Card',
          'Analytics',
          'Products',
          'Services',
          'Menus',
          'Cart',
          'Orders',
          'Admin - Users',
          'Admin - Bookings',
          'Admin - Listings',
          'Admin - Merchants',
          'Admin - Events',
          'Admin - Payments',
          'Admin - Notifications',
        ];
        const indexA = tagOrder.indexOf(a);
        const indexB = tagOrder.indexOf(b);
        if (indexA === -1 && indexB === -1) return a.localeCompare(b);
        if (indexA === -1) return 1;
        if (indexB === -1) return -1;
        return indexA - indexB;
      },
      operationsSorter: 'method', // Sort by HTTP method (GET, POST, PUT, DELETE, PATCH)
      docExpansion: 'none', // Don't expand operations by default
      filter: true, // Enable filter box
      showRequestDuration: true, // Show request duration
    },
  });

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`🚀 Zoea API running on http://localhost:${port}`);
  console.log(`📚 API Docs: http://localhost:${port}/api/docs`);
}
bootstrap();

