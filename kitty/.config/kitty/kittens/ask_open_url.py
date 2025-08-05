#!/usr/bin/env python3

from typing import List, Optional

import json
import re
import subprocess
import sys
import os


def get_visible_kitty_text(window_id):
    try:
        proc = subprocess.Popen(
            ["kitty", "@", "get-text", "--match", f"id:{window_id}"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=None,  # Let stderr go to terminal
            text=True
        )
        stdout, _ = proc.communicate()
        return stdout
    except subprocess.CalledProcessError:
        return None


def extract_urls(text: str) -> List[str]:
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
    urls = url_pattern.findall(text)
    return set([url.rstrip('\'"') for url in urls])


def fzf_select(prompt: str, choices: List[str]) -> str:
    if not choices:
        return None

    fzf = subprocess.Popen(
        ["fzf", f"--prompt={prompt}"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=None,  # Let stderr go to terminal
        text=True
    )
    stdout, _ = fzf.communicate("\n".join(choices))
    if fzf.returncode == 0 and stdout.strip():
        selected_line = stdout.strip()
        return selected_line

    return None


def get_all_windows():
    result = subprocess.run(
        ["kitty", "@", "ls"],
        stdout=subprocess.PIPE,
        text=True
    )
    return json.loads(result.stdout)


def select_window_with_fzf():
    windows = get_all_windows()

    # Prepare choices for fzf: "id | title | cwd"
    choices = []
    id_map = {}
    for window in windows:
        if window["is_active"]:
            for tab in window["tabs"]:
                for win in tab["windows"]:
                    desc = f'{win["id"]} | {win["title"]} | {win["cwd"]}'
                    choices.append(desc)
                    id_map[desc] = win["id"]

    selected = fzf_select("Select Window: ", choices)

    return id_map.get(selected)


def is_active_and_focused(w):
    return w["is_active"] and w["is_focused"]


def get_active_window():
    windows = get_all_windows()
    for window in windows:
        if is_active_and_focused(window):
            for tab in window["tabs"]:
                if is_active_and_focused(tab):
                    for win in tab["windows"]:
                        if is_active_and_focused(win):
                            return win["id"]
    return None


def open_url(url):
    # if sys.platform.startswith('darwin'):
    #     subprocess.Popen(['open', url])
    # elif sys.platform.startswith('win'):
    #     os.startfile(url)
    # else:
    subprocess.Popen(['xdg-open', url])


def print_to_parent(msg):
    try:
        os.write(3, msg.encode())
    except OSError:
        print(msg)


def main(args: List[str]) -> str:
    window_id = select_window_with_fzf()
    # window_id = get_active_window()
    text = get_visible_kitty_text(window_id)
    urls = extract_urls(text)
    if not urls:
        return None

    selected_url = fzf_select("Select URL: ", urls)
    # if not selected_url:
    #     return None

    open_url(selected_url)


def handle_result(args: List[str],
                  url: Optional[str],
                  target_window_id: int,
                  boss) -> None:
    pass


if __name__ == "__main__":
    main([])
