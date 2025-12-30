#!/bin/bash

# Script to move categories under Experiences using the API
# Moves: Hiking, National Parks, Museums

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

echo -e "${YELLOW}📁 Finding Experiences category...${NC}"
EXPERIENCES_ID=$(curl -s "${API_BASE_URL}/categories" | jq -r '.[] | select(.slug == "experiences") | .id')

if [ -z "$EXPERIENCES_ID" ] || [ "$EXPERIENCES_ID" == "null" ]; then
  echo -e "${RED}❌ Experiences category not found${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Experiences ID: ${EXPERIENCES_ID}${NC}"
echo ""

# Categories to move
categories=("hiking" "national-parks" "museums")

for slug in "${categories[@]}"; do
  echo -e "${YELLOW}🔍 Finding '${slug}' category...${NC}"
  
  CATEGORY_ID=$(curl -s "${API_BASE_URL}/categories" | jq -r ".[] | select(.slug == \"${slug}\") | .id")
  
  if [ -n "$CATEGORY_ID" ] && [ "$CATEGORY_ID" != "null" ]; then
    echo -e "  ${GREEN}✅ Found: ${CATEGORY_ID}${NC}"
    
    # Check current parent
    CURRENT_PARENT=$(curl -s "${API_BASE_URL}/categories/${CATEGORY_ID}" | jq -r '.parentId // "null"')
    if [ "$CURRENT_PARENT" == "$EXPERIENCES_ID" ]; then
      echo -e "  ${YELLOW}ℹ️  Already a subcategory of Experiences. Skipping.${NC}"
    else
      echo -e "  ${YELLOW}⏳ Moving under Experiences...${NC}"
      
      RESPONSE=$(curl -s -X PUT "${API_BASE_URL}/categories/${CATEGORY_ID}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${TOKEN}" \
        -d "{\"parentId\": \"${EXPERIENCES_ID}\"}")
      
      if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
        NAME=$(echo "$RESPONSE" | jq -r '.name')
        echo -e "  ${GREEN}✅ Successfully moved '${NAME}'${NC}"
      else
        echo -e "  ${RED}❌ Failed: ${RESPONSE}${NC}"
      fi
    fi
  else
    echo -e "  ${YELLOW}⚠️  Category '${slug}' not found${NC}"
  fi
  echo ""
done

echo -e "${GREEN}✅ Category reorganization complete!${NC}"

# Verify the changes
echo ""
echo -e "${YELLOW}📋 Verifying changes...${NC}"
EXPERIENCES_WITH_CHILDREN=$(curl -s "${API_BASE_URL}/categories/${EXPERIENCES_ID}")
CHILDREN_COUNT=$(echo "$EXPERIENCES_WITH_CHILDREN" | jq '.children | length')
echo -e "${GREEN}✅ Experiences now has ${CHILDREN_COUNT} subcategories${NC}"

echo ""
echo -e "${YELLOW}Subcategories of Experiences:${NC}"
echo "$EXPERIENCES_WITH_CHILDREN" | jq -r '.children[] | "  • \(.name) (\(.slug))"'

