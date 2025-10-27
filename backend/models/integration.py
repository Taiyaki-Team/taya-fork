from datetime import datetime
from typing import List, Optional, Dict, Any
from pydantic import BaseModel
from enum import Enum


class IntegrationStatus(str, Enum):
    not_connected = 'not_connected'
    connected = 'connected'
    error = 'error'


class Integration(BaseModel):
    id: str
    user_id: str
    status: IntegrationStatus
    config: Optional[Dict[str, Any]] = None
    connected_at: Optional[datetime] = None
    last_used_at: Optional[datetime] = None
    error_message: Optional[str] = None


class IntegrationConnection(BaseModel):
    server_id: str
    config: Optional[Dict[str, Any]] = None


class IntegrationToolCall(BaseModel):
    server_id: str
    tool_name: str
    arguments: Dict[str, Any]


class IntegrationToolResult(BaseModel):
    success: bool
    result: Optional[Any] = None
    error: Optional[str] = None


