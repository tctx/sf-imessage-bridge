# AppleScript Enhancements - Reactions & Haptics

**Priority: 🟡 HIGH**  
**Timeline: Next few hours**  
**Goal: Make iMessage conversations feel more human and engaging**

---

## Overview

Right now we can send and receive text messages through the bridge. The next level is adding iMessage-specific features like reactions (likes, hearts), haptic feedback, and better message formatting to make the experience feel truly native.

---

## Current State

### What Works ✅
- Sending text messages via AppleScript
- Receiving messages through bridge
- Basic message formatting

### What's Missing ❌
- Message reactions (like, heart, laugh, etc.)
- Haptic feedback triggers
- Speech bubble grouping
- Typing indicators
- Message effects (slam, loud, gentle)

---

## Task Breakdown

### 1. Message Reactions Implementation
**Location:** `helpers/bridge/sf-message-bridge-11-5/imessage_send.applescript`

> **⚠️ Important:** This feature may already exist, so there may not be a need to write a new function. Instead please review the AppleScript code first, and then read these instructions as broad guidelines instead of the word of God. In general this document describes what we want at a high level and is not intended to be a directive to rewrite functions if they already exist or in any other way substantially modify code that already works.

#### Types of Reactions to Support
- [ ] 👍 Thumbs Up (Like)
- [ ] ❤️ Heart
- [ ] 😂 Laugh (Haha)
- [ ] ‼️ Exclamation
- [ ] ❓ Question Mark
- [ ] 😮 Surprised

#### Implementation Steps
- [ ] Research AppleScript commands for reactions
  - Test in Script Editor
  - Find message ID reference method
  - Determine reaction syntax
  
- [ ] Create reaction functions
  ```applescript
  on sendReaction(messageId, reactionType)
      -- Implementation
  end sendReaction
  ```
  
- [ ] Test each reaction type
  - Send test message
  - React to it programmatically
  - Verify it appears correctly in Messages
  
- [ ] Add bridge API endpoint
  ```python
  @app.post("/bridge/react")
  async def send_reaction(message_id: str, reaction: str):
      # Call AppleScript with reaction
  ```
  
- [ ] Integrate into demo flow
  - When user confirms order → Send ❤️ reaction
  - When user asks question → Send 👍 to acknowledge
  - After receipt sent → Send 😊 celebration

#### Success Criteria
- [ ] Can programmatically react to any message intelligently
- [ ] Reactions appear correctly in iMessage
- [ ] Timing feels natural (not instant, not too slow)
- [ ] Works reliably 95%+ of the time

---

### 2. Haptic Feedback
**Goal:** Trigger phone vibrations for important moments

> **⚠️ Important:** This feature may already exist, so there may not be a need to write a new function. Instead please review the AppleScript code first, and then read these instructions as broad guidelines instead of the word of God. In general this document describes what we want at a high level and is not intended to be a directive to rewrite functions if they already exist or in any other way substantially modify code that already works.

#### Haptic Triggers to Implement
- [ ] Order confirmation (strong haptic)
- [ ] Receipt arrival (success haptic)
- [ ] Important notifications (attention haptic)

#### Implementation Approach
- [ ] Research iMessage effects that trigger haptics
  - "Slam" effect
  - "Loud" effect
  - Custom vibration patterns
  
- [ ] Test AppleScript message effects
  ```applescript
  send "Order confirmed!" with effect "slam"
  ```
  
- [ ] Map demo moments to haptic types
  | Moment | Effect | Haptic Type |
  |--------|--------|-------------|
  | Payment link sent | Gentle | Light tap |
  | Order confirmed | Slam | Strong |
  | Receipt delivered | Loud | Success pattern |
  
- [ ] Implement in message sender
  ```python
  def send_with_haptic(message: str, effect: str):
      # Call AppleScript with effect parameter
  ```
  
- [ ] Test on real iPhone
  - Verify haptics feel appropriate
  - Not too aggressive
  - Enhances experience

#### Success Criteria
- [ ] Haptics work on physical iPhone
- [ ] Feel natural and appropriate
- [ ] Don't annoy or overwhelm
- [ ] Add delight to key moments

---

### 3. Speech Bubble Formatting - Human-Like Message Flow
**Goal:** Make messages feel like they're from a real person texting naturally

> **⚠️ Important:** This feature may already exist, so there may not be a need to write a new function. Instead please review the AppleScript code first, and then read these instructions as broad guidelines instead of the word of God. In general this document describes what we want at a high level and is not intended to be a directive to rewrite functions if they already exist or in any other way substantially modify code that already works.

#### Current State
The app already does some intelligent message splitting, but needs extra polish to ensure:
- **No mid-sentence cutoffs** (most critical)
- Natural thought grouping
- Breaks that mimic how humans actually text

#### The Problem We're Solving
When AI generates long responses, we need to break them into multiple bubbles like a human would:

**❌ Bad (Mid-sentence cutoff):**
```
Bubble 1: "Great! I can help you with that. Our most popular item is the vanilla latte"
Bubble 2: "which comes in three sizes. Would you like to hear about our specials?"
```

**✅ Good (Natural thought breaks):**
```
Bubble 1: "Great! I can help you with that."
Bubble 2: "Our most popular item is the vanilla latte which comes in three sizes."
Bubble 3: "Would you like to hear about our specials?"
```

#### Implementation Focus

##### 1. Sentence Boundary Detection
- [ ] **Review current message splitting logic**
  - Where is it happening? (Backend? Bridge?)
  - What rules does it currently use?
  
- [ ] **Ensure complete sentence integrity**
  ```python
  def split_into_natural_messages(text: str) -> list[str]:
      """
      Split AI response into natural message bubbles.
      NEVER break in the middle of a sentence.
      """
      # Split on natural boundaries:
      # - End of sentences (. ! ?)
      # - Natural pauses (after questions, after statements)
      # - Topic changes
      
      # Rules:
      # 1. Keep sentences together
      # 2. Group related thoughts (2-3 sentences max per bubble)
      # 3. Break after questions
      # 4. Break before topic changes
  ```

##### 2. Natural Grouping Rules (How Humans Text)

**Humans group by thought, not by character count:**

- [ ] **After questions** - Always break
  ```
  "What size would you like?" → [break]
  "We have small, medium, and large." → [break]
  ```

- [ ] **Topic changes** - Always break
  ```
  "Your latte is $5.50." → [break]
  "By the way, we have a special today!" → [break]
  ```

- [ ] **Lists and options** - Keep together
  ```
  "We have vanilla, caramel, and hazelnut."  # Keep in one bubble
  ```

- [ ] **Short acknowledgments** - Separate
  ```
  "Great choice!" → [break]
  "I'll get that started for you." → [break]
  ```

##### 3. Character Limits (With Intelligence)
- [ ] Don't split purely on character count
- [ ] Use character limits as a *guideline* only
- [ ] **Never exceed 160 characters per bubble** (good guideline)
- [ ] But **always finish the sentence** even if it goes slightly over

```python
MAX_CHARS_PER_BUBBLE = 160  # Guideline, not hard rule

def is_good_break_point(text: str, position: int) -> bool:
    """
    Check if this is a natural place to break a message.
    """
    char = text[position]
    next_char = text[position + 1] if position + 1 < len(text) else ""
    
    # Good break points:
    # - After sentence endings (. ! ?)
    # - After complete thoughts
    # - NOT in the middle of words
    # - NOT between "words that" are clearly connected
    
    if char in '.!?':
        return True
    
    if char == '\n':
        return True
        
    return False
```

##### 4. Testing & Validation
- [ ] **Review current message splits**
  - Run the demo
  - Screenshot all AI responses
  - Check for any mid-sentence breaks
  
- [ ] **Test with various response lengths**
  - Short responses (1 sentence)
  - Medium responses (3-4 sentences)
  - Long responses (full menu descriptions)
  
- [ ] **Compare to real human texting**
  - How would YOU type this response?
  - Where would YOU break it into messages?
  - Does the AI split match human intuition?

##### 5. Edge Cases to Handle
- [ ] Very long sentences (150+ characters)
  - Still don't break mid-sentence
  - Maybe rephrase in backend to be shorter?
  
- [ ] Lists and enumerations
  ```
  Good: "We have three sizes: small, medium, and large."  # One bubble
  ```
  
- [ ] URLs and payment links
  ```
  Bubble 1: "Here's your payment link:"
  Bubble 2: "[URL]"  # Keep URL in its own bubble
  ```

#### Implementation Checklist
- [ ] Find where message splitting currently happens
- [ ] Review the splitting algorithm/rules
- [ ] Add sentence boundary detection (if missing)
- [ ] Test with 10 different AI responses
- [ ] Fix any instances of mid-sentence breaks
- [ ] Verify breaks feel natural (get feedback from 3 people)

#### Success Criteria
- [ ] **Zero mid-sentence cutoffs** (absolute requirement)
- [ ] Messages group by complete thoughts
- [ ] Breaks feel like a human is typing
- [ ] 5/5 testers say "messages flow naturally"
- [ ] No awkward pauses or timing issues
- [ ] Works consistently across all AI responses

#### Examples of Good vs Bad Splits

**Scenario: Confirming an order**

❌ **Bad:**
```
"Perfect! I've got your order for a vanilla latt"
"e. That'll be $5.50. I'll send you a payment li"
"nk now."
```

✅ **Good:**
```
"Perfect! I've got your order for a vanilla latte."
"That'll be $5.50."
"I'll send you a payment link now."
```

**Scenario: Asking about preferences**

❌ **Bad:**
```
"Great! What size would you like? We have small, medium"
", and large."
```

✅ **Good:**
```
"Great! What size would you like?"
"We have small, medium, and large."
```

**Scenario: Menu description**

❌ **Bad:**
```
"Our vanilla latte is made with espresso, steamed milk, and"
"vanilla syrup. It's our most popular drink!"
```

✅ **Good:**
```
"Our vanilla latte is made with espresso, steamed milk, and vanilla syrup."
"It's our most popular drink!"
```

---

### 4. Typing Indicators
**Goal:** Show "..." typing indicator before AI responds

> **⚠️ Important:** This feature may already exist, so there may not be a need to write a new function. Instead please review the AppleScript code first, and then read these instructions as broad guidelines instead of the word of God. In general this document describes what we want at a high level and is not intended to be a directive to rewrite functions if they already exist or in any other way substantially modify code that already works.

#### Implementation Approach
- [ ] Research AppleScript typing indicator
  ```applescript
  tell application "Messages"
      show typing indicator for conversation "682-443-9658"
  end tell
  ```
  
- [ ] Add typing indicator control
  - Start typing indicator
  - Delay for realistic duration (1-3 seconds) or until message is ready to be sent
  - Send message
  - Stop typing indicator
  
- [ ] Implement in bridge
  ```python
  def send_message_with_typing(message: str, typing_duration: int = 2):
      start_typing_indicator()
      await asyncio.sleep(typing_duration)
      send_message(message)
      stop_typing_indicator()
  ```
  
- [ ] Calculate appropriate typing duration
  - Longer messages = longer typing
  - Formula: `length / 20` seconds (avg typing speed)
  - Min: 1 second, Max: 5 seconds

#### Success Criteria
- [ ] Typing indicator appears before response (especially during first reply to original text message, which is currently not happening)
- [ ] Duration feels realistic
- [ ] Stops when message sent
- [ ] Adds to natural feel
- [ ] Ensure that typing animation is supported for all possible ios releases and phone models

---

### 5. Message Effects
**Goal:** Use iMessage effects for special moments

> **⚠️ Important:** This feature may already exist, so there may not be a need to write a new function. Instead please review the AppleScript code first, and then read these instructions as broad guidelines instead of the word of God. In general this document describes what we want at a high level and is not intended to be a directive to rewrite functions if they already exist or in any other way substantially modify code that already works.

#### Effect Types to Implement
- [ ] **Slam** - Order confirmation
  - Message slams onto screen
  - Strong haptic feedback
  - Use for: "Order confirmed! 🎉"
  
- [ ] **Loud** - Important announcements
  - Message appears larger
  - Attention-grabbing
  - Use for: Payment links
  
- [ ] **Gentle** - Welcome messages
  - Soft appearance
  - Light haptic
  - Use for: Initial greeting
  
- [ ] **Invisible Ink** - Fun reveals (optional)
  - User swipes to reveal
  - Could use for: "Your order is..."
  - Adds delight

#### Implementation
- [ ] Test each effect in AppleScript
- [ ] Map effects to message types
- [ ] Update message sender to support effects
  ```python
  send_message(
      text="Order confirmed! 🎉",
      effect="slam",
      trigger_haptic=True
  )
  ```

#### Success Criteria
- [ ] Effects work reliably
- [ ] Appropriate for context
- [ ] Add delight without annoyance
- [ ] Work on target iOS versions

---

## Technical Implementation

### Files to Modify
1. **`helpers/bridge/sf-message-bridge-11-5/imessage_send.applescript`**
   - Add reaction functions
   - Add effect parameters
   - Add typing indicator controls

2. **`helpers/bridge/sf-message-bridge-11-5/bridge.py`**
   - Add reaction API endpoint
   - Update message sender with effects
   - Implement timing logic

3. **`backend/demo_playbook.py`**
   - Decide when to use reactions
   - Map moments to effects
   - Implement haptic triggers

### Testing Strategy
1. **Unit Tests**
   - Test each AppleScript function individually
   - Verify parameters work correctly
   - Check error handling

2. **Integration Tests**
   - Test full flow with reactions
   - Verify timing and grouping
   - Check effects on real device

3. **User Testing**
   - Show to 5 people
   - Get feedback on natural feel
   - Adjust based on reactions

---

## Research & Resources

### AppleScript Documentation
- [ ] Review Messages.app AppleScript dictionary
- [ ] Find examples of reactions in AppleScript
- [ ] Research message effects API
- [ ] Check iOS version compatibility

### Testing Tools
- [ ] Script Editor (Mac)
- [ ] Messages.app debug mode
- [ ] iPhone for real-world testing
- [ ] Screen recording for demos

---

## Priority Order

### Do First (Next 2 hours)
1. Message reactions (especially ❤️ and 👍)
2. Basic haptic feedback (slam effect)
3. Typing indicators (this currently works, but it just needs polish and to ensure it happens on initial messages when a conversation starts)

### Do Next (Next 2 hours)
4. Speech bubble grouping
5. More message effects
6. Polish timing

### Do Last (When time permits)
7. Advanced reactions
8. Custom vibration patterns
9. Invisible ink (if fun)

---

## Success Metrics

- [ ] Reactions work 95%+ of time
- [ ] Haptics feel appropriate to 9/10 testers
- [ ] Typing indicators feel natural
- [ ] Messages group like real iMessage
- [ ] Effects enhance (don't distract from) experience

---

## Known Challenges

### Challenge 1: AppleScript Limitations
- **Problem:** AppleScript for Messages may not support all features
- **Solution:** Test extensively, document what works, find workarounds

### Challenge 2: Timing
- **Problem:** Getting timing to feel natural is subjective
- **Solution:** Test with real users, iterate based on feedback

### Challenge 3: iOS Version Differences
- **Problem:** Features may work differently on different iOS versions
- **Solution:** Test on most common iOS version (iOS 15+)

---

## Definition of Done

**This section is complete when:**
1. Can send reactions programmatically
2. Key moments have appropriate haptic feedback
3. Messages group naturally like iMessage
4. Typing indicators work before AI responses
5. Order confirmation has "slam" effect with haptic
6. 5 people test it and say "it feels like real texting"

---

**Status: 🚧 TODO**  
**Dependencies:** Bridge must remain stable  
**Risk Level:** Medium (changes to working system)  
**Estimated Time:** 4-6 hours

