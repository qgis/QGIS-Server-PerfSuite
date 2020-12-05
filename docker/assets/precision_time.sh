#!/bin/bash
start="$(date +'%s.%N')"
$@
echo "$(date +"%s.%N - ${start}" | bc)" >&2

