require "./matrix.pl";
require "./EditMatrixNode.pl";
# expect the first argument to be the old string
# expect the second argument to be the new string
$oldString = $ARGV[0];
$newString = $ARGV[1];

# build edit distance matrix
$colCount = length($oldString) + 1;
$rowCount = length($newString) + 1;

# init matrix
$editMatrix = new Matrix($colCount, $rowCount);

# initialize distances for first column
for ($i = 1; $i <= $rowCount; $i++) { 
  #print "x: 0, y: $i, dis: $i fromtop\n";
  $editMatrix->setValue(1, $i, new EditMatrixNode($i, "fromtop")); 
}

# initialize distances for first row
for ($i = 1; $i <= $colCount; $i++) { 
  #print "x: $i, y: 0, dis: $i fromleft\n";
  $editMatrix->setValue($i, 1, new EditMatrixNode($i, "fromleft")); 
}

#$editMatrix->print("getVector");

#now, start at 2,2 and determine the best way to get there
for ($x = 2; $x <= $colCount; $x++) {
  for ($y = 2; $y <= $rowCount; $y++) {
    #first, see if it's a diagonal
    if (substr($oldString, $x - 1, 1) eq substr($newString, $y - 1, 1)) {
      $editMatrix->setValue($x, $y, new EditMatrixNode($editMatrix->getValue($x - 1, $y - 1)->{ _distance }, "diag"));
      #print "x: $x, y: $y, dir: diag\n";
    } else {
      #try from the top and from the left, see which is better.
      $distanceFromTop = $editMatrix->getValue($x, $y - 1)->getDistance() + 1;
      $distanceFromLeft = $editMatrix->getValue($x - 1, $y)->getDistance() + 1;
      if ($distanceFromTop < $distanceFromLeft) {
        #top looks good! we'll take it.
        $editMatrix->setValue($x, $y, new EditMatrixNode($distanceFromTop, "fromtop"));
        #print "x: $x, y: $y, dir: fromtop; dl: $distanceFromLeft, dt: $distanceFromTop\n";
      } else {
        #left looks better! we'll take that instead.
        $editMatrix->setValue($x, $y, new EditMatrixNode($distanceFromLeft, "fromleft"));
        #print "x: $x, y: $y, dir: fromleft; dl: $distanceFromLeft, dt: $distanceFromTop\n";
      }
    }
  }
}

$editMatrix->print("getVector");

#transform the edit matrix into the minimum list of steps to transform the old string into the new string
#start at the bottom-right node, and move backwards through the edit matrix, following the recorded directions
$x = $colCount - 1;
$y = $rowCount - 1;
@steps = ();
while($x != 1 || $y != 1) {
  #record direction - only need to record it if it's not diagonal
  $dir = $editMatrix->getValue($x, $y)->getDirection();
  #print "x: $x, y: $y; dir: $dir\n";
  if (!($dir eq "d")) {
    $index = $dir eq "l" ? $x : $y;
    unshift(@steps, { _direction => $dir, _index => $index});
  }
  $x -= $dir eq "d" || $dir eq "l" ? 1 : 0;
  $y -= $dir eq "d" || $dir eq "t" ? 1 : 0;
}

#print out the steps
foreach (@steps) {
  print "$_\n";
}
