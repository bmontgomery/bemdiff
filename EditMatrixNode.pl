package EditMatrixNode;
# expects a distance and direction parameters
sub new {
  my $class = shift;
  my $distance = shift;
  my $direction = shift;
  my $self = {
    _distance => $distance,
    _direction => $direction
  };
  bless $self, $class;
  return $self;
}

sub getDistance {
  $self = shift;
  return $self->{ _distance };
}

sub getDirection {
  $self = shift;
  if ($self->{ _direction } eq "diag") {
    return "d";
  } elsif ($self->{ _direction } eq "fromleft") {
    return "l";
  } elsif ($self->{ _direction } eq "fromtop") {
    return "t";
  }
}

sub getVector {
  $self = shift;
  return $self->{ _distance } . $self->getDirection();
}

1;
