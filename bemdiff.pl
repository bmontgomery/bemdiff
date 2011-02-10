require "./matrix.pl";
require "./EditMatrixNode.pl";
# expect the first argument to be the old file
# expect the second argument to be the new file
$oldFilePath = $ARGV[0];
$newFilePath = $ARGV[1];

# read in the lines of each file, build a dictionary of lines
open($OLDFILE, $oldFilePath) or die("error reading $oldFilePath");
open($NEWFILE, $newFilePath) or die("error reading $newFilePath");

# the %lines hash stores the unique lines from both files
#   "we the people" => 0
#   "of the united states of america" => 1
# the %map hash stores the same information, but backwards - the key
# is the number, the value is the text
#   0 => "we the people"
#   1 => "of the united states of america"
%lines = ();
%map = ();
@oldFileMap = ();
@newFileMap = ();

sub buildHash {
  my $file = shift;
  my $hashref = shift;
  my $maphashref = shift;
  my $filemapref = shift;
  my $counter = 0;
  while ($line = <$file>) {
    chomp($line);
    my $hashCount = scalar(keys(%{$hashref}));
    if (!defined($hashref->{$line})) {
      $hashref->{$line} = $hashCount; 
      $maphashref->{$hashCount} = $line;
    }
    @{$filemapref}[$counter] = $hashref->{$line};
    $counter++;
  }
}

# read from old file
buildHash($OLDFILE, \%lines, \%map, \@oldFileMap);
buildHash($NEWFILE, \%lines, \%map, \@newFileMap);

# build edit distance matrix
$colCount = scalar(@oldFileMap) + 1;
$rowCount = scalar(@newFileMap) + 1;

# init matrix
$editMatrix = new Matrix($colCount, $rowCount);

# initialize distances for first column
for ($i = 1; $i <= $rowCount; $i++) { 
  $editMatrix->setValue(1, $i, new EditMatrixNode($i - 1, "fromtop")); 
}

# initialize distances for first row
for ($i = 1; $i <= $colCount; $i++) { 
  $editMatrix->setValue($i, 1, new EditMatrixNode($i - 1, "fromleft")); 
}

# now, start at 2,2 and determine the best way to get there, repeat for
# all vertices in grid 
for ($x = 2; $x <= $colCount; $x++) {
  for ($y = 2; $y <= $rowCount; $y++) {
    #first, see if it's a diagonal
    if (@oldFileMap[$x - 2] eq @newFileMap[$y - 2]) {
      $editMatrix->setValue($x, $y, new EditMatrixNode($editMatrix->getValue($x - 1, $y - 1)->{ _distance }, "diag"));
    } else {
      #try from the top and from the left, see which is better.
      $distanceFromTop = $editMatrix->getValue($x, $y - 1)->getDistance() + 1;
      $distanceFromLeft = $editMatrix->getValue($x - 1, $y)->getDistance() + 1;
      if ($distanceFromTop > $distanceFromLeft) {
        #left looks better! we'll take that instead.
        $editMatrix->setValue($x, $y, new EditMatrixNode($distanceFromLeft, "fromleft"));
      } else {
        #top looks good! we'll take it.
        $editMatrix->setValue($x, $y, new EditMatrixNode($distanceFromTop, "fromtop"));
      }
    }
  }
}

# transform the edit matrix into the minimum list of steps to transform the old string into the new string
# start at the bottom-right node, and move backwards through the edit matrix, following the recorded directions
$x = $colCount;
$y = $rowCount;
@steps = ();
while($x != 1 || $y != 1) {
  #record direction - only need to record it if it's not diagonal
  $dir = $editMatrix->getValue($x, $y)->getDirection();
  unshift(@steps, { 
      _direction => $dir, 
      _indexA => $x - 1, 
      _indexB => $y - 1
    });
  $x -= $dir eq "d" || $dir eq "l" ? 1 : 0;
  $y -= $dir eq "d" || $dir eq "t" ? 1 : 0;
}

#write out a human friendly representation of the change which were made
$indexOld = 0;
$indexNew = 0;
@diff = ();
foreach (@steps) {
  if ($_->{ _direction } eq "l") {
    # this is a delete from the old file. in this case, we show the line
    # from the old file with a "-" in front of it.
    $indicator = "-";
    $line = $map{$oldFileMap[$indexOld++]};
  } elsif ($_->{ _direction } eq "t") {
    # this is an insert from the new file. in this case, we show the line
    # from the new file with a "+" in front of it.
    $indicator = "+";
    $line = $map{$newFileMap[$indexNew++]};
  } else {
    # no change - in this case, we show the line (same in both files) and
    # increment both file indexes.
    $indicator = " ";
    $line = $map{$newFileMap[$indexNew++]};
    $indexOld++;
  }
  # since we chomped the line when reading it into the hash, add a \n at
  # the end
  @diff[scalar(@diff)] = "$indicator $line\n";
}

foreach $line (@diff) {
  print "$line";
}
