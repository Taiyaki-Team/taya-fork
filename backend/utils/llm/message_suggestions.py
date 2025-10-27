"""
Generate contextual message suggestions based on conversation history
"""
from typing import List
from pydantic import BaseModel, Field

from models.chat import Message
from utils.llm.clients import llm_mini


class MessageSuggestions(BaseModel):
    """Model for AI-generated message suggestions"""
    suggestions: List[str] = Field(
        description='List of 3 contextual message suggestions',
        min_items=1,
        max_items=3
    )


def generate_message_suggestions(messages: List[Message], max_messages: int = 5) -> List[str]:
    """
    Generate contextual message suggestions based on recent conversation history
    
    Args:
        messages: List of recent messages in the conversation
        max_messages: Maximum number of recent messages to consider for context
        
    Returns:
        List of 3 suggested messages the user might want to send
    """
    if not messages:
        # Default suggestions if no conversation history
        return [
            "What did I do yesterday?",
            "What could I do differently today?", 
            "Can you teach me something new?"
        ]
    
    # Get recent messages for context (last N messages)
    recent_messages = messages[-max_messages:] if len(messages) > max_messages else messages
    
    # Build conversation context
    conversation_context = "\n".join([
        f"{msg.sender.value}: {msg.text[:200]}"  # Limit text length for token efficiency
        for msg in recent_messages
        if msg.text  # Only include messages with text
    ])
    
    if not conversation_context.strip():
        # Fallback to defaults if no valid context
        return [
            "What did I do yesterday?",
            "What could I do differently today?",
            "Can you teach me something new?"
        ]
    
    prompt = f"""You are a helpful assistant that generates contextual follow-up questions for users in a conversation.

Based on the recent conversation below, generate 3 short, natural follow-up questions or prompts that the user might want to ask next.

Guidelines:
- Each suggestion should be 3-10 words maximum
- Make them conversational and relevant to the recent discussion
- Focus on continuing the conversation naturally
- Vary the types: ask for clarification, deeper insights, related topics, or actionable next steps
- Don't repeat what was already discussed
- Make them feel like natural continuations

Recent conversation:
{conversation_context}

Generate 3 contextual follow-up suggestions that would help continue this conversation meaningfully."""

    try:
        with_parser = llm_mini.with_structured_output(MessageSuggestions)
        result = with_parser.invoke(prompt)
        
        # Ensure we have valid suggestions
        suggestions = result.suggestions if result.suggestions else []
        
        # Filter out empty or very long suggestions
        valid_suggestions = [
            s.strip() for s in suggestions 
            if s and len(s.strip()) > 0 and len(s.strip()) < 100
        ]
        
        # Return up to 3 suggestions, fall back to defaults if needed
        if len(valid_suggestions) >= 1:
            return valid_suggestions[:3]
        else:
            return [
                "Tell me more about that",
                "What else should I know?",
                "How can I apply this?"
            ]
            
    except Exception as e:
        print(f"Error generating message suggestions: {e}")
        # Fallback to sensible defaults on error
        return [
            "Tell me more about that",
            "What else should I know?",
            "How can I apply this?"
        ]

