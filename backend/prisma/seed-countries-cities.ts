import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌍 Seeding countries and cities...');

  // Add South Africa
  const southAfrica = await prisma.country.upsert({
    where: { code: 'ZAF' },
    update: {
      isActive: true,
    },
    create: {
      name: 'South Africa',
      code: 'ZAF',
      code2: 'ZA',
      phoneCode: '+27',
      currencyCode: 'ZAR',
      currencySymbol: 'R',
      flagEmoji: '🇿🇦',
      defaultLanguage: 'en',
      supportedLanguages: ['en', 'af', 'zu', 'xh'],
      timezone: 'Africa/Johannesburg',
      isActive: true,
      launchedAt: new Date(),
    },
  });

  // Add Nigeria
  const nigeria = await prisma.country.upsert({
    where: { code: 'NGA' },
    update: {
      isActive: true,
    },
    create: {
      name: 'Nigeria',
      code: 'NGA',
      code2: 'NG',
      phoneCode: '+234',
      currencyCode: 'NGN',
      currencySymbol: '₦',
      flagEmoji: '🇳🇬',
      defaultLanguage: 'en',
      supportedLanguages: ['en', 'yo', 'ig', 'ha'],
      timezone: 'Africa/Lagos',
      isActive: true,
      launchedAt: new Date(),
    },
  });

  // Get Rwanda
  const rwanda = await prisma.country.findFirst({
    where: { code: 'RWA' },
  });

  if (!rwanda) {
    console.log('⚠️  Rwanda not found, creating...');
    await prisma.country.create({
      data: {
        name: 'Rwanda',
        code: 'RWA',
        code2: 'RW',
        phoneCode: '+250',
        currencyCode: 'RWF',
        currencySymbol: 'FRw',
        flagEmoji: '🇷🇼',
        defaultLanguage: 'en',
        supportedLanguages: ['en', 'rw', 'fr'],
        timezone: 'Africa/Kigali',
        isActive: true,
        launchedAt: new Date(),
      },
    });
  }

  // Rwanda Cities
  const rwandaCities = [
    'Kigali',
    'Butare',
    'Gitarama',
    'Ruhengeri',
    'Gisenyi',
    'Byumba',
    'Cyangugu',
    'Kibungo',
    'Kibuye',
    'Huye',
    'Rusizi',
    'Nyagatare',
    'Musanze',
    'Rubavu',
    'Nyamagabe',
    'Nyanza',
    'Ruhango',
    'Muhanga',
    'Kamonyi',
    'Karongi',
  ];

  if (rwanda) {
    for (const cityName of rwandaCities) {
      const slug = cityName.toLowerCase().replace(/\s+/g, '-');
      // Check if city exists first
      const existingCity = await prisma.city.findFirst({
        where: {
          countryId: rwanda.id,
          slug,
        },
      });
      
      if (!existingCity) {
        await prisma.city.create({
          data: {
            countryId: rwanda.id,
            name: cityName,
            slug,
            timezone: 'Africa/Kigali',
            isActive: true,
          },
        });
      } else {
        await prisma.city.update({
          where: { id: existingCity.id },
          data: { isActive: true },
        });
      }
    }
    console.log(`✅ Added ${rwandaCities.length} cities for Rwanda`);
  }

  // South Africa Cities
  const southAfricaCities = [
    'Johannesburg',
    'Cape Town',
    'Durban',
    'Pretoria',
    'Port Elizabeth',
    'Bloemfontein',
    'East London',
    'Polokwane',
    'Nelspruit',
    'Kimberley',
    'Rustenburg',
    'Welkom',
    'Pietermaritzburg',
    'Benoni',
    'Tembisa',
    'Vereeniging',
    'Boksburg',
    'Soweto',
    'Sandton',
    'Centurion',
  ];

  for (const cityName of southAfricaCities) {
    const slug = cityName.toLowerCase().replace(/\s+/g, '-');
    const existingCity = await prisma.city.findFirst({
      where: {
        countryId: southAfrica.id,
        slug,
      },
    });
    
    if (!existingCity) {
      await prisma.city.create({
        data: {
          countryId: southAfrica.id,
          name: cityName,
          slug,
          timezone: 'Africa/Johannesburg',
          isActive: true,
        },
      });
    } else {
      await prisma.city.update({
        where: { id: existingCity.id },
        data: { isActive: true },
      });
    }
  }
  console.log(`✅ Added ${southAfricaCities.length} cities for South Africa`);

  // Nigeria Cities
  const nigeriaCities = [
    'Lagos',
    'Kano',
    'Ibadan',
    'Abuja',
    'Port Harcourt',
    'Benin City',
    'Kaduna',
    'Aba',
    'Maiduguri',
    'Ilorin',
    'Warri',
    'Onitsha',
    'Abeokuta',
    'Enugu',
    'Zaria',
    'Jos',
    'Calabar',
    'Uyo',
    'Akure',
    'Owerri',
  ];

  for (const cityName of nigeriaCities) {
    const slug = cityName.toLowerCase().replace(/\s+/g, '-');
    const existingCity = await prisma.city.findFirst({
      where: {
        countryId: nigeria.id,
        slug,
      },
    });
    
    if (!existingCity) {
      await prisma.city.create({
        data: {
          countryId: nigeria.id,
          name: cityName,
          slug,
          timezone: 'Africa/Lagos',
          isActive: true,
        },
      });
    } else {
      await prisma.city.update({
        where: { id: existingCity.id },
        data: { isActive: true },
      });
    }
  }
  console.log(`✅ Added ${nigeriaCities.length} cities for Nigeria`);

  // Add cities for other countries if they exist
  const otherCountries = await prisma.country.findMany({
    where: {
      code: { in: ['KEN', 'UGA', 'TZA', 'BDI', 'ETH'] },
    },
  });

  // Kenya Cities
  const kenya = otherCountries.find(c => c.code === 'KEN');
  if (kenya) {
    const kenyaCities = [
      'Nairobi',
      'Mombasa',
      'Kisumu',
      'Nakuru',
      'Eldoret',
      'Thika',
      'Malindi',
      'Kitale',
      'Garissa',
      'Kakamega',
    ];
    for (const cityName of kenyaCities) {
      const slug = cityName.toLowerCase().replace(/\s+/g, '-');
      const existingCity = await prisma.city.findFirst({
        where: {
          countryId: kenya.id,
          slug,
        },
      });
      
      if (!existingCity) {
        await prisma.city.create({
          data: {
            countryId: kenya.id,
            name: cityName,
            slug,
            timezone: 'Africa/Nairobi',
            isActive: true,
          },
        });
      } else {
        await prisma.city.update({
          where: { id: existingCity.id },
          data: { isActive: true },
        });
      }
    }
    console.log(`✅ Added ${kenyaCities.length} cities for Kenya`);
  }

  // Uganda Cities
  const uganda = otherCountries.find(c => c.code === 'UGA');
  if (uganda) {
    const ugandaCities = [
      'Kampala',
      'Gulu',
      'Lira',
      'Mbarara',
      'Jinja',
      'Mbale',
      'Mukono',
      'Masaka',
      'Entebbe',
      'Arua',
    ];
    for (const cityName of ugandaCities) {
      const slug = cityName.toLowerCase().replace(/\s+/g, '-');
      const existingCity = await prisma.city.findFirst({
        where: {
          countryId: uganda.id,
          slug,
        },
      });
      
      if (!existingCity) {
        await prisma.city.create({
          data: {
            countryId: uganda.id,
            name: cityName,
            slug,
            timezone: 'Africa/Kampala',
            isActive: true,
          },
        });
      } else {
        await prisma.city.update({
          where: { id: existingCity.id },
          data: { isActive: true },
        });
      }
    }
    console.log(`✅ Added ${ugandaCities.length} cities for Uganda`);
  }

  // Tanzania Cities
  const tanzania = otherCountries.find(c => c.code === 'TZA');
  if (tanzania) {
    const tanzaniaCities = [
      'Dar es Salaam',
      'Dodoma',
      'Mwanza',
      'Arusha',
      'Mbeya',
      'Morogoro',
      'Tanga',
      'Zanzibar',
      'Kigoma',
      'Mtwara',
    ];
    for (const cityName of tanzaniaCities) {
      const slug = cityName.toLowerCase().replace(/\s+/g, '-');
      const existingCity = await prisma.city.findFirst({
        where: {
          countryId: tanzania.id,
          slug,
        },
      });
      
      if (!existingCity) {
        await prisma.city.create({
          data: {
            countryId: tanzania.id,
            name: cityName,
            slug,
            timezone: 'Africa/Dar_es_Salaam',
            isActive: true,
          },
        });
      } else {
        await prisma.city.update({
          where: { id: existingCity.id },
          data: { isActive: true },
        });
      }
    }
    console.log(`✅ Added ${tanzaniaCities.length} cities for Tanzania`);
  }

  console.log('✅ Countries and cities seeding completed!');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding countries and cities:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

