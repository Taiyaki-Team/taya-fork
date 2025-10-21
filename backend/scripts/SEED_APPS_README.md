# Seed Apps to Your Database

## Overview
This script populates your Firestore database with all 98 free community apps from `community-plugins.json`.

## Prerequisites
- Your backend environment variables are configured (Firebase credentials)
- Your backend dependencies are installed

## How to Run

### Option 1: From backend directory
```bash
cd backend
python scripts/seed_apps.py
```

### Option 2: From project root
```bash
cd taya-fork
python backend/scripts/seed_apps.py
```

## What It Does
1. Reads all apps from `/community-plugins.json`
2. Connects to your Firestore database
3. Checks for existing apps (skips duplicates)
4. Adds new apps to the `apps` collection
5. Reports progress and summary

## Expected Output
```
Starting apps seeding process...
==================================================
Found 98 apps in community-plugins.json
Found 0 existing apps in database
✓ Added: Conversation Coach (conversation-coach)
✓ Added: Actionable Insights (actionable-insights)
...
==================================================
Seeding complete!
  Added: 98
  Skipped (already exist): 0
  Errors: 0
  Total in JSON: 98
==================================================
```

## After Seeding
Once the apps are seeded:
1. Restart your backend (if running)
2. Restart your Flutter app
3. Tap the puzzle piece icon 🧩 in the top-right
4. You'll see all 98 free apps organized by category!

## Troubleshooting
- **"Error connecting to database"**: Check your Firebase credentials
- **"Permission denied"**: Ensure your service account has Firestore write permissions
- **"Module not found"**: Make sure you're running from the correct directory

## Re-running the Script
Safe to run multiple times - it will skip apps that already exist in the database.

