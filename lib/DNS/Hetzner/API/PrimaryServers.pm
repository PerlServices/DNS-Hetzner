package DNS::Hetzner::API::PrimaryServers;

# ABSTRACT: PrimaryServers

# ---
# This class is auto-generated by bin/get_hetzner_info.pl
# ---

use v5.24;

use Moo;
use Types::Standard qw(:all);

use Mojo::Base -strict, -signatures;

extends 'DNS::Hetzner::APIBase';

with 'MooX::Singleton';

use DNS::Hetzner::Schema;

has endpoint  => ( is => 'ro', isa => Str, default => sub { 'primary_servers' } );

sub list ($self, %params) {
    return $self->_do( 'GetPrimaryServers', \%params, '', { type => 'get' } );
}

sub create ($self, %params) {
    return $self->_do( 'CreatePrimaryServer', \%params, '', { type => 'post' } );
}

sub delete ($self, %params) {
    return $self->_do( 'DeletePrimaryServer', \%params, '/:PrimaryServerID', { type => 'delete' } );
}

sub get ($self, %params) {
    return $self->_do( 'GetPrimaryServer', \%params, '/:PrimaryServerID', { type => 'get' } );
}

sub update ($self, %params) {
    return $self->_do( 'UpdatePrimaryServer', \%params, '/:PrimaryServerID', { type => 'put' } );
}


1;

__END__

=pod


=head1 SYNOPSIS

    use DNS::Hetzner;

    my $api_key = '1234abc';
    my $dns     = DNS::Hetzner->new(
        token => $api_key,
    );

    $dns->records->create(
    );

=head1 ATTRIBUTES

=over 4

=item * endpoint

=back

=head1 METHODS



=head2 list

Returns all primary servers associated with user. Primary servers can also be filtered by zone_id.

    $dns->primary_servers->list();


=head2 create

Creates a new primary server.

    $dns->primary_servers->create();


=head2 delete

Deletes a primary server.

    $dns->primary_servers->delete();


=head2 get

Returns an object containing all information of a primary server. Primary Server to get is identified by 'PrimaryServerID'.

    $dns->primary_servers->get();


=head2 update

Updates a primary server.

    $dns->primary_servers->update();


    