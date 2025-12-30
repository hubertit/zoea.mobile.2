# Failed Users Analysis - 117 Remaining Users

**Date:** December 27, 2025  
**Status:** Analysis in Progress

## Overview

After implementing comprehensive data cleaning, **117 users** (2.6%) remain unmigrated out of 4,564 total users.

## Analysis Format

Each user is shown as:
```
ID|EPNC|Email|Phone|Name
```

Where:
- **E** = Has Email, **P** = Has Phone, **N** = Has Name, **C** = Has Contact
- **-** = Missing that field, **X** = No contact info at all

## Failed Users List

(To be populated with detailed analysis)

## Failure Patterns

### Pattern 1: Users with Contact Info
- Users that have email OR phone but still failed
- Likely causes: Duplicate constraints, encoding issues, database errors

### Pattern 2: Users without Contact Info
- Users with no email AND no phone
- Should have placeholder phone generated
- Likely causes: Database errors during creation

### Pattern 3: Encoding Issues
- Users with null bytes or invalid UTF-8 characters
- Should be sanitized by data cleaner
- Likely causes: Severe corruption, binary data in text fields

## Recommendations

1. **Review each failed user individually**
2. **Check for specific error messages**
3. **Identify fixable patterns**
4. **Create targeted migration script**
5. **Manual review for unfixable cases**

---

**Next Steps:** Detailed analysis of each failed user to identify fixable issues.

