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
  $editMatrix->setValue(1, $i, new EditMatrixNode($i - 1, "fromtop")); 
}

# initialize distances for first row
for ($i = 1; $i <= $colCount; $i++) { 
  #print "x: $i, y: 0, dis: $i fromleft\n";
  $editMatrix->setValue($i, 1, new EditMatrixNode($i - 1, "fromleft")); 
}

#$editMatrix->print("getVector");

#now, start at 2,2 and determine the best way to get there
for ($x = 2; $x <= $colCount; $x++) {
  for ($y = 2; $y <= $rowCount; $y++) {
    #first, see if it's a diagonal
    if (substr($oldString, $x - 2, 1) eq substr($newString, $y - 2, 1)) {
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
$x = $colCount;
$y = $rowCount;
@steps = ();
while($x != 1 || $y != 1) {
  #record direction - only need to record it if it's not diagonal
  $dir = $editMatrix->getValue($x, $y)->getDirection();
  #print "x: $x, y: $y; dir: $dir\n";
  if (!($dir eq "d")) {
    unshift(@steps, { 
        _direction => $dir, 
        _indexA => $x - 1, 
        _indexB => $y - 1
      });
  }
  $x -= $dir eq "d" || $dir eq "l" ? 1 : 0;
  $y -= $dir eq "d" || $dir eq "t" ? 1 : 0;
}

#write out a human friendly representation of the change which were made
@diffChars = split("", $oldString);
@indicator = ();
for ($i = 0; $i < length($oldString) + length($newString); $i++) { 
  $indicator[$i] = ""; 
}

print "$oldString\n";
print "$newString\n";
$offset = 0;
foreach (@steps) {
  if ($_->{ _direction } eq "l") {
    $adjIndexA = $_->{ _indexA } + $offset - 1;
    $charToDel = substr($oldString, $adjIndexA - $offset, 1);
    print "delete char at index $adjIndexA (\"$charToDel\")\n";
    $offset--;
  } elsif ($_->{ _direction } eq "t") {
    $adjIndexA = $_->{ _indexA } + $offset;
    $adjIndexB = $_->{ _indexB } - 1;
    $charToIns = substr($newString, $adjIndexB, 1);
    print "insert char from the new string at index $adjIndexB (\"$charToIns\") into the old string at index $adjIndexA\n";
    $offset++;
  }
}

$diffString = join("", @diffChars);
$indicatorString = join("", @indicator);
#print "$diffString\n$indicatorString\n";
