#! usr/bin/perl -w
# turtle2svg.pl
# Convert a turtle file to svg file, and generate the svg file to STDOUT

$SVGfilename = "turtle2svg.svg";
$originX = 200;
$originY = 200;
$angle = 0;
$isDown = 0;					# The state of the pen.
$linecount = 1;					# Trace the current line number.

$DEFAULTSTYLE = "default";		# The default style.
$DEFAULTRED = 0;	
$DEFAULTGREEN = 0;
$DEFAULTBLUE = 0;
$DEFAULTWIDTH = "2";
$style = $DEFAULTSTYLE;
$red{$style} = $DEFAULTRED;		# Use hashes to store relevant information.
$green{$style} = $DEFAULTGREEN;
$blue{$style} = $DEFAULTBLUE;
$width{$style} = $DEFAULTWIDTH;
$styles[0] = $style;			# The style array.

# Clear the svg file, which will be send to standard output at the
# end of the program.
open(SVGFILE, ">$SVGfilename")
or die "Could not create file \"$SVGfilename\"!\n";
close(SVGFILE);

# Begin to append contents.
open(SVGFILE, ">>$SVGfilename")
or die "Could not create file \"$SVGfilename\"!\n";

# Write header for SVG file.
print SVGFILE '<svg xmlns="http://www.w3.org/2000/svg" ';
print SVGFILE 'viewBox="0 0 400 400" ';
print SVGFILE 'version="1.1">';
print SVGFILE "\n";

# These two lines for stage one of the assignment 2 only.
#print SVGFILE '<g fill="none" stroke="green" stroke-width="2">';
#print SVGFILE "\n";

while(<>) {
	# Get each line
	chomp;
	
	# Parse the line
	&convert($_);
	
	$linecount++;
}

# Write footer for SVG file
#print SVGFILE "\t<\/g>\n";
print SVGFILE '</svg>';

# Close file
close(SVGFILE);

# Read file and print to standard output
open(SVGFILE, "<$SVGfilename");
while(<SVGFILE>) {
	print;
}
close(SVGFILE);

# Convert each line of turtle file to svg file.
sub convert{

	# Ignore comments.
	s/#.*//g;
	# Eliminate extra spaces.
	s/\s+/ /g;
	
	# If nothing in this line, skip this line.
	if ($_[0] =~ m/^\s$|^$/) {
		return;
	}
	
	elsif (m/^DEFINESTYLE/) {

		s/^DEFINESTYLE //;
		
		# values = {name, r, g, b, width}
		my @values = split(/ /,);
		if ($#values != 4) {
			die "At line $linecount, \"$_[0]\".\nNumbers of parameter for DEFINESTYLE is invalid!\n";
		}
		
		$stylename = $values[0];
		$red{$stylename} = $values[1];
		$green{$stylename} = $values[2];
		$blue{$stylename} = $values[3];
		$width{$stylename} = $values[4];
		
		# Check if the style defined previouly.
		for($i=0;$i<=$#styles;$i++){
			if($stylename eq $styles[$i]) {
				$styles[$i] = $stylename;
				return;
			}
		}
		
		# When this is a new style, save it to the next index of array.
		$styles[$#styles+1] = $stylename;

		
	}
	
	elsif (m/^SETSTYLE/) {
		
		# Get the style name.
		s/^SETSTYLE //g;
		my @values = split(/ /, );
		if ($#values != 0) {
			die "At line $linecount, \"$_[0]\".\nNumbers of parameter for SETSTYLE is invalid!\n";
		}
		my $stylename1= $values[0];
		
		# Check whether it is defined.
		# If yes, then get the style.
		foreach $s(@styles) {
			if ($s eq $stylename1) {
				$style = $stylename1;
				return;
			}
		}
		
		# If no, then terminate the program with an error mesage.
		die "Style \"$stylename1\" has not been defined! \nThe \@styles are @styles\n"
	}
	
	elsif (m/^PENDOWN/) {
		s/\s+//g;
		if (m/^PENDOWN$/) {
			$isDown = 1;
		}
		else {
			die "At line $linecount, \"$_[0]\" is invalid!\n";
		}
	}
	
	elsif (m/^PENUP/) {
		s/\s+//g;
		if (m/^PENUP$/) {
			$isDown = 0;
		}
		else {
			die "At line $linecount, \"$_[0]\" is invalid!\n";
		}
	}
	
	# If it is doing rotating
	elsif ($_[0] =~ m/^RIGHT|^LEFT/) {
		$_[0] =~ s/^RIGHT /+/;
		$_[0] =~ s/^LEFT /-/;
		$angle += $_[0];
	}
		
	# If it is moving
	elsif ($_[0] =~ m/^FORWARD|^BACKWARD/) {
		$_[0] =~ s/^FORWARD /+/;
		$_[0] =~ s/^BACKWARD /-/;
		
		# radian = degree * PI/180 = degree * atan2(1,1)/45
		my $destX = $originX + $_[0] * sin(atan2(1,1)*$angle/45);
		my $destY = $originY + $_[0] * (-cos(atan2(1,1)*$angle/45));	
		if ($isDown == 1) {	
			&writeFile($originX, $originY, $destX, $destY);
		}
		$originX = $destX;
		$originY = $destY;
	}
	
	
	
	else {
		die "At line $linecount!\n, \"$_[0]\". Syntax error!\n";
	}
}

sub writeFile{
	
	# Get style information.
	my $r = $red{$style};
	my $g = $green{$style};
	my $b = $blue{$style};
	my $width = $width{$style};
	
	# Position information.
	print SVGFILE "\t<line x1=\"$_[0]\" y1=\"$_[1]\" x2=\"$_[2]\" y2=\"$_[3]\"\n";
	# Style information
	print SVGFILE "\tstyle=\"stroke:rgb($r,$g,$b);stroke-width:$width\" \/>\n";
	
}