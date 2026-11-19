import os
import subprocess

from kittens.tui.handler import result_handler

SESSION = os.path.expanduser("~/.config/kitty/sessions/dev.kitty-session")


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    cwd = window.get_cwd_of_child() if window else os.getcwd()
    subprocess.Popen(
        ["kitty", "--session", SESSION, "--directory", cwd or os.getcwd()],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
