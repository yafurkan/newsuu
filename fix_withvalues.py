#!/usr/bin/env python3
import os
import re

def fix_withvalues_in_file(filepath):
    """Fix withValues method calls in a single file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace .withValues(alpha: X) with .withOpacity(X)
        pattern = r'\.withValues\(alpha:\s*([0-9.]+)\)'
        replacement = r'.withOpacity(\1)'
        
        new_content = re.sub(pattern, replacement, content)
        
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Fixed: {filepath}")
            return True
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def fix_all_dart_files():
    """Fix all Dart files in the project"""
    fixed_count = 0
    
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                if fix_withvalues_in_file(filepath):
                    fixed_count += 1
    
    print(f"Fixed {fixed_count} files")

if __name__ == "__main__":
    fix_all_dart_files()