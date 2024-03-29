package Mojolicious::Plugin::Notifications::JSON;
use Mojo::Base 'Mojolicious::Plugin::Notifications::Engine';

has key => 'notifications';

# Nothing to register
sub register {
  my ($plugin, $app, $param) = @_;
  $plugin->key($param->{key}) if $param->{key};
};


# Notification method
sub notifications {
  my ($self, $c, $notify_array, $rule, $json, %param) = @_;

  my $key = $param{key} // $self->key;

  return $json unless @$notify_array;

  if (!$json || ref $json) {
    my @msgs;
    foreach (@$notify_array) {
      push(@msgs, [$_->[0], $_->[-1]]);
    };

    if (!$json) {
      return { $key => \@msgs }
    }

    # Obect is an array
    elsif (index(ref $json, 'ARRAY') >= 0) {
      push(@$json, { $key => \@msgs });
    }

    # Object is a hash
    elsif (index(ref $json, 'HASH') >= 0) {
      my $n = ($json->{$key} //= []);
      push(@$n, @msgs);
    };
  };

  return $json;
};


1;


__END__

=pod

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Notifications::JSON - Event Notifications in JSON


=head1 SYNOPSIS

  # Register the engine
  plugin Notifications => {
    JSON => 1
  };

  # In the controller
  $c->render(json => $c->notifications(json => $json));


=head1 DESCRIPTION

This plugin is a simple notification engine for JSON.

If it does not suit your needs, you can easily
L<write your own engine|Mojolicious::Plugin::Notifications::Engine>.


=head1 METHODS

L<Mojolicious::Plugin::Notifications::JSON> inherits all methods
from L<Mojolicious::Plugin::Notifications::Engine> and implements
the following new one.


=head2 register

  plugin Notifications => {
    JSON => {
      key => 'notes'
    }
  };

Called when registering the main plugin.
All parameters under the key C<JSON> are passed to the registration.

Accepts the following parameters:

=over 4

=item B<key>

Define the attribute name of the notification array.
Defaults to C<notifications>.

=back


=head1 HELPERS

=head2 notify

See the base L<notify|Mojolicious::Plugin::Notifications/notify> helper.


=head2 notifications

  $c->render(json => $c->notifications(json => $json));
  $c->render(json => $c->notifications(json => $json, key => 'notes'));

Merge notifications into your JSON response.

In case JSON is an object, it will inject an attribute
that points to an array reference containing the notifications.
If the JSON is an array, an object is appended with one attribute
that points to an array reference containing the notifications.
If the JSON is empty, an object will be created with one attribute
that points to an array reference containing the notifications.

If the JSON is not of one of the descripted types, it's returned
unaltered.

The name of the attribute can either be given on registration or
by passing a parameter for C<key>.
The name defaults to C<notifications>.


=head1 AVAILABILITY

  https://github.com/Akron/Mojolicious-Plugin-Notifications


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014, L<Nils Diewald|http://nils-diewald.de/>.

This program is free software, you can redistribute it
and/or modify it under the terms of the Artistic License version 2.0.

=cut
