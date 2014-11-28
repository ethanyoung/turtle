#! /bin/bash
# peeve2png.sh
# Convert peeve file to png file. Using a turtle file as temporaty.

for file in $@
do
	turtlefile=${file/.peeve/.turtle}
	# Convert to turtle file
	perl peeve2turtle.pl $file > "$turtlefile"
	# Print the turtle file
	cat $turtlefile
	# Convert from turtle file to png file
	./turtle2png.sh $turtlefile
done

echo "\n"

rm $turtlefile
rm peeve2turtle.turtle
