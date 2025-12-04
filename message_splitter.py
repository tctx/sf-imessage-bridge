#!/usr/bin/env python3
"""
Message Splitter - Intelligent text splitting for natural iMessage conversations

This utility helps split AI-generated responses into natural message bubbles
that mimic how humans actually text. Can be used by the backend before sending
messages to the bridge.

Key principles:
- NEVER break mid-sentence
- Group by complete thoughts (2-3 sentences max)
- Break after questions
- Break before topic changes
- Use 160 chars per bubble as a guideline, not a hard rule
"""

import re
from typing import List


def split_into_natural_messages(text: str, max_chars: int = 160) -> List[str]:
    """
    Split a long text into natural message bubbles.
    
    Args:
        text: The full text to split
        max_chars: Guideline for max characters per bubble (not a hard limit)
    
    Returns:
        List of message strings that feel natural
    
    Examples:
        >>> split_into_natural_messages("Great! I can help you with that. Our most popular item is the vanilla latte which comes in three sizes. Would you like to hear about our specials?")
        [
            "Great! I can help you with that.",
            "Our most popular item is the vanilla latte which comes in three sizes.",
            "Would you like to hear about our specials?"
        ]
    """
    if not text or not text.strip():
        return []
    
    text = text.strip()
    
    # If text is short enough, return as-is
    if len(text) <= max_chars:
        return [text]
    
    # Split into sentences
    sentences = _split_into_sentences(text)
    
    # Group sentences into natural message bubbles
    messages = []
    current_bubble = ""
    
    for sentence in sentences:
        # Clean up the sentence
        sentence = sentence.strip()
        if not sentence:
            continue
        
        # Check if adding this sentence would exceed max_chars
        would_be_length = len(current_bubble) + len(sentence) + (1 if current_bubble else 0)
        
        # Decision logic:
        # 1. If current bubble is empty, start with this sentence
        # 2. If adding wouldn't exceed max by much, add it
        # 3. If sentence ends with question mark, always break after it
        # 4. If current bubble + sentence is reasonable, group them
        
        if not current_bubble:
            # Start new bubble
            current_bubble = sentence
            # If it's a question or short exclamation, send it alone
            if _is_standalone_sentence(sentence):
                messages.append(current_bubble)
                current_bubble = ""
        elif would_be_length <= max_chars:
            # Add to current bubble
            current_bubble += " " + sentence
            # If this is a question, break after it
            if sentence.endswith("?"):
                messages.append(current_bubble)
                current_bubble = ""
        elif len(sentence) > max_chars * 1.5:
            # Sentence itself is too long - break it carefully
            # First, finish current bubble if any
            if current_bubble:
                messages.append(current_bubble)
                current_bubble = ""
            # Then split the long sentence (at natural points if possible)
            long_parts = _split_long_sentence(sentence, max_chars)
            messages.extend(long_parts)
        else:
            # Current bubble + sentence would be too long
            # Finish current bubble and start new one
            if current_bubble:
                messages.append(current_bubble)
            current_bubble = sentence
            # If it's a standalone sentence, send it
            if _is_standalone_sentence(sentence):
                messages.append(current_bubble)
                current_bubble = ""
    
    # Don't forget the last bubble
    if current_bubble:
        messages.append(current_bubble)
    
    return messages


def _split_into_sentences(text: str) -> List[str]:
    """
    Split text into sentences, handling common edge cases.
    
    Handles:
    - Regular sentences ending with . ! ?
    - Abbreviations (Dr., Mr., etc.)
    - URLs
    - Numbers (3.14, etc.)
    """
    # Simple but effective sentence splitting
    # This regex splits on . ! ? followed by space and capital letter
    # while trying to avoid common abbreviations
    
    # Replace common abbreviations temporarily
    text = text.replace("Mr.", "Mr<DOT>")
    text = text.replace("Mrs.", "Mrs<DOT>")
    text = text.replace("Dr.", "Dr<DOT>")
    text = text.replace("Ms.", "Ms<DOT>")
    text = text.replace("vs.", "vs<DOT>")
    
    # Split on sentence endings
    pattern = r'([.!?]+[\s]+)'
    parts = re.split(pattern, text)
    
    # Recombine sentences with their punctuation
    sentences = []
    for i in range(0, len(parts), 2):
        sentence = parts[i]
        if i + 1 < len(parts):
            sentence += parts[i + 1].rstrip()
        sentence = sentence.replace("<DOT>", ".")
        if sentence.strip():
            sentences.append(sentence.strip())
    
    return sentences


def _is_standalone_sentence(sentence: str) -> bool:
    """
    Check if a sentence should be sent alone (not grouped).
    
    Returns True for:
    - Questions
    - Short exclamations
    - Greetings
    """
    sentence = sentence.strip()
    
    # Questions always standalone
    if sentence.endswith("?"):
        return True
    
    # Short exclamations (under 30 chars ending with !)
    if sentence.endswith("!") and len(sentence) < 30:
        return True
    
    # Common short phrases that should be alone
    short_phrases = ["ok!", "great!", "awesome!", "perfect!", "got it!", "sounds good!"]
    if sentence.lower() in short_phrases:
        return True
    
    return False


def _split_long_sentence(sentence: str, max_chars: int) -> List[str]:
    """
    Split a sentence that's too long, trying to break at natural points.
    
    Prefers to break at:
    - Commas
    - Conjunctions (and, but, or)
    - After parentheses
    """
    # If it fits, return as-is
    if len(sentence) <= max_chars:
        return [sentence]
    
    # Try to split at commas first
    if "," in sentence:
        parts = []
        current = ""
        for chunk in sentence.split(","):
            if not current:
                current = chunk + ","
            elif len(current) + len(chunk) + 1 < max_chars:
                current += chunk + ","
            else:
                parts.append(current.strip().rstrip(","))
                current = chunk + ","
        if current:
            parts.append(current.strip().rstrip(","))
        return parts
    
    # Fall back to word-based splitting
    words = sentence.split()
    parts = []
    current = ""
    
    for word in words:
        if not current:
            current = word
        elif len(current) + len(word) + 1 <= max_chars:
            current += " " + word
        else:
            parts.append(current)
            current = word
    
    if current:
        parts.append(current)
    
    return parts


def format_for_bridge(messages: List[str], 
                     base_typing_speed: float = 55.0,
                     first_delay: tuple = (0.1, 0.3),
                     follow_delay: tuple = (0.3, 0.6)) -> List[dict]:
    """
    Format split messages for the bridge's expected format.
    
    Args:
        messages: List of message strings
        base_typing_speed: Characters per second for typing simulation
        first_delay: (min, max) delay before first message in seconds
        follow_delay: (min, max) delay before follow-up messages in seconds
    
    Returns:
        List of message dicts ready for bridge consumption
    
    Example:
        >>> messages = split_into_natural_messages("Hey! How are you? I'm doing great.")
        >>> format_for_bridge(messages)
        [
            {
                "text": "Hey! How are you?",
                "typing_delay": None,  # Let bridge calculate
                "delay_before": None   # Let bridge calculate
            },
            ...
        ]
    """
    formatted = []
    
    for i, text in enumerate(messages):
        formatted.append({
            "text": text,
            # Let bridge calculate timing automatically
            # (it has smarter logic now)
            "typing_delay": None,
            "delay_before": None
        })
    
    return formatted


# Example usage / testing
if __name__ == "__main__":
    # Test cases
    test_texts = [
        "Hey! How are you?",
        "Great! I can help you with that. Our most popular item is the vanilla latte which comes in three sizes. Would you like to hear about our specials?",
        "Your latte is $5.50. By the way, we have a special today on pastries! Would you like to add one to your order?",
        "Perfect! I've got your order for a vanilla latte. That'll be $5.50. I'll send you a payment link now.",
    ]
    
    print("=" * 60)
    print("Message Splitter Test Cases")
    print("=" * 60)
    
    for i, text in enumerate(test_texts, 1):
        print(f"\n📝 Test {i}:")
        print(f"Original ({len(text)} chars):")
        print(f"  {text}")
        print(f"\n✂️ Split into:")
        
        messages = split_into_natural_messages(text)
        for j, msg in enumerate(messages, 1):
            print(f"  Bubble {j} ({len(msg)} chars): {msg}")
        
        print(f"\n📤 Formatted for bridge:")
        formatted = format_for_bridge(messages)
        import json
        print(json.dumps(formatted, indent=2))
        print("-" * 60)

