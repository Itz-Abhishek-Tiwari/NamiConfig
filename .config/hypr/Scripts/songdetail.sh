#!/bin/bash

# Fetch song title and artist
title=$(playerctl metadata --format '{{title}}')
artist=$(playerctl metadata --format '{{artist}}')

# Truncate title to 20 characters if it's too long
max_length=30
if [ ${#title} -gt $max_length ]; then
  title="${title:0:$max_length}..."
fi

# Display song information with the truncated title
song_info="$title   󰽬    $artist"
echo "$song_info"

