import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateIntegrationDto, UpdateIntegrationDto } from './dto/integration.dto';

@Injectable()
export class IntegrationsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Get all integrations
   */
  async findAll() {
    return this.prisma.integration.findMany({
      orderBy: { displayName: 'asc' },
    });
  }

  /**
   * Get integration by name
   */
  async findByName(name: string) {
    const integration = await this.prisma.integration.findUnique({
      where: { name },
    });

    if (!integration) {
      throw new NotFoundException(`Integration '${name}' not found`);
    }

    return integration;
  }

  /**
   * Get integration by ID
   */
  async findById(id: string) {
    const integration = await this.prisma.integration.findUnique({
      where: { id },
    });

    if (!integration) {
      throw new NotFoundException(`Integration not found`);
    }

    return integration;
  }

  /**
   * Create a new integration
   */
  async create(data: CreateIntegrationDto) {
    // Check if integration with same name already exists
    const existing = await this.prisma.integration.findUnique({
      where: { name: data.name },
    });

    if (existing) {
      throw new BadRequestException(`Integration '${data.name}' already exists`);
    }

    return this.prisma.integration.create({
      data: {
        name: data.name,
        displayName: data.displayName,
        description: data.description,
        isActive: data.isActive ?? true,
        config: data.config,
      },
    });
  }

  /**
   * Update an integration
   */
  async update(id: string, data: UpdateIntegrationDto) {
    await this.findById(id); // Ensure it exists

    return this.prisma.integration.update({
      where: { id },
      data: {
        ...(data.displayName && { displayName: data.displayName }),
        ...(data.description !== undefined && { description: data.description }),
        ...(data.isActive !== undefined && { isActive: data.isActive }),
        ...(data.config && { config: data.config }),
        updatedAt: new Date(),
      },
    });
  }

  /**
   * Delete an integration
   */
  async delete(id: string) {
    await this.findById(id); // Ensure it exists

    await this.prisma.integration.delete({
      where: { id },
    });

    return { success: true, message: 'Integration deleted successfully' };
  }

  /**
   * Get integration config by name (for internal use by other services)
   */
  async getConfig<T = any>(name: string): Promise<T | null> {
    try {
      const integration = await this.findByName(name);
      
      if (!integration.isActive) {
        return null;
      }

      return integration.config as T;
    } catch {
      return null;
    }
  }

  /**
   * Check if integration is active
   */
  async isActive(name: string): Promise<boolean> {
    try {
      const integration = await this.findByName(name);
      return integration.isActive;
    } catch {
      return false;
    }
  }
}

