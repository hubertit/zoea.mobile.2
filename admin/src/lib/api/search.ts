import apiClient from './client';

export interface SearchResult {
  type: 'user' | 'listing' | 'event' | 'tour';
  id: string;
  title: string;
  subtitle?: string;
  href: string;
}

export interface SearchResponse {
  users?: Array<{ id: string; fullName?: string; email?: string; phoneNumber?: string }>;
  listings?: Array<{ id: string; name: string; city?: { name: string } }>;
  events?: Array<{ id: string; name: string; city?: { name: string } }>;
  tours?: Array<{ id: string; name: string }>;
  total?: number;
}

export const SearchAPI = {
  async search(query: string): Promise<SearchResult[]> {
    if (!query || query.trim().length < 2) {
      return [];
    }

    const results: SearchResult[] = [];

    try {
      // Search users
      try {
        const usersResponse = await apiClient.get('/admin/users', {
          params: { search: query.trim(), limit: 5 },
        });
        const users = usersResponse.data?.data || [];
        users.forEach((user: any) => {
          results.push({
            type: 'user',
            id: user.id,
            title: user.fullName || user.email || user.phoneNumber || 'Unknown',
            subtitle: user.email || user.phoneNumber,
            href: `/dashboard/users/${user.id}`,
          });
        });
      } catch (error) {
        // Silently fail - search should continue even if one endpoint fails
        console.error('Error searching users:', error);
      }

      // Search listings, events, tours via global search endpoint
      try {
        const searchResponse = await apiClient.get('/search', {
          params: { q: query.trim(), limit: 5 },
        });
        const data = searchResponse.data || {};

        // Add listings
        if (data.listings) {
          data.listings.forEach((listing: any) => {
            results.push({
              type: 'listing',
              id: listing.id,
              title: listing.name,
              subtitle: listing.city?.name,
              href: `/dashboard/listings/${listing.id}`,
            });
          });
        }

        // Add events
        if (data.events) {
          data.events.forEach((event: any) => {
            results.push({
              type: 'event',
              id: event.id,
              title: event.name,
              subtitle: event.city?.name,
              href: `/dashboard/events/${event.id}`,
            });
          });
        }

        // Add tours
        if (data.tours) {
          data.tours.forEach((tour: any) => {
            results.push({
              type: 'tour',
              id: tour.id,
              title: tour.name,
              href: `/dashboard/tours/${tour.id}`,
            });
          });
        }
      } catch (error) {
        // Silently fail - search should continue even if one endpoint fails
        console.error('Error searching content:', error);
      }
    } catch (error) {
      console.error('Error performing search:', error);
    }

    return results;
  },
};

