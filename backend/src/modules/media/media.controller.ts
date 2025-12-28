import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  Request,
  UseInterceptors,
  UploadedFile,
  UploadedFiles,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiConsumes,
  ApiBody,
  ApiQuery,
  ApiParam,
} from '@nestjs/swagger';
import { MediaService } from './media.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UploadMediaDto, UploadFromUrlDto, UpdateMediaDto, MediaCategory } from './dto/media.dto';

@ApiTags('Media')
@Controller('media')
export class MediaController {
  constructor(private readonly mediaService: MediaService) {}

  @Get('accounts')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get storage accounts status (admin)' })
  async getAccountStats() {
    return this.mediaService.getAccountStats();
  }

  @Post('upload')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @UseInterceptors(FileInterceptor('file'))
  @ApiOperation({ summary: 'Upload a single file' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: { type: 'string', format: 'binary' },
        category: { type: 'string', enum: Object.values(MediaCategory) },
        altText: { type: 'string' },
        title: { type: 'string' },
        folder: { type: 'string' },
      },
      required: ['file'],
    },
  })
  async upload(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
    @Body() body: UploadMediaDto,
  ) {
    return this.mediaService.upload(file, req.user.id, {
      category: body.category,
      altText: body.altText,
      title: body.title,
      folder: body.folder,
    });
  }

  @Post('upload/multiple')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @UseInterceptors(FilesInterceptor('files', 10))
  @ApiOperation({ summary: 'Upload multiple files (max 10)' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        files: { type: 'array', items: { type: 'string', format: 'binary' } },
        category: { type: 'string', enum: Object.values(MediaCategory) },
        folder: { type: 'string' },
      },
      required: ['files'],
    },
  })
  async uploadMultiple(
    @Request() req,
    @UploadedFiles() files: Express.Multer.File[],
    @Body() body: { category?: MediaCategory; folder?: string },
  ) {
    const results = await Promise.all(
      files.map(file =>
        this.mediaService.upload(file, req.user.id, {
          category: body.category,
          folder: body.folder,
        }),
      ),
    );
    return { uploaded: results.length, files: results };
  }

  @Post('upload/url')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Upload from external URL' })
  @ApiBody({ type: UploadFromUrlDto })
  async uploadFromUrl(@Request() req, @Body() body: UploadFromUrlDto) {
    return this.mediaService.uploadFromUrl(body.url, req.user.id, {
      category: body.category,
      altText: body.altText,
      title: body.title,
      folder: body.folder,
    });
  }

  @Get('my')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get my uploaded media' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'type', required: false, enum: ['image', 'video', 'document', 'audio'] })
  @ApiQuery({ name: 'category', required: false, enum: Object.values(MediaCategory) })
  async getMyMedia(
    @Request() req,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('type') type?: string,
    @Query('category') category?: string,
  ) {
    return this.mediaService.findByUser(req.user.id, {
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      type,
      category,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get media by ID' })
  @ApiParam({ name: 'id', description: 'Media UUID' })
  async findOne(@Param('id') id: string) {
    return this.mediaService.findOne(id);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update media metadata' })
  @ApiParam({ name: 'id', description: 'Media UUID' })
  @ApiBody({ type: UpdateMediaDto })
  async update(@Request() req, @Param('id') id: string, @Body() body: UpdateMediaDto) {
    return this.mediaService.update(id, req.user.id, body);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete media' })
  @ApiParam({ name: 'id', description: 'Media UUID' })
  async delete(@Request() req, @Param('id') id: string) {
    return this.mediaService.delete(id, req.user.id);
  }
}

