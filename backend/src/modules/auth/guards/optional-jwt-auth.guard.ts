import { Injectable, ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Observable } from 'rxjs';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard('jwt') {
  // Override handleRequest to not throw error if no user
  handleRequest(err: any, user: any, info: any, context: ExecutionContext) {
    // If there's an error or no user, just return null instead of throwing
    // This allows the endpoint to work for both authenticated and anonymous users
    return user || null;
  }

  // Override canActivate to allow the request even if authentication fails
  async canActivate(context: ExecutionContext): Promise<boolean> {
    try {
      const result = super.canActivate(context);
      
      // Handle different return types
      if (result instanceof Promise) {
        return await result.catch(() => true); // Allow if auth fails
      } else if (result instanceof Observable) {
        return await firstValueFrom(result).catch(() => true); // Allow if auth fails
      } else {
        return result; // boolean
      }
    } catch {
      // If authentication fails, allow the request to continue (for anonymous users)
      return true;
    }
  }
}

