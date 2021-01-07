package DNS::Hetzner;

use v5.24;

# ABSTRACT: Perl library to work with the API for the Hetzner DNS

use Carp;
use Moo;
use Mojo::UserAgent;
use Types::Mojo qw(:all);
use Types::Standard qw(Str);

use DNS::Hetzner::Schema;

with 'DNS::Hetzner::API';

use Mojo::Base -strict, -signatures;

has token    => ( is => 'ro', isa => Str, required => 1 );
has host     => ( is => 'ro', isa => MojoURL["https?"], default => sub { 'https://dns.hetzner.com' }, coerce => 1 );
has base_uri => ( is => 'ro', isa => Str, default => sub { 'api/v1' } );

has client   => (
    is      => 'ro',
    lazy    => 1,
    isa     => MojoUserAgent,
    default => sub {
        Mojo::UserAgent->new,
    }
);

__PACKAGE__->load_namespace;

1;

=head1 INFO

This is still pretty alpha. The API might change.

=head1 SYNOPSIS

    use DNS::Hetzner;
    use Data::Printer;

    my $dns = DNS::Hetzner->new(
        token => 'ABCDEFG1234567',    # your api token
    );

    my $records = $dns->records;
    my $zones   = $dns->zones;

    my $all_records = $records->list;
    p $all_records;

=head1 ATTRIBUTES

=over 4

=item * base_uri

I<(optional)> Default: C<api/v1>

=item * client 

I<(optional)> A C<Mojo::UserAgent> compatible user agent. By default a new object of C<Mojo::UserAgent>
is created.

=item * host

I<(optional)> This is the URL to Hetzner's Cloud-API. Defaults to C<https://dns.hetzner.com>

=item * token

B<I<(required)>> Your API token.

=back

=head1 METHODS

=head2 records

=head2 zones
