#! usr/bin/perl -w
# peeve2svg.pl
# Convert a peeve file to svg file, and generate the svg file to STDOUT
use Math::Trig;

$TURTLEfilename = "peeve2turtle.turtle";
$angle = 0;
$originX = 200;
$originY = 200;
$linecount = 1;				# Trace the current line number of the file.
$PI = 4*atan2(1,1);			# Value of pi.

# Clear the turtle file, which is temporary.
open(TURTLEFILE, ">$TURTLEfilename")
or die "Could not create file \"$TURTLEfilename\"!\n";
close(TURTLEFILE);

# Begin to append content to the turtle file.
open(TURTLEFILE, ">>$TURTLEfilename")
or die "Could not create file \"$TURTLEfilename\"!\n";


while(<>) {
	# Get each line
	chomp;
	
	# Parse the line
	&convert($_);
	
	$linecount++;
}


# Close file
close(TURTLEFILE);

# Read file and print to standard output
open(TURTLEFILE, "<$TURTLEfilename");
while(<TURTLEFILE>) {
	print;
}
close(TURTLEFILE);

sub convert {
	
	# Ignore comments.
	s/#.*//g;
	# Eliminate extra spaces.
	s/\s+/ /g;
	
	# If nothing in this line, skip this line.
	if ($_[0] =~ m/^\s$|^$/) {
		return;
	}
	
	elsif (m/^DEFINESTYLE /){
		# Check syntax.
		my $copy = $_[0];
		$copy =~ s/^DEFINESTYLE //;
		my @values = split(/ /, $copy);
		if ($#values != 4) {
			die "At line $linecount, \"$_[0]\".\nNumbers of parameter for DEFINESTYLE is invalid!\n";
		}
		
		# No syntax error, output
		&writeFile($_[0]);
		
	}
	elsif (m/^SETSTYLE /) {
		# Check syntax.
		my $copy = $_[0];
		$copy =~ s/^SETSTYLE //;
		my @values = split(/ /, $copy);
		if ($#values != 0) {
			die "At line $linecount, \"$_[0]\".\nNumbers of parameter for SETSTYLE is invalid!\n";
		}
		
		# No syntax error, output.
		&writeFile($_[0]);
	}
	
	elsif (m/^LINE /) {
		s/^LINE //;
		
		# numbers = {x1, y1, x2, y2}
		my @numbers= split(/ /,);
		if ($#numbers != 3) {
			die "At line $linecount, \"$_[0]\".\nNumbers of parameter for LINE is invalid!\n";
		}
		
		# Move twice, first time go to the start point,
		# second time draw the line.
		&gotoPoint($numbers[0], $numbers[1]);
		&writeFile("PENDOWN");
		gotoPoint($numbers[2], $numbers[3]);
		&writeFile("PENUP");
	}
	
	elsif (m/^POLYGON /) {
		s/^POLYGON //;
		
		# numbers = {x1, y1, init_angle, n_sides, side_length}
		my @numbers = split(/ /,);
		if ($#numbers != 4) {
			die "At line $linecount, \"$_[0]\".\nNumbers of parameter for POLYGON is invalid!\n";
		}
		
		# Initial state
		&gotoPoint($numbers[0], $numbers[1]);
		&rotateToAngle($numbers[2]);
		
		# Draw the polygon.
		&writeFile("PENDOWN");
		&drawPolygon($numbers[3], $numbers[4]);
		&writeFile("PENUP");
		
	}
	
	elsif (m/^CIRCLE /) {
		s/^CIRCLE //;
		
		# numbers = {x, y, radius}
		my @numbers = split(/ /,);
		if ($#numbers != 2) {
			die "At line $linecount, \"$_[0]\".\nNumbers of parameter for CIRCLE is invalid!\n";
		}
		
		# The number of sides of the circle: the diameter divided by 3.
		# "3" is the apporximately units of the length of the circle.
		my $side_length = 3;
		my $n_side = 2*$PI*$numbers[2]/$side_length;
		
		# If the number of sides is at minimum 8, so that it is like a circle.
		$n_side > 8 or $n_side = 8; 
		
		# Go to the center of the circle.
		&gotoPoint($numbers[0], $numbers[1]);
		&gotoPoint($numbers[0]-$numbers[2], $numbers[1]);
		&rotateToAngle(0);
		
		# Draw the polygon with many sides, such that it looks like a circle.
		&writeFile("PENDOWN");
		&drawPolygon($n_side, $side_length);
		&writeFile("PENUP");
	}
	else {
		die "At line $linecount, \"$_[0]\".Primitive syntax error!\n";
	}
}

# Go from current point to the specified point.
sub gotoPoint {
	
	if ($originX != $_[0] || $originY != $_[1]){
		my $destX = $_[0];
		my $destY = $_[1];
		
		my $a = $destX - $originX;
		my $b = $destY - $originY;
		
		my $length = sqrt($a**2 + $b**2);
		
		# Get the rotation in radiant.
		my $rotation_r = asin($a/$length);
		if ($b>0) {
			$rotation_r = $PI - $rotation_r;
		}		
		
		# degree = radiant * 45 /atan(1,1)
		my $rotation = $rotation_r * 45 /atan2(1,1);
		
		# Do the rotation first.
		&rotateToAngle($rotation);
		
		# Go to the position.
		&writeFile("FORWARD", $length);
		
		# Change current position.
		$originX = $destX;
		$originY = $destY;
	}
}

# Rotate from current angle to the specified angle
sub rotateToAngle {
	my $rotationoffset = $_[0] - $angle;
	if ($rotationoffset <0) {
		&writeFile("LEFT", -$rotationoffset);
	}
	else {
		&writeFile("RIGHT", $rotationoffset);
	}
	
	$angle = $_[0];
}

# Draw a polygon with the specified  n_sides and side_length 
# with no init_angle.
# The first side is drawn verticle up.
sub drawPolygon {
	# Sum of a polygon's exterior angles' degree is 360
	my $exteriorangle = 360/$_[0];
	
	for(my $i=0;$i<$_[0];$i++){
		&writeFile("FORWARD", $_[1]);
		&rotateToAngle($angle+$exteriorangle);
	}
}

sub writeFile {
	if ($_[0] eq "PENUP" || $_[0] eq "PENDOWN" ||
		$_[0] =~ m/^DEFINESTYLE/ || $_[0] =~ m/^SETSTYLE/) {
		print TURTLEFILE "$_[0]\n";
	}
	else {
		print TURTLEFILE "$_[0] $_[1]\n";
	}
}
