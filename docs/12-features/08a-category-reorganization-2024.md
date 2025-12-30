# Category Reorganization - December 2024

## Overview

This document details the category reorganization that took place in December 2024, moving categories to better reflect their nature and purpose.

## Changes Made

### 1. Experiences Category Reorganization

**Date**: December 30, 2024

**Action**: Moved the following categories under "Experiences":
- **Hiking** - Moved from top-level to subcategory of Experiences
- **National Parks** - Moved from top-level to subcategory of Experiences
- **Museums** - Initially moved to Experiences, then moved to Attractions (see below)

**Rationale**: 
- Hiking is an activity/experience, not a static location
- National Parks offer various experiences (hiking, wildlife viewing, etc.)
- These align better with the "Experiences" category which represents activities and things to do

### 2. Attractions Category Setup

**Date**: December 30, 2024

**Action**: 
1. Moved **Museums** from Experiences to Attractions
2. Created 7 new subcategories under Attractions:
   - Monuments
   - Viewpoints
   - Historical Sites
   - Cultural Landmarks
   - Natural Landmarks
   - Statues & Memorials
   - Architectural Sites

**Rationale**:
- Museums are static locations (places you visit), not activities
- Attractions should contain all static landmarks and points of interest
- The new subcategories provide better organization for different types of attractions

## Final Category Structure

### Attractions (Parent Category)
- **Purpose**: Static places, landmarks, and points of interest
- **Subcategories**:
  1. Monuments
  2. Viewpoints
  3. Historical Sites
  4. Cultural Landmarks
  5. Natural Landmarks
  6. Statues & Memorials
  7. Architectural Sites
  8. Museums

### Experiences (Parent Category)
- **Purpose**: Activities, adventures, and things to do
- **Subcategories**:
  1. Adventure
  2. Cultural
  3. Nature
  4. Water
  5. National Parks
  6. CarFree Zone
  7. Cinema
  8. Hiking
  9. Tour and Travel

## Scripts Used

1. **move-categories-api.sh** - API-based script to move categories (recommended)
2. **setup-attractions-categories.sh** - Script to set up Attractions subcategories
3. **move-categories-to-experiences.ts** - Database-based script (legacy, for reference)

## API Endpoints

- `PUT /api/categories/:id` - Update category (including `parentId`)
- `POST /api/categories` - Create new category
- `GET /api/categories` - Get all categories with children

## Key Distinction

- **Attractions** = Static places/landmarks (places you visit)
- **Experiences** = Activities/things you do (activities you participate in)

This distinction helps users better understand and navigate the platform's content.

