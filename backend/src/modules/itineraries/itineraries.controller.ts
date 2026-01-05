import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, Request, NotFoundException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse, ApiExcludeEndpoint } from '@nestjs/swagger';
import { ItinerariesService } from './itineraries.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateItineraryDto, UpdateItineraryDto, ItineraryQueryDto } from './dto/itinerary.dto';

@ApiTags('Itineraries')
@Controller('itineraries')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ItinerariesController {
  constructor(private itinerariesService: ItinerariesService) {}

  @Get('my')
  @ApiOperation({
    summary: 'Get my itineraries',
    description: 'Retrieve paginated list of itineraries created by the authenticated user',
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 50, description: 'Items per page (default: 50)' })
  @ApiResponse({
    status: 200,
    description: 'Itineraries retrieved successfully',
  })
  async getMyItineraries(@Request() req, @Query() query: ItineraryQueryDto) {
    return this.itinerariesService.findAll(req.user.id, {
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 50,
    });
  }

  // Client-side only routes - must be BEFORE :id route to avoid matching
  // Hidden from Swagger docs since these are client-side navigation routes
  @Get('add-from-favorites')
  @ApiExcludeEndpoint()
  async addFromFavorites() {
    throw new NotFoundException('This is a client-side route. Use /favorites endpoint instead.');
  }

  @Get('add-from-recommendations')
  @ApiExcludeEndpoint()
  async addFromRecommendations() {
    throw new NotFoundException('This is a client-side route. Use /listings/featured endpoint instead.');
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get itinerary by ID',
    description: 'Retrieve a specific itinerary by ID. User must own the itinerary or it must be public.',
  })
  @ApiParam({ name: 'id', description: 'Itinerary UUID' })
  @ApiResponse({
    status: 200,
    description: 'Itinerary retrieved successfully',
  })
  @ApiResponse({ status: 404, description: 'Itinerary not found' })
  @ApiResponse({ status: 403, description: 'Access denied' })
  async getItinerary(@Param('id') id: string, @Request() req) {
    return this.itinerariesService.findOne(id, req.user.id);
  }

  @Post()
  @ApiOperation({
    summary: 'Create new itinerary',
    description: 'Create a new itinerary with optional items (listings, events, tours, or custom items)',
  })
  @ApiResponse({
    status: 201,
    description: 'Itinerary created successfully',
  })
  async createItinerary(@Request() req, @Body() dto: CreateItineraryDto) {
    return this.itinerariesService.create(req.user.id, dto);
  }

  @Put(':id')
  @ApiOperation({
    summary: 'Update itinerary',
    description: 'Update an existing itinerary. Only the owner can update their itinerary.',
  })
  @ApiParam({ name: 'id', description: 'Itinerary UUID' })
  @ApiResponse({
    status: 200,
    description: 'Itinerary updated successfully',
  })
  @ApiResponse({ status: 404, description: 'Itinerary not found' })
  @ApiResponse({ status: 403, description: 'Access denied' })
  async updateItinerary(@Param('id') id: string, @Request() req, @Body() dto: UpdateItineraryDto) {
    return this.itinerariesService.update(id, req.user.id, dto);
  }

  @Delete(':id')
  @ApiOperation({
    summary: 'Delete itinerary',
    description: 'Soft delete an itinerary. Only the owner can delete their itinerary.',
  })
  @ApiParam({ name: 'id', description: 'Itinerary UUID' })
  @ApiResponse({
    status: 200,
    description: 'Itinerary deleted successfully',
  })
  @ApiResponse({ status: 404, description: 'Itinerary not found' })
  @ApiResponse({ status: 403, description: 'Access denied' })
  async deleteItinerary(@Param('id') id: string, @Request() req) {
    return this.itinerariesService.delete(id, req.user.id);
  }

  @Post(':id/share')
  @ApiOperation({
    summary: 'Share itinerary',
    description: 'Generate or retrieve a share token for the itinerary. Makes the itinerary public if not already.',
  })
  @ApiParam({ name: 'id', description: 'Itinerary UUID' })
  @ApiResponse({
    status: 200,
    description: 'Share token generated successfully',
  })
  @ApiResponse({ status: 404, description: 'Itinerary not found' })
  @ApiResponse({ status: 403, description: 'Access denied' })
  async shareItinerary(@Param('id') id: string, @Request() req) {
    return this.itinerariesService.share(id, req.user.id);
  }
}

@ApiTags('Itineraries')
@Controller('itineraries')
export class PublicItinerariesController {
  constructor(private itinerariesService: ItinerariesService) {}

  @Get('shared/:token')
  @ApiOperation({
    summary: 'Get shared itinerary by token',
    description: 'Retrieve a public itinerary using its share token. No authentication required.',
  })
  @ApiParam({ name: 'token', description: 'Share token' })
  @ApiResponse({
    status: 200,
    description: 'Shared itinerary retrieved successfully',
  })
  @ApiResponse({ status: 404, description: 'Shared itinerary not found' })
  async getSharedItinerary(@Param('token') token: string) {
    return this.itinerariesService.findByShareToken(token);
  }
}

