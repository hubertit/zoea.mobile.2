// API utility functions - Using mock data for development

import { 
  mockUsers, 
  mockVenues, 
  mockProperties, 
  mockEvents, 
  mockOrders,
  mockDashboardStats,
  mockChartData
} from './mockData';

// Simulate API delay
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

export async function fetchAdminStats() {
  await delay(300);
  return mockDashboardStats;
}

export async function fetchEvents() {
  await delay(200);
  return mockEvents;
}

export async function fetchVenues() {
  await delay(200);
  return mockVenues;
}

export async function fetchProperties() {
  await delay(200);
  return mockProperties;
}

export async function fetchOrders() {
  await delay(200);
  return mockOrders;
}

export async function fetchUsers() {
  await delay(200);
  return mockUsers;
}

export async function fetchChartData() {
  await delay(300);
  return mockChartData;
}

