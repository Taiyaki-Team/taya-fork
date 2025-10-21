"""
Script to seed the Firestore database with apps from community-plugins.json
Run this to populate your database with all the free community apps.
"""
import json
import sys
from pathlib import Path

# Add parent directory to path to import database modules
sys.path.append(str(Path(__file__).parent.parent))

from database.apps import add_app_to_db
from database._client import db

def seed_apps_from_json():
    """Load apps from community-plugins.json and add them to Firestore"""
    
    # Path to community-plugins.json
    json_path = Path(__file__).parent.parent.parent / 'community-plugins.json'
    
    if not json_path.exists():
        print(f"Error: {json_path} not found!")
        return
    
    # Load the JSON file
    with open(json_path, 'r') as f:
        apps_data = json.load(f)
    
    print(f"Found {len(apps_data)} apps in community-plugins.json")
    
    # Get existing app IDs to avoid duplicates
    apps_collection = 'apps'
    existing_apps = db.collection(apps_collection).stream()
    existing_ids = {doc.id for doc in existing_apps}
    
    print(f"Found {len(existing_ids)} existing apps in database")
    
    added_count = 0
    skipped_count = 0
    error_count = 0
    
    for app in apps_data:
        app_id = app.get('id')
        
        if not app_id:
            print(f"Warning: App missing ID, skipping: {app.get('name', 'Unknown')}")
            error_count += 1
            continue
        
        # Skip if already exists
        if app_id in existing_ids:
            print(f"Skipping existing app: {app.get('name')} ({app_id})")
            skipped_count += 1
            continue
        
        try:
            # Ensure all required fields are present with defaults
            app_data = {
                'id': app_id,
                'name': app.get('name', 'Untitled App'),
                'author': app.get('author', 'Community'),
                'description': app.get('description', ''),
                'image': app.get('image', ''),
                'capabilities': app.get('capabilities', []),
                'memory_prompt': app.get('memory_prompt'),
                'chat_prompt': app.get('chat_prompt'),
                'category': app.get('category', 'other'),
                'approved': app.get('approved', True),
                'deleted': app.get('deleted', False),
                'private': app.get('private', False),
                'is_paid': app.get('is_paid', False),
                'price': app.get('price'),
                'payment_plan': app.get('payment_plan'),
                'external_integration': app.get('external_integration'),
                'proactive_notification': app.get('proactive_notification'),
            }
            
            # Remove None values
            app_data = {k: v for k, v in app_data.items() if v is not None}
            
            # Add to database
            add_app_to_db(app_data)
            print(f"✓ Added: {app_data['name']} ({app_id})")
            added_count += 1
            
        except Exception as e:
            print(f"✗ Error adding app {app.get('name', 'Unknown')} ({app_id}): {e}")
            error_count += 1
    
    print("\n" + "="*50)
    print(f"Seeding complete!")
    print(f"  Added: {added_count}")
    print(f"  Skipped (already exist): {skipped_count}")
    print(f"  Errors: {error_count}")
    print(f"  Total in JSON: {len(apps_data)}")
    print("="*50)

if __name__ == "__main__":
    print("Starting apps seeding process...")
    print("="*50)
    seed_apps_from_json()

