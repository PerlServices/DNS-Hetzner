package DNS::Hetzner::API::Records;

# ABSTRACT: Records

use v5.20;

use Moo;
use Types::Standard qw(:all);

use Mojo::Base -strict, -signatures;

extends 'DNS::Hetzner';

with 'DNS::Hetzner::Utils';
with 'MooX::Singleton';

use JSON::Validator;
use Carp;

has endpoint  => ( is => 'ro', isa => Str, default => sub { 'records' } );

sub get ($self, $params) {
    my $spec   =     {
        'properties' => { 'RecordID' => { 'type' => 'string', }, },
        'required'   => [ 'RecordID', ],
        'type'       => 'object',
    };

    my $validator = JSON::Validator->new->schema($spec);

    my @errors = $validator->validate(
        $params,
    );

    if ( @errors ) {
        croak 'invalid parameters';
    }

    my %request_params = map{
        exists $params->{$_} ?
            ($_ => $params->{$_}) :
            ();
    } keys %{$spec->{properties}};

    $self->request(
        '/records/:RecordID',
        { type => 'get' },
        \%request_params,
    );
}

sub update ($self, $params) {
    my $spec   =     {
        'components' => {
            'BaseRecord' => {
                'properties' => {
                    'name' => {
                        'description' => 'Name of record',
                        'type'        => 'string',
                    },
                    'ttl' => {
                        'description' => 'TTL of record',
                        'format'      => 'uint64',
                        'type'        => 'integer',
                    },
                    'type' =>
                      { '$ref' => '#/components/schemas/RecordTypeCreatable', },
                    'value' => {
                        'description' =>
                          'Value of record (e.g. 127.0.0.1, 1.1.1.1)',
                        'type' => 'string',
                    },
                    'zone_id' => {
                        'description' =>
                          'ID of zone this record is associated with',
                        'type' => 'string',
                    },
                },
            },
            'ExistingRecord' => {
                'allOf' => [ { '$ref' => '#/components/schemas/BaseRecord', }, ],
                'properties' => {
                    'created' => {
                        'description' => 'Time record was created',
                        'format'      => 'date-time',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                    'id' => {
                        'description' => 'ID of record',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                    'modified' => {
                        'description' => 'Time record was last updated',
                        'format'      => 'date-time',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                },
                'type' => 'object',
            },
            'Record' => {
                'allOf' =>
                  [ { '$ref' => '#/components/schemas/ExistingRecord', }, ],
                'required' => [ 'name', 'type', 'value', 'zone_id', ],
                'type'     => 'object',
            },
            'RecordResponse' => {
                'allOf' =>
                  [ { '$ref' => '#/components/schemas/ExistingRecord', }, ],
                'properties' =>
                  { 'type' => { '$ref' => '#/components/schemas/RecordType', }, },
                'type' => 'object',
            },
            'RecordType' => {
                'description' => 'Type of the record',
                'enum'        => [
                    'A',    'AAAA', 'PTR', 'NS',    'MX',  'CNAME',
                    'RP',   'TXT',  'SOA', 'HINFO', 'SRV', 'DANE',
                    'TLSA', 'DS',   'CAA',
                ],
                'type' => 'string',
            },
            'RecordTypeCreatable' => {
                'description' => 'Type of the record',
                'enum'        => [
                    'A',   'AAAA', 'NS',    'MX',  'CNAME', 'RP',
                    'TXT', 'SOA',  'HINFO', 'SRV', 'DANE',  'TLSA',
                    'DS',  'CAA',
                ],
                'type' => 'string',
            },
        },
        'properties' => {
            '' => { 'schema' => { '$ref' => '#/components/schemas/Record', }, },
            'RecordID' => { 'type' => 'string', },
        },
        'required' => [ 'RecordID', ],
        'type'     => 'object',
    };

    my $validator = JSON::Validator->new->schema($spec);

    my @errors = $validator->validate(
        $params,
    );

    if ( @errors ) {
        croak 'invalid parameters';
    }

    my %request_params = map{
        exists $params->{$_} ?
            ($_ => $params->{$_}) :
            ();
    } keys %{$spec->{properties}};

    $self->request(
        '/records/:RecordID',
        { type => 'put' },
        \%request_params,
    );
}

sub delete ($self, $params) {
    my $spec   =     {
        'properties' => { 'RecordID' => { 'type' => 'string', }, },
        'required'   => [ 'RecordID', ],
        'type'       => 'object',
    };

    my $validator = JSON::Validator->new->schema($spec);

    my @errors = $validator->validate(
        $params,
    );

    if ( @errors ) {
        croak 'invalid parameters';
    }

    my %request_params = map{
        exists $params->{$_} ?
            ($_ => $params->{$_}) :
            ();
    } keys %{$spec->{properties}};

    $self->request(
        '/records/:RecordID',
        { type => 'delete' },
        \%request_params,
    );
}

sub create ($self, $params) {
    my $spec   =     {
        'components' => {
            'BaseRecord' => {
                'properties' => {
                    'name' => {
                        'description' => 'Name of record',
                        'type'        => 'string',
                    },
                    'ttl' => {
                        'description' => 'TTL of record',
                        'format'      => 'uint64',
                        'type'        => 'integer',
                    },
                    'type' =>
                      { '$ref' => '#/components/schemas/RecordTypeCreatable', },
                    'value' => {
                        'description' =>
                          'Value of record (e.g. 127.0.0.1, 1.1.1.1)',
                        'type' => 'string',
                    },
                    'zone_id' => {
                        'description' =>
                          'ID of zone this record is associated with',
                        'type' => 'string',
                    },
                },
            },
            'ExistingRecord' => {
                'allOf' => [ { '$ref' => '#/components/schemas/BaseRecord', }, ],
                'properties' => {
                    'created' => {
                        'description' => 'Time record was created',
                        'format'      => 'date-time',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                    'id' => {
                        'description' => 'ID of record',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                    'modified' => {
                        'description' => 'Time record was last updated',
                        'format'      => 'date-time',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                },
                'type' => 'object',
            },
            'Record' => {
                'allOf' =>
                  [ { '$ref' => '#/components/schemas/ExistingRecord', }, ],
                'required' => [ 'name', 'type', 'value', 'zone_id', ],
                'type'     => 'object',
            },
            'RecordResponse' => {
                'allOf' =>
                  [ { '$ref' => '#/components/schemas/ExistingRecord', }, ],
                'properties' =>
                  { 'type' => { '$ref' => '#/components/schemas/RecordType', }, },
                'type' => 'object',
            },
            'RecordType' => {
                'description' => 'Type of the record',
                'enum'        => [
                    'A',    'AAAA', 'PTR', 'NS',    'MX',  'CNAME',
                    'RP',   'TXT',  'SOA', 'HINFO', 'SRV', 'DANE',
                    'TLSA', 'DS',   'CAA',
                ],
                'type' => 'string',
            },
            'RecordTypeCreatable' => {
                'description' => 'Type of the record',
                'enum'        => [
                    'A',   'AAAA', 'NS',    'MX',  'CNAME', 'RP',
                    'TXT', 'SOA',  'HINFO', 'SRV', 'DANE',  'TLSA',
                    'DS',  'CAA',
                ],
                'type' => 'string',
            },
        },
        'properties' =>
          { '' => { 'schema' => { '$ref' => '#/components/schemas/Record', }, }, },
        'required' => [],
        'type'     => 'object',
    };

    my $validator = JSON::Validator->new->schema($spec);

    my @errors = $validator->validate(
        $params,
    );

    if ( @errors ) {
        croak 'invalid parameters';
    }

    my %request_params = map{
        exists $params->{$_} ?
            ($_ => $params->{$_}) :
            ();
    } keys %{$spec->{properties}};

    $self->request(
        '/records',
        { type => 'post' },
        \%request_params,
    );
}

sub list ($self, $params) {
    my $spec   =     {
        'properties' => {},
        'required'   => [],
        'type'       => 'object',
    };

    my $validator = JSON::Validator->new->schema($spec);

    my @errors = $validator->validate(
        $params,
    );

    if ( @errors ) {
        croak 'invalid parameters';
    }

    my %request_params = map{
        exists $params->{$_} ?
            ($_ => $params->{$_}) :
            ();
    } keys %{$spec->{properties}};

    $self->request(
        '/records',
        { type => 'get' },
        \%request_params,
    );
}

sub update_bulk ($self, $params) {
    my $spec   =     {
        'components' => {
            'BaseRecord' => {
                'properties' => {
                    'name' => {
                        'description' => 'Name of record',
                        'type'        => 'string',
                    },
                    'ttl' => {
                        'description' => 'TTL of record',
                        'format'      => 'uint64',
                        'type'        => 'integer',
                    },
                    'type' =>
                      { '$ref' => '#/components/schemas/RecordTypeCreatable', },
                    'value' => {
                        'description' =>
                          'Value of record (e.g. 127.0.0.1, 1.1.1.1)',
                        'type' => 'string',
                    },
                    'zone_id' => {
                        'description' =>
                          'ID of zone this record is associated with',
                        'type' => 'string',
                    },
                },
            },
            'ExistingRecord' => {
                'allOf' => [ { '$ref' => '#/components/schemas/BaseRecord', }, ],
                'properties' => {
                    'created' => {
                        'description' => 'Time record was created',
                        'format'      => 'date-time',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                    'id' => {
                        'description' => 'ID of record',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                    'modified' => {
                        'description' => 'Time record was last updated',
                        'format'      => 'date-time',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                },
                'type' => 'object',
            },
            'Record' => {
                'allOf' =>
                  [ { '$ref' => '#/components/schemas/ExistingRecord', }, ],
                'required' => [ 'name', 'type', 'value', 'zone_id', ],
                'type'     => 'object',
            },
            'RecordResponse' => {
                'allOf' =>
                  [ { '$ref' => '#/components/schemas/ExistingRecord', }, ],
                'properties' =>
                  { 'type' => { '$ref' => '#/components/schemas/RecordType', }, },
                'type' => 'object',
            },
            'RecordType' => {
                'description' => 'Type of the record',
                'enum'        => [
                    'A',    'AAAA', 'PTR', 'NS',    'MX',  'CNAME',
                    'RP',   'TXT',  'SOA', 'HINFO', 'SRV', 'DANE',
                    'TLSA', 'DS',   'CAA',
                ],
                'type' => 'string',
            },
            'RecordTypeCreatable' => {
                'description' => 'Type of the record',
                'enum'        => [
                    'A',   'AAAA', 'NS',    'MX',  'CNAME', 'RP',
                    'TXT', 'SOA',  'HINFO', 'SRV', 'DANE',  'TLSA',
                    'DS',  'CAA',
                ],
                'type' => 'string',
            },
        },
        'properties' => {
            '' => {
                'schema' => {
                    'properties' => {
                        'records' => {
                            'items' => { '$ref' => '#/components/schemas/Record', },
                            'type'  => 'array',
                        },
                    },
                    'type' => 'object',
                },
            },
        },
        'required' => [],
        'type'     => 'object',
    };

    my $validator = JSON::Validator->new->schema($spec);

    my @errors = $validator->validate(
        $params,
    );

    if ( @errors ) {
        croak 'invalid parameters';
    }

    my %request_params = map{
        exists $params->{$_} ?
            ($_ => $params->{$_}) :
            ();
    } keys %{$spec->{properties}};

    $self->request(
        '/records/bulk',
        { type => 'put' },
        \%request_params,
    );
}

sub create_bulk ($self, $params) {
    my $spec   =     {
        'components' => {
            'BaseRecord' => {
                'properties' => {
                    'name' => {
                        'description' => 'Name of record',
                        'type'        => 'string',
                    },
                    'ttl' => {
                        'description' => 'TTL of record',
                        'format'      => 'uint64',
                        'type'        => 'integer',
                    },
                    'type' =>
                      { '$ref' => '#/components/schemas/RecordTypeCreatable', },
                    'value' => {
                        'description' =>
                          'Value of record (e.g. 127.0.0.1, 1.1.1.1)',
                        'type' => 'string',
                    },
                    'zone_id' => {
                        'description' =>
                          'ID of zone this record is associated with',
                        'type' => 'string',
                    },
                },
            },
            'ExistingRecord' => {
                'allOf' => [ { '$ref' => '#/components/schemas/BaseRecord', }, ],
                'properties' => {
                    'created' => {
                        'description' => 'Time record was created',
                        'format'      => 'date-time',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                    'id' => {
                        'description' => 'ID of record',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                    'modified' => {
                        'description' => 'Time record was last updated',
                        'format'      => 'date-time',
                        'readOnly' =>
                          bless( do { \( my $o = 1 ) }, 'JSON::PP::Boolean' ),
                        'type' => 'string',
                    },
                },
                'type' => 'object',
            },
            'Record' => {
                'allOf' =>
                  [ { '$ref' => '#/components/schemas/ExistingRecord', }, ],
                'required' => [ 'name', 'type', 'value', 'zone_id', ],
                'type'     => 'object',
            },
            'RecordResponse' => {
                'allOf' =>
                  [ { '$ref' => '#/components/schemas/ExistingRecord', }, ],
                'properties' =>
                  { 'type' => { '$ref' => '#/components/schemas/RecordType', }, },
                'type' => 'object',
            },
            'RecordType' => {
                'description' => 'Type of the record',
                'enum'        => [
                    'A',    'AAAA', 'PTR', 'NS',    'MX',  'CNAME',
                    'RP',   'TXT',  'SOA', 'HINFO', 'SRV', 'DANE',
                    'TLSA', 'DS',   'CAA',
                ],
                'type' => 'string',
            },
            'RecordTypeCreatable' => {
                'description' => 'Type of the record',
                'enum'        => [
                    'A',   'AAAA', 'NS',    'MX',  'CNAME', 'RP',
                    'TXT', 'SOA',  'HINFO', 'SRV', 'DANE',  'TLSA',
                    'DS',  'CAA',
                ],
                'type' => 'string',
            },
        },
        'properties' => {
            '' => {
                'schema' => {
                    'properties' => {
                        'records' => {
                            'items' => { '$ref' => '#/components/schemas/Record', },
                            'type'  => 'array',
                        },
                    },
                    'type' => 'object',
                },
            },
        },
        'required' => [],
        'type'     => 'object',
    };

    my $validator = JSON::Validator->new->schema($spec);

    my @errors = $validator->validate(
        $params,
    );

    if ( @errors ) {
        croak 'invalid parameters';
    }

    my %request_params = map{
        exists $params->{$_} ?
            ($_ => $params->{$_}) :
            ();
    } keys %{$spec->{properties}};

    $self->request(
        '/records/bulk',
        { type => 'post' },
        \%request_params,
    );
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



=head2 get

Returns information about a single record.

    $dns->Records->get(HASH(0x55fcbf2e0998));


=head2 put

Updates a record.

    $dns->Records->put(HASH(0x55fcbf231ab8));


=head2 delete

Deletes a record.

    $dns->Records->delete(HASH(0x55fcbf232130));


=head2 post

Creates a new record.

    $dns->Records->post(HASH(0x55fcbf222cb8));


=head2 get

Returns all records associated with user.

    $dns->Records->get(HASH(0x55fcbf2232d0));


=head2 put

Update several records at once.

    $dns->Records->put(HASH(0x55fcbf2234c8));


=head2 post

Create several records at once.

    $dns->Records->post(HASH(0x55fcbf2d4458));


    