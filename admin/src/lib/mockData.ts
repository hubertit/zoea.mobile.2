// Mock data for UI development
// Generate 3000+ entries for each module

const firstNames = ['John', 'Jane', 'Michael', 'Sarah', 'David', 'Emily', 'James', 'Emma', 'Robert', 'Olivia', 'William', 'Sophia', 'Richard', 'Isabella', 'Joseph', 'Mia', 'Thomas', 'Charlotte', 'Charles', 'Amelia', 'Daniel', 'Harper', 'Matthew', 'Evelyn', 'Anthony', 'Abigail', 'Mark', 'Elizabeth', 'Donald', 'Sofia', 'Steven', 'Avery', 'Paul', 'Ella', 'Andrew', 'Scarlett', 'Joshua', 'Grace', 'Kenneth', 'Chloe', 'Kevin', 'Victoria', 'Brian', 'Riley', 'George', 'Aria', 'Timothy', 'Lily', 'Ronald', 'Natalie'];
const lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores', 'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts', 'Gomez', 'Phillips'];
const venues = ['The Garden Restaurant', 'Sky Bar', 'Rooftop Lounge', 'City View Cafe', 'Sunset Terrace', 'Moonlight Bistro', 'Ocean View Restaurant', 'Mountain Peak Bar', 'Riverside Cafe', 'Downtown Diner', 'Harbor House', 'Park Plaza', 'Central Square', 'Green Valley', 'Blue Moon', 'Red Rose', 'Golden Gate', 'Silver Spoon', 'Crystal Palace', 'Emerald Garden'];
const events = ['Tech Summit 2025', 'Music Festival', 'Business Conference', 'Art Exhibition', 'Food & Wine Expo', 'Sports Championship', 'Cultural Festival', 'Fashion Show', 'Film Premiere', 'Book Launch', 'Startup Pitch', 'Networking Event', 'Workshop Series', 'Charity Gala', 'Product Launch'];
const organizations = ['Tech Corp', 'Music Events Ltd', 'Business Solutions', 'Art Gallery', 'Food Network', 'Sports Association', 'Cultural Center', 'Fashion House', 'Film Studio', 'Publishing House', 'Startup Hub', 'Network Pro', 'Education Center', 'Charity Foundation', 'Marketing Agency'];
const categories = ['Apartment', 'House', 'Commercial', 'Land', 'Development'];
const propertyTypes = ['rent', 'sale'];
const statuses = ['active', 'inactive', 'pending'];
const orderStatuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];
const applicationStatuses = ['approved', 'pending', 'rejected'];

// Generate random date within last year
function randomDate(start: Date, end: Date): string {
  const date = new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  return date.toISOString().split('T')[0];
}

// Generate random phone number
function randomPhone(): string {
  return `+250788${Math.floor(100000 + Math.random() * 900000)}`;
}

// Generate users (3000+)
export const mockUsers = Array.from({ length: 3150 }, (_, i) => {
  const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
  const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
  const accountTypes = ['customer', 'merchant'];
  const accountType = accountTypes[Math.floor(Math.random() * accountTypes.length)];
  const status = statuses[Math.floor(Math.random() * statuses.length)];
  
  return {
    user_id: i + 1,
    venue_id: accountType === 'merchant' ? Math.floor(Math.random() * 100) + 1 : undefined,
    account_type: accountType,
    user_fname: firstName,
    user_lname: lastName,
    user_email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}${i}@example.com`,
    user_phone: randomPhone(),
    user_status: status,
    user_reg_date: randomDate(new Date(2024, 0, 1), new Date()),
  };
});

// Generate venues (3000+)
export const mockVenues = Array.from({ length: 3100 }, (_, i) => {
  const venueName = venues[Math.floor(Math.random() * venues.length)] + ` ${i > 0 ? i : ''}`;
  const status = ['active', 'pending', 'inactive'][Math.floor(Math.random() * 3)];
  
  return {
    venue_id: i + 1,
    user_id: Math.floor(Math.random() * 100) + 1,
    category_id: Math.floor(Math.random() * 5) + 1,
    venue_name: venueName,
    venue_about: `A beautiful ${['restaurant', 'bar', 'cafe', 'lounge'][Math.floor(Math.random() * 4)]} with great ambiance`,
    venue_rating: Number((3.5 + Math.random() * 1.5).toFixed(1)),
    venue_reviews: Math.floor(Math.random() * 500) + 10,
    venue_status: status,
    venue_price: Math.floor(Math.random() * 100000) + 20000,
    venue_address: `KG ${Math.floor(Math.random() * 1000)} St, Kigali`,
    venue_coordinates: `${-1.9 + Math.random() * 0.1},${30 + Math.random() * 0.1}`,
  };
});

// Generate properties (3000+)
export const mockProperties = Array.from({ length: 3280 }, (_, i) => {
  const category = categories[Math.floor(Math.random() * categories.length)] as 'Apartment' | 'House' | 'Commercial' | 'Land' | 'Development';
  const propertyType = propertyTypes[Math.floor(Math.random() * propertyTypes.length)] as 'rent' | 'sale';
  const status = ['available', 'sold', 'rented'][Math.floor(Math.random() * 3)] as 'available' | 'sold' | 'rented';
  
  return {
    property_id: i + 1,
    location_id: `KGL-${String(i + 1).padStart(4, '0')}`,
    agent_id: Math.floor(Math.random() * 50) + 1,
    category: category,
    bedrooms: category !== 'Land' && category !== 'Commercial' ? Math.floor(Math.random() * 5) + 1 : undefined,
    bathrooms: category !== 'Land' ? Math.floor(Math.random() * 4) + 1 : undefined,
    size: Math.floor(Math.random() * 500) + 50,
    price: Math.floor(Math.random() * 500000) + 50000,
    property_type: propertyType,
    status: status,
    title: `${category} in ${['Kacyiru', 'Nyarutarama', 'Kimisagara', 'Remera', 'Kicukiro'][Math.floor(Math.random() * 5)]}`,
    address: `KG ${Math.floor(Math.random() * 1000)} St, Kigali`,
  };
});

// Generate events/applications (3000+)
export const mockEvents = Array.from({ length: 3120 }, (_, i) => {
  const event = events[Math.floor(Math.random() * events.length)];
  const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
  const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
  const organization = organizations[Math.floor(Math.random() * organizations.length)];
  const status = applicationStatuses[Math.floor(Math.random() * applicationStatuses.length)];
  
  return {
    id: i + 1,
    event: event,
    title: ['Mr.', 'Ms.', 'Dr.', 'Prof.'][Math.floor(Math.random() * 4)],
    first_name: firstName,
    last_name: lastName,
    organization: organization,
    work_title: ['CEO', 'Manager', 'Director', 'Coordinator', 'Executive'][Math.floor(Math.random() * 5)],
    phone: randomPhone(),
    email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}${i}@${organization.toLowerCase().replace(/\s+/g, '')}.com`,
    status: status,
    updated_date: randomDate(new Date(2025, 0, 1), new Date()),
  };
});

// Generate orders (3000+)
export const mockOrders = Array.from({ length: 3050 }, (_, i) => {
  const status = orderStatuses[Math.floor(Math.random() * orderStatuses.length)] as 'pending' | 'confirmed' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  const orderDate = randomDate(new Date(2025, 0, 1), new Date());
  
  return {
    id: i + 1,
    order_no: `ORD-2025-${String(i + 1).padStart(5, '0')}`,
    customer_id: Math.floor(Math.random() * 3150) + 1,
    seller_id: Math.floor(Math.random() * 100) + 1,
    total_amount: Math.floor(Math.random() * 200000) + 25000,
    currency: 'RWF',
    status: status,
    order_date: orderDate,
  };
});

// Mock dashboard stats - updated to reflect 3000+ data with different counts
export const mockDashboardStats = {
  totalUsers: 3150,
  activeUsers: 2420,
  inactiveUsers: 730,
  totalVenues: 3100,
  activeVenues: 2750,
  pendingVenues: 350,
  totalProperties: 3280,
  totalEvents: 3120,
  totalOrders: 3050,
  totalRevenue: 285000000,
  totalApplications: 3120,
  pendingApplications: 420,
};

// Mock chart data - updated to reflect 3000+ scale with revenue below 1M
export const mockChartData = {
  revenue: [
    { date: 'Jan 18', revenue: 850000, orders: 145 },
    { date: 'Jan 19', revenue: 920000, orders: 178 },
    { date: 'Jan 20', revenue: 780000, orders: 132 },
    { date: 'Jan 21', revenue: 960000, orders: 198 },
    { date: 'Jan 22', revenue: 890000, orders: 165 },
    { date: 'Jan 23', revenue: 940000, orders: 186 },
    { date: 'Jan 24', revenue: 980000, orders: 210 },
  ],
  ordersByStatus: [
    { name: 'Delivered', value: 1820 },
    { name: 'Processing', value: 650 },
    { name: 'Confirmed', value: 380 },
    { name: 'Pending', value: 150 },
    { name: 'Shipped', value: 40 },
    { name: 'Cancelled', value: 10 },
  ],
  userGrowth: [
    { date: 'Jan 18', users: 135 },
    { date: 'Jan 19', users: 168 },
    { date: 'Jan 20', users: 145 },
    { date: 'Jan 21', users: 198 },
    { date: 'Jan 22', users: 175 },
    { date: 'Jan 23', users: 220 },
    { date: 'Jan 24', users: 245 },
  ],
  applicationsByStatus: [
    { name: 'Approved', value: 2100 },
    { name: 'Pending', value: 420 },
    { name: 'Rejected', value: 600 },
  ],
  propertiesByCategory: [
    { name: 'Apartment', value: 1320 },
    { name: 'House', value: 1020 },
    { name: 'Commercial', value: 650 },
    { name: 'Land', value: 240 },
    { name: 'Development', value: 50 },
  ],
};

// Analytics data for detailed insights
export const mockAnalyticsData = {
  // Active users by country (Rwanda has the most)
  usersByCountry: [
    { country: 'Rwanda', users: 2900, change: 1.8, changeType: 'increase' },
    { country: 'China', users: 1600, change: 31.2, changeType: 'increase' },
    { country: 'Singapore', users: 776, change: 10.9, changeType: 'increase' },
    { country: 'United States', users: 392, change: 58.7, changeType: 'increase' },
    { country: 'Kenya', users: 76, change: 20.6, changeType: 'increase' },
    { country: 'Canada', users: 63, change: 34.0, changeType: 'increase' },
    { country: 'United Kingdom', users: 58, change: -4.9, changeType: 'decrease' },
  ],
  // Page views by page title
  pageViews: [
    { page: 'Police Stations', views: 10, change: 150.0, changeType: 'increase' },
    { page: 'Real Estate', views: 12, change: 1100.0, changeType: 'increase' },
    { page: 'DPU Nyarugenge Police', views: 6, change: 200.0, changeType: 'increase' },
    { page: 'Accommodation', views: 6, change: 0, changeType: 'neutral' },
    { page: 'Beauty salon', views: 6, change: 0, changeType: 'neutral' },
    { page: 'Kids', views: 6, change: 0, changeType: 'neutral' },
    { page: 'Restaurants', views: 2, change: -50.0, changeType: 'decrease' },
  ],
  // Sessions by traffic source
  sessionsByChannel: [
    { channel: 'Direct', sessions: 849, change: 304.3, changeType: 'increase' },
    { channel: 'Organic Search', sessions: 51, change: -3.8, changeType: 'decrease' },
    { channel: 'Social Media', sessions: 28, change: 12.5, changeType: 'increase' },
    { channel: 'Referral', sessions: 15, change: 8.3, changeType: 'increase' },
    { channel: 'Email', sessions: 8, change: 0, changeType: 'neutral' },
    { channel: 'Unassigned', sessions: 1, change: 0, changeType: 'neutral' },
  ],
  // Time series data for last 30 days
  timeSeriesData: Array.from({ length: 30 }, (_, i) => {
    const date = new Date();
    date.setDate(date.getDate() - (29 - i));
    const baseUsers = 1200 + Math.floor(Math.random() * 400);
    const baseEvents = baseUsers * 4.2;
    return {
      date: date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
      users: baseUsers + Math.floor(Math.random() * 200),
      events: Math.floor(baseEvents + Math.random() * 300),
      previousUsers: 350 + Math.floor(Math.random() * 100),
      previousEvents: Math.floor((350 + Math.floor(Math.random() * 100)) * 1.2),
    };
  }),
};
