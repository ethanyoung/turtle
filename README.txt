File in this distribution:
	turtle2svg.pl		perl script
	turtle2png.sh		shell script that invoke the above perl script
	peeve2turtle.pl		perl script
	peeve2png.sh		shell script that invokes the above perl script

1. How to run the programs.
For perl scripts, call 
	perl [filename]
to run the program.

For shell scripts, change the permissions by
	chmod u+x [filename]
then call
	./[filename]
to run the program.

2. Functions supported.
 * turtle2svg.pl	convert turtle file to svg file
 * turtle2png.sh	convert turtle file to png file
 * peeve2turtle.pl	convert peeve file to turtle file
 * peeve2png.sh		convert a list of peeve files to png files

Also, the program supports DEFINESTYLE and SETSTYLE primitives for changing style of the pen, including the width and colour.

Additionaaly, the program has error checking. It checks the syntax of each line in the file to convert. When come acros syntax errors, the program prompts which kind of syntax error is and in which line the error is. Also, the program prompts errors when use tries to set style that has not been defined.

3. Primitives supported for each type of file.
 * turtle file
	PENDOWN
	PENUP
	RIGHT
	LEFT
	FORWARD
	BACKWARD
	DEFINESTYLE
	SETSTYLE
 * peeve file
	LINE
	POLYGON
	CIRCLE
	DEFINESTYLE
	SETSTYLE

4. Known limitation.
The syntax error checking is not as high as complier level. THe progarm accept all the right input, and prompts error messages for most syntax errors. But not guarantee that all the syntax erorr will be detected with error message.
