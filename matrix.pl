package Matrix;
# constructor expects an x-dimension and a y-dimension
sub new {
  my $class = shift;
  my $self = {
    _xDim => shift,
    _yDim => shift
  };
  bless $self, $class;
  return $self;
}

# this method expects an x-coordinate and a y-coordinate
sub getValue {
  $self = shift;
  $x = shift;
  $y = shift;
  if (defined($self->{ _matrixArray })) {
    return $self->{ _matrixArray }[$self->getMatrixIndex($x, $y)];
  } else {
    return 0;
  }
}

# this method expects an x-coordinate, a y-coordinate, and a value
sub setValue {
  $self = shift;
  $x = shift;
  $y = shift;
  $value = shift;
  $self->{ _matrixArray }[$self->getMatrixIndex($x, $y)] = $value;
}

# this method prints out the matrix in an easy to read format. it allows for a parameter which tells what method to run during the print. mostly for debugging purposes.
sub print {
  $self = shift;
  $method = shift;
  for ($r = 1; $r <= $self->{ _yDim }; $r++) {
    for ($c = 1; $c <= $self->{ _xDim }; $c++) {
      $val = $self->{ _matrixArray }[$self->getMatrixIndex($c, $r)];
      if (!defined $val || $method eq "") {
        $printVal = $val;
      } else {
        $printVal = $val->$method;
      }
      print " $printVal ";
    }
    print "\n";
  }
}

sub getMatrixIndex {
  $self = shift;
  $x = shift;
  $y = shift;
  return $x - 1 + $self->{ _xDim } * ($y - 1);
}

1;
