#!/usr/bin/env python3
"""
Fix the safe_print mess in bridge.py by replacing it with a working version
"""
import re

with open('bridge.py', 'r') as f:
    content = f.read()

# Remove the broken safe_safe_print function
content = re.sub(r'def safe_safe_print.*?\n.*?pass\n', '', content, flags=re.DOTALL)

# Replace safe_print with working version
safe_print_func = '''def safe_print(*args, **kwargs):
    """Print that won't crash on BrokenPipeError."""
    try:
        print(*args, **kwargs)
        sys.stdout.flush()
    except (BrokenPipeError, IOError):
        pass

'''

# Find where to insert (after imports)
lines = content.split('\n')
for i, line in enumerate(lines):
    if line.startswith('# ---------'):
        if 'Safe Print' in lines[i-1] or 'Safe Print' in line:
            # Remove old safe print section
            start_idx = i - 1
            end_idx = i + 10
            while end_idx < len(lines) and not lines[end_idx].startswith('# -----'):
                end_idx += 1
            lines = lines[:start_idx] + [safe_print_func] + lines[end_idx:]
            break

content = '\n'.join(lines)

# Replace all safe_safe_print back to safe_print
content = content.replace('safe_safe_print', 'safe_print')

with open('bridge.py', 'w') as f:
    f.write(content)

print("✅ Fixed safe_print in bridge.py")




