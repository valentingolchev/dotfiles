#!/usr/bin/env python3

import re
import subprocess

from kitty.boss import Boss
from kittens.tui.handler import result_handler


def get_visible_kitty_text(boss):
    texts = []
    for w in boss.list_windows():
        text = w.get_text()
        texts.append(text)
    return "\n".join(texts)


def extract_urls(text):
    # Basic URL-matching regex
    url_pattern = re.compile(r'''(
        (?:
            https?:// |
            ftp:// |
            news:// |
            git:// |
            mailto: |
            file:// |
            www\.
        )
        [\w\-@;/?:&=%\$_.+!*\x27(),~#\x1b\[\]]+
        [\w\-@;/?&=%\$_+!*\x27(~]
    )''', re.VERBOSE)
    return [url.rstrip('\'"') for url in url_pattern.findall(text)]


def fzf_select(urls: list[str]) -> str:
    if not urls:
        return None

    result = subprocess.run(
        ["kitty", "@", "launch",
         "--type=overlay",
         "fzf", "--prompt=Select URL: "],
        input="\n".join(urls).encode(),
        capture_output=True
    )
    return result.stdout.decode().strip() if result.returncode == 0 else None


def open_url(url: str) -> None:
    subprocess.Popen(['xdg-open', url])


def main(args: list[str]) -> str:
    return "Select a URL from visible windows (press Enter to continue)"


@result_handler(type_of_input='text')
def handle_result(args: list[str],
                  answer: str,
                  target_window_id: int,
                  boss: Boss) -> None:
    text = get_visible_kitty_text(boss)
    urls = extract_urls(text)
    if not urls:
        boss.notify("No URLs found in visible windows.")
        return

    selected = fzf_select(urls)
    if selected:
        open_url(selected)
