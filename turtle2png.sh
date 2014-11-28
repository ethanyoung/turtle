#! /bin/bash
# turtle2png.sh
# Convert turtle file to png file. Using one svg file as temporary file.

# Convert turtle file to svg file(temp)
dir="/tmp/turtle2svg$$"
perl turtle2svg.pl $1 > $dir
# Print svg file
cat $dir
# Convert to png file
rsvg ${dir} "${1/.turtle/.png}"
# Remove temporary files
rm $dir
rm turtle2svg.svg
