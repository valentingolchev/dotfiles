#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <pdf file>"
    exit 1
fi

pdf_file="$1"
txt_file="${pdf_file%.pdf}.txt"

pdftotext -layout -nopgbreak -enc UTF-8 "$pdf_file" "$txt_file"

echo "Created: $txt_file"