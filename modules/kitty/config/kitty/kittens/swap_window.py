from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    # args[1] = title of window to swap with (e.g. "term" or "llm")
    title = args[1] if len(args) > 1 else "term"
    tab = boss.active_tab
    active = tab.active_window
    # only act when nvim window (big window) is focused
    if active is None or active.title != "nvim":
        return
    target = next((w for w in tab if w is not active and w.title == title), None)
    if target is None:
        return
    # swap positions; active group follows target, so focus stays on big window
    tab.swap_windows(target, active)
