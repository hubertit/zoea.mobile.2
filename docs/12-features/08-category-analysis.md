# Category Analysis: Attractions, Experiences, Hiking, and Tours

## Overview

This document explains the differences between four key concepts in the Zoea platform: **Attractions**, **Experiences**, **Hiking**, and **Tours**.

---

## 1. **Attractions** 🏛️

### Definition
- **Type**: A `listing_type` enum value (`attraction`)
- **Category**: A top-level category with slug `'attractions'`
- **Nature**: Static places, landmarks, or points of interest that people visit

### Characteristics
- **Entity Model**: `Listing` (with `type = 'attraction'`)
- **Category Slug**: `'attractions'`
- **Icon**: `'attractions'`
- **Sort Order**: 7
- **Purpose**: Represents fixed locations like monuments, landmarks, viewpoints, historical sites

### Examples
- Museums
- Monuments
- Viewpoints
- Historical sites
- Cultural landmarks
- Natural landmarks
- Statues & Memorials
- Architectural sites

### Current Subcategories (as of December 2024)
1. **Monuments** (`monuments`)
2. **Viewpoints** (`viewpoints`)
3. **Historical Sites** (`historical-sites`)
4. **Cultural Landmarks** (`cultural-landmarks`)
5. **Natural Landmarks** (`natural-landmarks`)
6. **Statues & Memorials** (`statues-memorials`)
7. **Architectural Sites** (`architectural-sites`)
8. **Museums** (`museums`)

### Key Points
- Attractions are **static locations** - they don't move or have schedules
- They are **Listings** with type `attraction`
- They belong to the **Attractions category**

---

## 2. **Experiences** 🎯

### Definition
- **Type**: A top-level **Category** (not a listing type)
- **Category Slug**: `'experiences'`
- **Nature**: A broad umbrella category for activities, adventures, and immersive activities

### Characteristics
- **Entity Model**: Can contain both `Listing` and `Tour` entities
- **Category Slug**: `'experiences'`
- **Icon**: `'explore'`
- **Sort Order**: 3
- **Purpose**: General category for various activities and experiences

### Examples
- Tour packages
- Adventure activities
- Cultural experiences
- Workshops
- Classes
- Guided activities
- Hiking
- National Parks

### Current Subcategories (as of December 2024)
1. **Adventure** (`adventure`)
2. **Cultural** (`cultural`)
3. **Nature** (`nature`)
4. **Water** (`water`)
5. **National Parks** (`national-parks`)
6. **CarFree Zone** (`carfree-zone`)
7. **Cinema** (`cinema`)
8. **Hiking** (`hiking`)
9. **Tour and Travel** (`tour-and-travel`)

### Key Points
- Experiences is a **parent category** that can contain multiple types of activities
- In V1 migration, "Tour and Travel" was mapped to `'experiences'`
- It's a **broader category** that encompasses tours, activities, and other experiences
- Both listings and tours can belong to this category

---

## 3. **Hiking** ⛰️

### Definition
- **Type**: Can be both a **Category** AND a **Tour Type**
- **Category Slug**: `'hiking'`
- **Nature**: Specifically for hiking-related activities

### Characteristics
- **As a Category**:
  - Category Slug: `'hiking'`
  - Icon: `'terrain'`
  - Sort Order: 12
  - Can contain listings or tours related to hiking

- **As a Tour Type**:
  - Tour `type` field can be `'hiking'`
  - Part of tour type enum: `['wildlife', 'cultural', 'adventure', 'hiking', 'city', 'beach', 'safari']`

### Examples
- Mountain hiking tours
- Trail hiking experiences
- Guided hiking activities
- Hiking equipment rentals
- Hiking event listings

### Key Points
- Hiking can be:
  1. A **category** (for organizing hiking-related content)
  2. A **tour type** (for categorizing tours that involve hiking)
- This dual nature allows flexibility in how hiking content is organized

---

## 4. **Tours** 🗺️

### Definition
- **Type**: A separate **Entity Model** (not just a category)
- **Model**: `Tour` (distinct from `Listing`)
- **Nature**: Structured tour packages with schedules, itineraries, and booking capabilities

### Characteristics
- **Entity Model**: `Tour` (separate table/model)
- **Has Category**: Tours can have a `categoryId` linking to Category model
- **Has Type**: Tours have a `type` field with values: `'wildlife'`, `'cultural'`, `'adventure'`, `'hiking'`, `'city'`, `'beach'`, `'safari'`
- **Features**:
  - Schedules (`TourSchedule`)
  - Itineraries (JSON)
  - Group sizes (min/max)
  - Duration (days/hours)
  - Pricing per person
  - Requirements
  - Includes/Excludes
  - Difficulty levels
  - Languages offered

### Examples
- Gorilla trekking tours
- City sightseeing tours
- Cultural heritage tours
- Wildlife safari tours
- Hiking adventure tours
- Beach excursion tours

### Key Points
- Tours are a **separate entity type** with their own model
- Tours are **more structured** than listings - they have schedules, itineraries, and booking systems
- Tours can belong to various categories (including Experiences, Hiking, etc.)
- Tours have a `type` field that further categorizes them (hiking, wildlife, cultural, etc.)
- Tours are operated by `TourOperatorProfile`

---

## Key Differences Summary

| Aspect | Attractions | Experiences | Hiking | Tours |
|--------|------------|-------------|--------|-------|
| **Entity Type** | Listing (`type='attraction'`) | Category | Category OR Tour Type | Separate Entity (`Tour`) |
| **Nature** | Static locations | Broad category | Activity type | Structured packages |
| **Has Schedules** | ❌ No | ❌ No | ❌ No | ✅ Yes |
| **Has Itineraries** | ❌ No | ❌ No | ❌ No | ✅ Yes |
| **Booking System** | Basic listing | Varies | Varies | Advanced (with schedules) |
| **Flexibility** | Fixed location | Flexible | Can be category or type | Highly structured |

---

## Relationships

### How They Relate

1. **Tours can be Hiking Tours**:
   - A `Tour` can have `type = 'hiking'`
   - A `Tour` can have `categoryId` pointing to Hiking category

2. **Tours can be Experiences**:
   - A `Tour` can have `categoryId` pointing to Experiences category
   - Experiences is a parent category that can contain tours

3. **Attractions are Separate**:
   - Attractions are `Listing` entities with `type = 'attraction'`
   - They belong to the Attractions category
   - They are distinct from tours

4. **Hiking as Category vs Type**:
   - Hiking can be a **category** (for organizing content)
   - Hiking can be a **tour type** (for categorizing tours)
   - A hiking tour could have both: `categoryId = hiking_category` AND `type = 'hiking'`

---

## Recommendations

### Potential Overlap Issues

1. **Hiking Tours** might fall into multiple categories:
   - Could be in **Hiking category** (activity-based)
   - Could be in **Experiences category** (broader experience)
   - Could have `type = 'hiking'` (tour type classification)

2. **Tours vs Experiences**:
   - Tours are a specific entity type
   - Experiences is a category that can contain tours
   - Some tours might be better categorized under Experiences rather than having their own category

### Current Category Structure (as of December 2024)

```
Attractions (Parent Category)
├── Monuments
├── Viewpoints
├── Historical Sites
├── Cultural Landmarks
├── Natural Landmarks
├── Statues & Memorials
├── Architectural Sites
└── Museums

Experiences (Parent Category)
├── Adventure
├── Cultural
├── Nature
├── Water
├── National Parks
├── CarFree Zone
├── Cinema
├── Hiking
└── Tour and Travel

Top-Level Categories
├── Accommodation
├── Attractions (with subcategories)
├── Dining
├── Events
├── Experiences (with subcategories)
├── Kids
├── Nightlife
├── Real Estate
├── Religious Institutions
├── Services
├── Shopping
├── Sports
└── Transport
```

---

## Database Schema Reference

### Listing Model
```prisma
model Listing {
  type       listing_type?  // Can be 'attraction'
  categoryId String?        // Links to Category (e.g., 'attractions')
  // ... other fields
}
```

### Tour Model
```prisma
model Tour {
  type       String?        // Can be 'hiking', 'wildlife', 'cultural', etc.
  categoryId String?        // Links to Category (e.g., 'experiences', 'hiking')
  // ... other fields (schedules, itineraries, etc.)
}
```

### Category Model
```prisma
model Category {
  slug       String         // 'attractions', 'experiences', 'hiking', etc.
  parentId   String?        // For subcategories
  // ... other fields
}
```

---

## Conclusion

- **Attractions**: Static places/landmarks (Listings with type='attraction')
- **Experiences**: Broad parent category for activities and tours
- **Hiking**: Can be both a category and a tour type
- **Tours**: Separate structured entity with schedules and itineraries

The key insight is that **Tours** is a separate entity type (like Listings), while **Attractions**, **Experiences**, and **Hiking** are categories that can organize both Listings and Tours.

