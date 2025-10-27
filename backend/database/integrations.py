"""
Database functions for managing user integrations
"""
from datetime import datetime, timezone
from typing import Optional, List
from ._client import db
from models.integration import Integration, IntegrationStatus


def get_user_integrations(uid: str) -> List[Integration]:
    """Get all integrations for a user"""
    try:
        integrations_ref = db.collection('users').document(uid).collection('integrations')
        docs = integrations_ref.stream()
        
        integrations = []
        for doc in docs:
            data = doc.to_dict()
            data['id'] = doc.id
            data['user_id'] = uid
            integrations.append(Integration(**data))
        
        return integrations
    except Exception as e:
        print(f"Error getting user integrations: {e}")
        return []


def get_user_integration(uid: str, integration_id: str) -> Optional[Integration]:
    """Get a specific integration for a user"""
    try:
        doc_ref = db.collection('users').document(uid).collection('integrations').document(integration_id)
        doc = doc_ref.get()
        
        if doc.exists:
            data = doc.to_dict()
            data['id'] = doc.id
            data['user_id'] = uid
            return Integration(**data)
        
        return None
    except Exception as e:
        print(f"Error getting user integration: {e}")
        return None


def save_user_integration(uid: str, integration: Integration) -> bool:
    """Save or update a user's integration"""
    try:
        doc_ref = db.collection('users').document(uid).collection('integrations').document(integration.id)
        
        data = integration.model_dump(exclude={'user_id', 'id'})
        # Convert datetime to timestamp
        if data.get('connected_at'):
            data['connected_at'] = data['connected_at'].isoformat() if isinstance(data['connected_at'], datetime) else data['connected_at']
        if data.get('last_used_at'):
            data['last_used_at'] = data['last_used_at'].isoformat() if isinstance(data['last_used_at'], datetime) else data['last_used_at']
        
        doc_ref.set(data, merge=True)
        return True
    except Exception as e:
        print(f"Error saving user integration: {e}")
        return False


def delete_user_integration(uid: str, integration_id: str) -> bool:
    """Delete a user's integration"""
    try:
        doc_ref = db.collection('users').document(uid).collection('integrations').document(integration_id)
        doc_ref.delete()
        return True
    except Exception as e:
        print(f"Error deleting user integration: {e}")
        return False


def update_integration_last_used(uid: str, integration_id: str) -> bool:
    """Update the last_used_at timestamp for an integration"""
    try:
        doc_ref = db.collection('users').document(uid).collection('integrations').document(integration_id)
        doc_ref.update({'last_used_at': datetime.now(timezone.utc).isoformat()})
        return True
    except Exception as e:
        print(f"Error updating integration last_used: {e}")
        return False


