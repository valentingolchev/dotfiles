#!/bin/bash

source ~/.config/zsh/helper_fns.sh

FILE_PATH="$HOME/.config/kitty/listen-channel.conf"

if [[ $(is_macos) == true ]]; then
  contents="listen_on unix:/tmp/mykitty"
else
  contents="listen_on unix:@mykitty"
fi

echo "writing: $contents"

touch $FILE_PATH
echo "$contents" > "$FILE_PATH"
