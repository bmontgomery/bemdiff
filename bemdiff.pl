require "./matrix.pl";
# expect the first argument to be the old string
# expect the second argument to be the new string
$oldString = $ARGV[0];
$newString = $ARGV[1];

# build edit distance matrix
$colCount = length($oldString) + 1;
$rowCount = length($newString) + 1;

# init matrix
$editMatrix = new Matrix($colCount, $rowCount);

# initialize distances for first row
for ($i = 0; $i < $colCount; $i++) { 
  $editMatrix->setValue($i, 0, { 
      _distance => $i, 
      _direction => "none" 
    }); 
}

# initialize distances for first column
for ($i = 0; $i < $rowCount; $i++) { 
  $editMatrix->setValue(0, $i, {
      _distance => $i,
      _direction => "none"
    }); 
}

#$editMatrix->print;

#now, start at 1,1 and determine the best way to get there
$x = 1;
$y = 1;

#first, see if it's a diagonal
if ($oldString[$x - 1] == $newString[$y - 1]) {
  print "diagonal!!";
  $editMatrix->setValue($x, $y, $editMatrix->getValue($x - 1, $y - 1));
}

$editMatrix->print;
