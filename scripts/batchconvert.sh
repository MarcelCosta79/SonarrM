#!/bin/sh
fpath="$sonarr_episodefile_path"
ss=$(dirname "$fpath")
cd "$ss"
find -type f ! -name "*edited.mkv" -size +100M -printf '\033[32m%p\033[0m\n'
find -type f ! -name "*edited.mkv" -size +100M -exec /scripts/one.sh {} \; 
