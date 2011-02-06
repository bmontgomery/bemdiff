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
for ($i = 0; $i < $rowCount; $i++) { 
  $editMatrix->setValue(0, $i, new EditMatrixNode($i, "fromtop")); 
}

# initialize distances for first row
for ($i = 0; $i < $colCount; $i++) { 
  $editMatrix->setValue($i, 0, new EditMatrixNode($i, "fromleft")); 
}

#$editMatrix->print;

#now, start at 1,1 and determine the best way to get there
for ($x = 1; $x < $colCount; $x++) {
  for ($y = 1; $y < $rowCount; $y++) {
    #first, see if it's a diagonal
    if (substr($oldString, $x - 1, 1) eq substr($newString, $y - 1, 1)) {
      $editMatrix->setValue($x, $y, new EditMatrixNode($editMatrix->getValue($x - 1, $y - 1)->{ _distance }, "diag"));
    } else {
      #try from the top and from the left, see which is better.
      $distanceFromTop = $editMatrix->getValue($x, $y - 1)->{ _distance } + 1;
      $distanceFromLeft = $editMatrix->getValue($x - 1, $y)->{ _distance } + 1;
      if ($distanceFromTop < $distanceFromLeft) {
        #top looks good! we'll take it.
        $editMatrix->setValue($x, $y, new EditMatrixNode($distanceFromTop, "fromtop"));
      } else {
        #left looks better! we'll take that instead.
        $editMatrix->setValue($x, $y, new EditMatrixNode($distanceFromLeft, "fromleft"));
      }
    }
  }
}

$editMatrix->print("getVector");
