#!/bin/bash

NUM_PARALLEL="${NUM_PARALLEL:-16}"

if [[ $# -ne 1 ]]; then
	echo "usage: $0 dst/"
	exit 1
fi
dst="$(cd "$1" &>/dev/null && pwd)"

# Directory dst will have structure:
# dst/videos.txt
# dst/partial/
# dst/complete/

if [ ! -f "$dst/videos.txt" ]; then
	echo "list of videos is missing: $dst/videos.txt"
    exit 1
fi

mkdir -p "$dst"/{partial,complete}

(
    cd "$dst"
    # Videos that are missing from YouTube.
    # User can clear partial/ to re-try.
    find partial/ -name err.txt -print0 | xargs -0 grep -l -e "ERROR: Video unavailable" -e "ERROR: Private video" -e "ERROR: Sign in to confirm your age" -e "ERROR: This video has been removed" | \
        awk '-F/' '{print $2}' >missing.txt
    echo "number of unavailable videos: $(wc -l missing.txt)"
    # Get list of videos that are not missing and not complete.
    comm -23 <(cat videos.txt | sort) <(cat <(ls complete) missing.txt | sort) >remain.txt
    echo "number of available videos that remain: $(wc -l remain.txt)"
)
# Download!
cat "$dst/remain.txt" | shuf | xargs -n 1 -P "${NUM_PARALLEL}" ./download_one.sh "$dst"
