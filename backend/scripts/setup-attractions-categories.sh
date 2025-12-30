#!/bin/bash

# Script to move Museums back to Attractions and create subcategories
# Subcategories: Monuments, Viewpoints, Historical Sites, Cultural Landmarks, Natural Landmarks, Statues/Memorials, Architectural Sites

API_BASE_URL="https://zoea-africa.qtsoftwareltd.com/api"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔐 Getting admin token...${NC}"
TOKEN=$(curl -s -X POST ${API_BASE_URL}/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"admin@zoea.africa","password":"Pass12"}' | jq -r '.accessToken')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo -e "${RED}❌ Failed to get token${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Token obtained${NC}"
echo ""

# Step 1: Find Attractions category
echo -e "${YELLOW}📁 Finding Attractions category...${NC}"
ATTRACTIONS_ID=$(curl -s "${API_BASE_URL}/categories" | jq -r '.[] | select(.slug == "attractions") | .id')

if [ -z "$ATTRACTIONS_ID" ] || [ "$ATTRACTIONS_ID" == "null" ]; then
  echo -e "${RED}❌ Attractions category not found${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Attractions ID: ${ATTRACTIONS_ID}${NC}"
echo ""

# Step 2: Move Museums back to Attractions
echo -e "${YELLOW}🔄 Moving Museums back to Attractions...${NC}"
MUSEUMS_ID=$(curl -s "${API_BASE_URL}/categories" | jq -r '.[] | select(.slug == "museums") | .id')

if [ -n "$MUSEUMS_ID" ] && [ "$MUSEUMS_ID" != "null" ]; then
  echo -e "  Found Museums: ${MUSEUMS_ID}"
  
  # Check current parent
  CURRENT_PARENT=$(curl -s "${API_BASE_URL}/categories/${MUSEUMS_ID}" | jq -r '.parentId // "null"')
  if [ "$CURRENT_PARENT" == "$ATTRACTIONS_ID" ]; then
    echo -e "  ${YELLOW}ℹ️  Already under Attractions. Skipping.${NC}"
  else
    RESPONSE=$(curl -s -X PUT "${API_BASE_URL}/categories/${MUSEUMS_ID}" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${TOKEN}" \
      -d "{\"parentId\": \"${ATTRACTIONS_ID}\"}")
    
    if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
      NAME=$(echo "$RESPONSE" | jq -r '.name')
      echo -e "  ${GREEN}✅ Successfully moved '${NAME}' to Attractions${NC}"
    else
      echo -e "  ${RED}❌ Failed: ${RESPONSE}${NC}"
    fi
  fi
else
  echo -e "  ${YELLOW}⚠️  Museums category not found${NC}"
fi
echo ""

# Step 3: Create subcategories under Attractions
echo -e "${YELLOW}📝 Creating subcategories under Attractions...${NC}"

# Define subcategories (name|slug|icon|sortOrder)
create_subcategory() {
  local name=$1
  local slug=$2
  local icon=$3
  local sort_order=$4
  
  echo -e "  Checking '${name}' (${slug})..."
  
  # Check if category already exists
  EXISTING_ID=$(curl -s "${API_BASE_URL}/categories" | jq -r ".[] | select(.slug == \"${slug}\") | .id")
  
  if [ -n "$EXISTING_ID" ] && [ "$EXISTING_ID" != "null" ]; then
    echo -e "    ${YELLOW}ℹ️  Category already exists: ${EXISTING_ID}${NC}"
    
    # Check if it's already under Attractions
    CURRENT_PARENT=$(curl -s "${API_BASE_URL}/categories/${EXISTING_ID}" | jq -r '.parentId // "null"')
    if [ "$CURRENT_PARENT" != "$ATTRACTIONS_ID" ]; then
      echo -e "    ⏳ Moving to Attractions..."
      RESPONSE=$(curl -s -X PUT "${API_BASE_URL}/categories/${EXISTING_ID}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${TOKEN}" \
        -d "{\"parentId\": \"${ATTRACTIONS_ID}\"}")
      
      if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
        echo -e "    ${GREEN}✅ Moved to Attractions${NC}"
      else
        echo -e "    ${RED}❌ Failed to move: ${RESPONSE}${NC}"
      fi
    else
      echo -e "    ${GREEN}✅ Already under Attractions${NC}"
    fi
  else
    echo -e "    ⏳ Creating new category..."
    RESPONSE=$(curl -s -X POST "${API_BASE_URL}/categories" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${TOKEN}" \
      -d "{
        \"name\": \"${name}\",
        \"slug\": \"${slug}\",
        \"parentId\": \"${ATTRACTIONS_ID}\",
        \"icon\": \"${icon}\",
        \"sortOrder\": ${sort_order},
        \"isActive\": true
      }")
    
    if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
      CREATED_NAME=$(echo "$RESPONSE" | jq -r '.name')
      echo -e "    ${GREEN}✅ Created '${CREATED_NAME}'${NC}"
    else
      echo -e "    ${RED}❌ Failed to create: ${RESPONSE}${NC}"
    fi
  fi
  echo ""
}

# Create all subcategories
create_subcategory "Monuments" "monuments" "landmark" 1
create_subcategory "Viewpoints" "viewpoints" "visibility" 2
create_subcategory "Historical Sites" "historical-sites" "history_edu" 3
create_subcategory "Cultural Landmarks" "cultural-landmarks" "account_balance" 4
create_subcategory "Natural Landmarks" "natural-landmarks" "landscape" 5
create_subcategory "Statues & Memorials" "statues-memorials" "monument" 6
create_subcategory "Architectural Sites" "architectural-sites" "architecture" 7

# Step 4: Verify the changes
echo -e "${YELLOW}📋 Verifying changes...${NC}"
ATTRACTIONS_WITH_CHILDREN=$(curl -s "${API_BASE_URL}/categories/${ATTRACTIONS_ID}")
CHILDREN_COUNT=$(echo "$ATTRACTIONS_WITH_CHILDREN" | jq '.children | length')
echo -e "${GREEN}✅ Attractions now has ${CHILDREN_COUNT} subcategories${NC}"

echo ""
echo -e "${YELLOW}Subcategories of Attractions:${NC}"
echo "$ATTRACTIONS_WITH_CHILDREN" | jq -r '.children[] | "  • \(.name) (\(.slug))"' | sort

echo ""
echo -e "${GREEN}✅ Attractions category setup complete!${NC}"
