import os
import re

def wrap_raw_blocks(md_text):
    # Match any code block (with or without language tag)
    code_block_re = re.compile(r"(```[^\n]*\n[\s\S]*?```)", re.MULTILINE)
    def replacer(match):
        block = match.group(1)
        if "{{" in block or "}}" in block:
            # Only wrap if not already wrapped
            if "{% raw %}" not in block:
                print("Wrapping block with {{ ... }}")
                return "{% raw %}\n" + block + "\n{% endraw %}"
        return block
    return code_block_re.sub(replacer, md_text)

def process_file(path):
    print(f"Checking: {path}")
    with open(path, "r", encoding="utf-8") as f:
        orig = f.read()
    fixed = wrap_raw_blocks(orig)
    if fixed != orig:
        with open(path, "w", encoding="utf-8") as f:
            f.write(fixed)
        print(f"Fixed: {path}")

def main():
    for root, _, files in os.walk("."):
        for file in files:
            if file.endswith(".md"):
                process_file(os.path.join(root, file))

if __name__ == "__main__":
    main()