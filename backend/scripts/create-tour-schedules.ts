import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Helper to generate dates for next 3 months
function generateDates(startDate: Date, days: number): Date[] {
  const dates: Date[] = [];
  for (let i = 0; i < days; i++) {
    const date = new Date(startDate);
    date.setDate(date.getDate() + i);
    dates.push(date);
  }
  return dates;
}

// Tour location mappings based on tour names and descriptions
const tourLocationMapping: Record<string, { cityName: string; startLocation: string }> = {
  // Volcanoes National Park tours - Musanze
  'volcanoes': { cityName: 'Musanze', startLocation: 'Volcanoes National Park' },
  'gorilla': { cityName: 'Musanze', startLocation: 'Volcanoes National Park Headquarters' },
  'golden monkey': { cityName: 'Musanze', startLocation: 'Volcanoes National Park' },
  
  // Lake Kivu tours - Rubavu (Gisenyi)
  'lake kivu': { cityName: 'Rubavu', startLocation: 'Lake Kivu Serena Hotel' },
  'rubavu': { cityName: 'Rubavu', startLocation: 'Rubavu City Center' },
  'gisenyi': { cityName: 'Rubavu', startLocation: 'Gisenyi Beach' },
  
  // Akagera National Park - Eastern Province (use Kigali as base)
  'akagera': { cityName: 'Kigali', startLocation: 'Akagera National Park Main Gate' },
  
  // Nyungwe National Park - Rusizi/Huye
  'nyungwe': { cityName: 'Huye', startLocation: 'Nyungwe Forest Lodge' },
  
  // Kigali tours
  'kigali': { cityName: 'Kigali', startLocation: 'Kigali City Center' },
  'city tour': { cityName: 'Kigali', startLocation: 'Kigali Convention Centre' },
  'history and culture': { cityName: 'Kigali', startLocation: 'Kigali Genocide Memorial' },
  
  // Musanze countryside
  'musanze': { cityName: 'Musanze', startLocation: 'Musanze Town' },
  'countryside': { cityName: 'Musanze', startLocation: 'Musanze Caves' },
};

// Schedule patterns based on tour type
const schedulePatterns = {
  // Gorilla trekking - Limited daily slots, early morning starts
  gorillaTrekking: {
    daysPerWeek: [1, 2, 3, 4, 5, 6, 0], // All week
    slotsPerDay: 8, // Limited permits
    startTime: '06:00',
    frequency: 'daily' as const,
  },
  
  // Wildlife safaris - Daily availability
  wildlife: {
    daysPerWeek: [0, 1, 2, 3, 4, 5, 6], // All week
    slotsPerDay: 15,
    startTime: '06:30',
    frequency: 'daily' as const,
  },
  
  // City tours - Daily, multiple slots
  cityTour: {
    daysPerWeek: [0, 1, 2, 3, 4, 5, 6],
    slotsPerDay: 20,
    startTime: '09:00',
    frequency: 'daily' as const,
  },
  
  // Multi-day packages - Less frequent
  multiDay: {
    daysPerWeek: [1, 3, 5], // Mon, Wed, Fri
    slotsPerDay: 10,
    startTime: '08:00',
    frequency: 'selective' as const,
  },
  
  // Adventure activities - Weekend focused
  adventure: {
    daysPerWeek: [5, 6, 0], // Fri, Sat, Sun
    slotsPerDay: 12,
    startTime: '09:00',
    frequency: 'weekend' as const,
  },
};

function detectTourType(name: string, description: string | null): keyof typeof schedulePatterns {
  const text = `${name} ${description || ''}`.toLowerCase();
  
  if (text.includes('gorilla')) return 'gorillaTrekking';
  if (text.includes('akagera') || text.includes('nyungwe') || text.includes('wildlife') || text.includes('safari')) return 'wildlife';
  if (text.includes('kigali') && (text.includes('city') || text.includes('tour'))) return 'cityTour';
  if (text.match(/\d+\s*day/i) && parseInt(text.match(/(\d+)\s*day/i)?.[1] || '0') > 1) return 'multiDay';
  
  return 'adventure';
}

function detectLocation(name: string, description: string | null): { cityName: string; startLocation: string } {
  const text = `${name} ${description || ''}`.toLowerCase();
  
  for (const [keyword, location] of Object.entries(tourLocationMapping)) {
    if (text.includes(keyword)) {
      return location;
    }
  }
  
  // Default to Kigali if location unclear
  return { cityName: 'Kigali', startLocation: 'Kigali City Center' };
}

async function main() {
  console.log('🚀 Starting tour schedules and locations setup...\n');

  // Fetch all cities first
  const cities = await prisma.city.findMany({
    where: { country: { name: 'Rwanda' } },
    select: { id: true, name: true },
  });

  const cityMap = new Map(cities.map(c => [c.name.toLowerCase(), c.id]));
  console.log(`📍 Found ${cities.size} cities in Rwanda\n`);

  // Fetch all active tours
  const tours = await prisma.tour.findMany({
    where: {
      status: 'active',
      deletedAt: null,
    },
    select: {
      id: true,
      name: true,
      description: true,
      cityId: true,
      startLocationName: true,
      durationDays: true,
    },
  });

  console.log(`📦 Found ${tours.length} active tours\n`);

  const startDate = new Date();
  startDate.setDate(startDate.getDate() + 1); // Start from tomorrow
  const dates = generateDates(startDate, 90); // Next 3 months

  let toursUpdated = 0;
  let schedulesCreated = 0;

  for (const tour of tours) {
    console.log(`\n📍 Processing: ${tour.name}`);
    
    // Detect location and tour type
    const location = detectLocation(tour.name, tour.description);
    const tourType = detectTourType(tour.name, tour.description);
    const pattern = schedulePatterns[tourType];
    
    console.log(`   Type: ${tourType}, Location: ${location.cityName} - ${location.startLocation}`);

    // Update tour with city and location if not set
    const cityId = cityMap.get(location.cityName.toLowerCase());
    if (cityId && (!tour.cityId || !tour.startLocationName)) {
      await prisma.tour.update({
        where: { id: tour.id },
        data: {
          cityId: cityId,
          startLocationName: location.startLocation,
        },
      });
      toursUpdated++;
      console.log(`   ✅ Updated location`);
    }

    // Create schedules based on pattern
    const schedules: any[] = [];
    
    for (const date of dates) {
      const dayOfWeek = date.getDay();
      
      // Check if this day is in the pattern
      if (pattern.daysPerWeek.includes(dayOfWeek)) {
        schedules.push({
          tourId: tour.id,
          date: date,
          startTime: pattern.startTime ? new Date(`1970-01-01T${pattern.startTime}:00`) : null,
          availableSpots: pattern.slotsPerDay,
          bookedSpots: 0,
          isAvailable: true,
        });
      }
    }

    // Batch create schedules
    if (schedules.length > 0) {
      await prisma.tourSchedule.createMany({
        data: schedules,
        skipDuplicates: true,
      });
      schedulesCreated += schedules.length;
      console.log(`   ✅ Created ${schedules.length} schedules`);
    }
  }

  console.log('\n✨ Summary:');
  console.log(`   - Tours processed: ${tours.length}`);
  console.log(`   - Tours updated with locations: ${toursUpdated}`);
  console.log(`   - Schedules created: ${schedulesCreated}`);
  console.log('\n✅ Done!\n');
}

main()
  .catch((e) => {
    console.error('❌ Error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

