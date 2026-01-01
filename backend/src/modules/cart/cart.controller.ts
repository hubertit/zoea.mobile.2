import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, Request, HttpCode, HttpStatus, Headers } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam, ApiResponse, ApiHeader, ApiBody } from '@nestjs/swagger';
import { CartService } from './cart.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { OptionalJwtAuthGuard } from '../auth/guards/optional-jwt-auth.guard';
import { AddToCartDto, UpdateCartItemDto } from './dto/cart.dto';

@ApiTags('Cart')
@Controller('cart')
export class CartController {
  constructor(private cartService: CartService) {}

  @Get()
  @UseGuards(OptionalJwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get user cart',
    description: 'Retrieve the current user cart with all items. Works with both authenticated users (userId from JWT) and guest users (sessionId header). Cart is automatically created if it does not exist. Returns cart with all items including product variants, services, and menu items with their details.'
  })
  @ApiHeader({ name: 'X-Session-Id', required: false, description: 'Session ID for guest users (UUID format)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Cart retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        userId: { type: 'string', nullable: true },
        sessionId: { type: 'string', nullable: true },
        items: {
          type: 'array',
          items: { type: 'object' }
        },
        createdAt: { type: 'string', format: 'date-time' },
        updatedAt: { type: 'string', format: 'date-time' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Neither userId nor sessionId provided' })
  async getCart(@Request() req, @Headers('x-session-id') sessionId?: string) {
    const userId = req.user?.userId || null;
    return this.cartService.getCart(userId, sessionId || null);
  }

  @Post('items')
  @UseGuards(OptionalJwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Add item to cart',
    description: 'Add a product, service, or menu item to the cart. Works with both authenticated and guest users. Validates inventory availability, checks product/service status, and handles variants. For products, if item already exists, quantity is incremented. For services, each booking creates a separate cart item.'
  })
  @ApiHeader({ name: 'X-Session-Id', required: false, description: 'Session ID for guest users (UUID format)' })
  @ApiBody({ type: AddToCartDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Item added to cart successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        itemType: { type: 'string', enum: ['product', 'service', 'menu_item'] },
        quantity: { type: 'number', example: 2 },
        unitPrice: { type: 'number', example: 50000 },
        totalPrice: { type: 'number', example: 100000 }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Insufficient inventory, item unavailable, invalid item type, or missing required fields' })
  @ApiResponse({ status: 404, description: 'Item not found' })
  async addToCart(
    @Request() req,
    @Headers('x-session-id') sessionId: string | undefined,
    @Body() addToCartDto: AddToCartDto,
  ) {
    const userId = req.user?.userId || null;
    return this.cartService.addToCart(userId, sessionId || null, addToCartDto);
  }

  @Put('items/:itemId')
  @UseGuards(OptionalJwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update cart item quantity',
    description: 'Update the quantity or customization options of a cart item. Automatically recalculates total price. Validates that the cart item belongs to the user\'s cart (either by userId or sessionId).'
  })
  @ApiHeader({ name: 'X-Session-Id', required: false, description: 'Session ID for guest users' })
  @ApiParam({ name: 'itemId', type: String, description: 'Cart item UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateCartItemDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Cart item updated successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Cart item does not belong to user\'s cart' })
  @ApiResponse({ status: 404, description: 'Cart item not found' })
  async updateCartItem(
    @Param('itemId') itemId: string,
    @Request() req,
    @Headers('x-session-id') sessionId: string | undefined,
    @Body() updateDto: UpdateCartItemDto,
  ) {
    const userId = req.user?.userId || null;
    return this.cartService.updateCartItem(itemId, userId, sessionId || null, updateDto);
  }

  @Delete('items/:itemId')
  @UseGuards(OptionalJwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Remove item from cart',
    description: 'Permanently remove an item from the cart. Validates that the cart item belongs to the user\'s cart before deletion.'
  })
  @ApiHeader({ name: 'X-Session-Id', required: false, description: 'Session ID for guest users' })
  @ApiParam({ name: 'itemId', type: String, description: 'Cart item UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Cart item removed successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'Cart item removed successfully' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Cart item does not belong to user\'s cart' })
  @ApiResponse({ status: 404, description: 'Cart item not found' })
  async removeCartItem(
    @Param('itemId') itemId: string,
    @Request() req,
    @Headers('x-session-id') sessionId: string | undefined,
  ) {
    const userId = req.user?.userId || null;
    return this.cartService.removeCartItem(itemId, userId, sessionId || null);
  }

  @Delete()
  @UseGuards(OptionalJwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Clear cart',
    description: 'Remove all items from the cart. The cart itself is preserved, but all cart items are deleted. Useful for resetting the shopping session.'
  })
  @ApiHeader({ name: 'X-Session-Id', required: false, description: 'Session ID for guest users' })
  @ApiResponse({ 
    status: 200, 
    description: 'Cart cleared successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'Cart cleared successfully' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Neither userId nor sessionId provided' })
  async clearCart(@Request() req, @Headers('x-session-id') sessionId: string | undefined) {
    const userId = req.user?.userId || null;
    return this.cartService.clearCart(userId, sessionId || null);
  }
}

