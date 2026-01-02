#!/bin/bash

# Script to fix hardcoded colors in Flutter files
# Phase 5: Replace Colors.grey[XX], Colors.white, Colors.black with theme-aware equivalents

FILE=$1

if [ -z "$FILE" ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

echo "Fixing hardcoded colors in: $FILE"

# Replace Colors.grey[XX] with context.greyXX
sed -i '' 's/Colors\.grey\[50\]/context.grey50/g' "$FILE"
sed -i '' 's/Colors\.grey\[100\]/context.grey100/g' "$FILE"
sed -i '' 's/Colors\.grey\[200\]/context.grey200/g' "$FILE"
sed -i '' 's/Colors\.grey\[300\]/context.grey300/g' "$FILE"
sed -i '' 's/Colors\.grey\[400\]/context.grey400/g' "$FILE"
sed -i '' 's/Colors\.grey\[500\]/context.grey500/g' "$FILE"
sed -i '' 's/Colors\.grey\[600\]/context.grey600/g' "$FILE"

# Replace Colors.grey[XX]! with context.greyXX (for null safety)
sed -i '' 's/Colors\.grey\[50\]!/context.grey50/g' "$FILE"
sed -i '' 's/Colors\.grey\[100\]!/context.grey100/g' "$FILE"
sed -i '' 's/Colors\.grey\[200\]!/context.grey200/g' "$FILE"
sed -i '' 's/Colors\.grey\[300\]!/context.grey300/g' "$FILE"
sed -i '' 's/Colors\.grey\[400\]!/context.grey400/g' "$FILE"
sed -i '' 's/Colors\.grey\[500\]!/context.grey500/g' "$FILE"
sed -i '' 's/Colors\.grey\[600\]!/context.grey600/g' "$FILE"

# Replace standalone Colors.grey with context.grey400 (common default)
sed -i '' 's/Colors\.grey,/context.grey400,/g' "$FILE"
sed -i '' 's/Colors\.grey)/context.grey400)/g' "$FILE"

# Replace Colors.red with context.errorColor (but NOT Colors.red[XXX] - those are specific shades)
sed -i '' 's/Colors\.red,/context.errorColor,/g' "$FILE"
sed -i '' 's/Colors\.red)/context.errorColor)/g' "$FILE"
sed -i '' 's/: Colors\.red$/: context.errorColor/g' "$FILE"

echo "✓ Replaced all hardcoded grey colors and red"
echo "Note: Colors.white, Colors.black, Colors.amber, and specific shades (red[600], etc.) need manual review"
echo "Done!"

