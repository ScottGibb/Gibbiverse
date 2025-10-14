import re, os
import yaml
from pathlib import Path
from argparse import ArgumentParser

# Set up argument parser
parser = ArgumentParser(description="Clean Markdown links.")
parser.add_argument("--path", type=Path, help="Root directory containing Markdown files.", default="../")
parser .add_argument("--links", type=Path, help="Path to a file containing valid links (one per line).", default="../links.yaml")
parser .add_argument("--topics", type=Path, help="Path to a file containing valid topics (one per line).", default="../topics.txt")
BLOG_DIR = parser.parse_args().path
LINKS_DIR = parser.parse_args().links
TOPICS_DIR = parser.parse_args().topics

# Open Links Database
with open(LINKS_DIR, "r", encoding="utf-8") as f:
    link_entries = yaml.safe_load(f)

# Open Topics Database
with open(TOPICS_DIR, "r", encoding="utf-8") as f:
    topic_entries = [line.strip() for line in f if line.strip()]

# Regex to find markdown links
LINK_PATTERN = re.compile(r'\[([^\]]+)\]\(([^)]*)\)')

def process_link(text_part: str) -> str:
    if text_part in link_entries:
        print(f"🔗 Replacing '{text_part}' with link from {LINKS_DIR}")
        text_part = "[{}]({})".format(text_part, link_entries[text_part])
    return text_part

def clean_links_in_file(filepath: Path):
    text = filepath.read_text(encoding="utf-8")

    def replace_link(match):
        text_part = match.group(1)
        url = match.group(2).strip()

        # Case 1: Empty link
        if not url:
            print(f"🧹 Removing empty link in {filepath}")
            return process_link(text_part)

        # Case 2: External to blog folder (example heuristic)
        if not os.path.isfile(url) and not url.startswith(("/", "#", "http://", "https://")):
            print(f"🚫 Removing external link '{url}' in {filepath}")
            return process_link(text_part)
        # Otherwise, keep link
        return match.group(0)

    new_text = LINK_PATTERN.sub(replace_link, text)

    # Only overwrite if changes
    if new_text != text:
        filepath.write_text(new_text, encoding="utf-8")

def add_tags_to_file(filepath: Path):
    text = filepath.read_text(encoding="utf-8")
    front_match = re.match(r"^---\n(.*?)\n---\n?", text, re.DOTALL)
    if not front_match:
        return

    front_data = yaml.safe_load(front_match.group(1)) or {}
    tags = front_data.get("tags", [])
    if isinstance(tags, str):
        tags = [tags]
    elif not isinstance(tags, list):
        tags = []

    body = text[front_match.end():]
    found = []
    body_lower = text.lower()
    for topic in topic_entries:
        if topic.lower() in body_lower and topic not in tags and topic not in found:
            found.append(topic)

    if not found:
        return

    tags.extend(found)
    front_data["tags"] = tags
    new_front = yaml.safe_dump(front_data, sort_keys=False).strip()
    filepath.write_text(f"---\n{new_front}\n---\n{body}", encoding="utf-8")
    print(f"🏷️ Added tags {found} to {filepath}")

def main():
    print("Starting link cleanup...")
    for md_file in BLOG_DIR.rglob("*.md"):
        print(f"Processing {md_file}")
        clean_links_in_file(md_file)
        add_tags_to_file(md_file)
    print("Link cleanup completed.")

if __name__ == "__main__":
    main()
