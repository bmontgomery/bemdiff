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
  $xDim = $self->{ _xDim };
  $yDim = $self->{ _yDim };
  if (defined($self->{ _matrixArray })) {
    return $self->{ _matrixArray }[$x + $y * $self->{ _yDim }];
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
  $xDim = $self->{ _xDim };
  $yDim = $self->{ _yDim };
  $self->{ _matrixArray }[$x + $y * $self->{ _yDim }] = $value;
}

# this method prints out the matrix in an easy to read format. it allows for a parameter which tells what method to run during the print. mostly for debugging purposes.
sub print {
  $self = shift;
  $method = shift;
  for ($r = 0; $r < $self->{ _yDim }; $r++) {
    for ($c = 0; $c < $self->{ _xDim }; $c++) {
      $printVal = $self->{ _matrixArray }[$c + $r * $self->{ _yDim }]->$method;
      print " $printVal ";
    }
    print "\n";
  }
}

1;
