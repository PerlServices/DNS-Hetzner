#!/usr/bin/env perl

# PODNAME: get_hcloud_info.pl
# ABSTRACT: get API definitions from docs.hetzner.cloud

use v5.20;

use Mojo::Base -strict, -signatures;

use Mojo::File qw(path curfile);
use Mojo::JSON qw(decode_json);
use Mojo::UserAgent;
use Mojo::Util qw(dumper);
use Mojo::URL;
use Data::Printer;
use Data::Dumper::Perltidy;

$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Trailingcomma = 1;
#$Data::Dumper::Purity = 1;
$Data::Dumper::Deepcopy = 1;

use feature 'postderef';
no warnings 'experimental::postderef';

my $ua   = Mojo::UserAgent->new;
my $url  = 'https://dns.hetzner.com';
my $base = 'https://dns.hetzner.com/api/v1';

my $tx        = $ua->get( $url . '/api-docs' );
my $dom       = $tx->res->dom;
my ($scripts) = $dom->find('script')->grep( sub {
    my $src = $_->attr('src');
    return if !$src;
    return 1 if $src =~ m{main\.\w+\.chunk.js};
    return;
});

my $js_tx  = $ua->get($url . $scripts->first->attr('src'));
my ($json) = $js_tx->res->body =~ m{JSON\.parse\('(.*?\}{4,})'\)};
$json =~ s{\\'}{'}g;
$json =~ s{\\\\}{\\}g;

my $data  = decode_json $json;
my @paths = keys $data->{paths}->%*;

my $components = $data->{components};
delete $components->{securitySchemes};
delete $components->{schemas}->{Pagination};
delete $components->{schemas}->{Meta};

my %classes;
APIPATH:
for my $api_path ( @paths ) {
    my $parts = path( $api_path )->to_array;
    my $name  = $parts->[1];
    my $class = ucfirst $name;

    my $subtree = $data->{paths}->{$api_path};
    $subtree->{path} = $api_path;
    $subtree->{parts} = $parts;

    $classes{$class} //= {
        endpoint => $name,
    };

    push $classes{$class}->{defs}->@*, $subtree;
}

for my $class ( keys %classes ) {
    say "Build class $class.pm";
    my $def = $classes{$class};

    my $code = _get_code( $class, $def, $components );

    my $path = curfile->dirname->child(
        qw/.. lib DNS Hetzner API/,
        "$class.pm"
    );

    my $fh = $path->open('>');
    $fh->print( $code );
    $fh->close;
}

sub _get_code ($class, $definitions, $components) {
    my $endpoint    = $definitions->{endpoint};
    my $subs        = '';
    my $methods_pod = '';

    for my $subdef ( $definitions->{defs}->@* ) {
        my $uri  = $subdef->{path} =~ s/\{(.*?)\}/:$1/rg;

        METHOD:
        for my $method ( keys $subdef->%* ) {
            my ($method_def) = $subdef->{$method};

            next METHOD if 'HASH' ne ref $method_def;

            delete @{ $method_def }{qw/responses x-code-samples summary tags operationId/};
        
            my $description = delete $method_def->{description};

            my $params              = _get_params( $class, $method_def, $components );
            my ($sub, $method_name) = _get_sub( $method, $subdef->{parts}, $uri, $params );
            my $pod                 = _get_pod( $method, $description, $class, $params );

            $subs        .= $sub;
            $methods_pod .= $pod;
        }
    }

    my $pod = sprintf q~

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

%s
~, $methods_pod;

    my $code = sprintf q~package DNS::Hetzner::API::%s;

# ABSTRACT: %s

use v5.20;

use Moo;
use Types::Standard qw(:all);

use Mojo::Base -strict, -signatures;

extends 'DNS::Hetzner';

with 'DNS::Hetzner::Utils';
with 'MooX::Singleton';

use JSON::Validator;
use Carp;

has endpoint  => ( is => 'ro', isa => Str, default => sub { '%s' } );
%s

1;

__END__

=pod

%s
    ~,
    $class, $class, $endpoint, $subs, $pod;

    return $code;
}

sub _get_params ( $class, $method_def, $components ) {
    my %params;
    my @required;
    my %components;

    PARAM:
    for my $param ( $method_def->{parameters}->@* ) {
        next PARAM if $param->{in} eq 'query';

        my $name = $param->{name};
        $params{$name} = $param->{schema};

        if ( $param->{required} ) {
            push @required, $name;
        }
    }

    if ( ($method_def->{requestBody} // {} )->%* ) {
        my $sub_def = $method_def->{requestBody};
        my $type    = $sub_def->{content};
        my $name    = "";

        if ( $type->{"text/plain"} ) {
            $params{""} = { type => "string" };
        }

        if ( $type->{"application/json"} ) {
            my $component_check = $class =~ s{s\z}{}r;
            my %subcomponents = map {
                ( $_ => $components->{schemas}->{$_} );
            } grep {
                $_ =~ m{$component_check};
            } keys $components->{schemas}->%*;

            %components = ( components => \%subcomponents );
            $params{""} = $type->{"application/json"};
        }

        if ( $sub_def->{description} ) {
            $params{$name}->{description} = $sub_def->{description};
        }

        if ( $sub_def->{required} ) {
            push @required, $name;
        }
    }

    my %data = (
        type       => "object",
        properties => \%params,
        required   => \@required,
        %components,
    );

    return \%data;
}

sub _get_sub ( $method, $parts, $uri, $params ) {
    my $method_name = $method;

    $method_name = 'create' if $method eq 'post';
    $method_name = 'update' if $method eq 'put';

    if ( $method eq 'get' && $uri !~ m/:/ ) {
        $method_name = 'list';
    }

    if ( $parts->@* > 2 && $parts->[-1] !~ m/\{/ ) {
        $method_name .= '_' . $parts->[-1];
    }

    my $spec = Dumper($params);
    $spec    =~ s{\$VAR1 = }{};
    $spec    =~ s{^}{    }xmsg;

    my $sub = sprintf q~
sub %s ($self, $params) {
    my $spec   = %s
    my $validator = JSON::Validator->new->schema($spec);

    my @errors = $validator->validate(
        $params,
    );

    if ( @errors ) {
        croak 'invalid parameters';
    }

    my %%request_params = map{
        exists $params->{$_} ?
            ($_ => $params->{$_}) :
            ();
    } keys %%{$spec->{properties}};

    $self->request(
        '%s',
        { type => '%s' },
        \%%request_params,
    );
}
~, $method_name, $spec, $uri, $method;

    return ($sub, $method_name);
}

sub _get_pod ( $method, $description, $object, $params) {
    my $pod = sprintf q~

=head2 %s

%s

    $dns->%s->%s(%s);
~,
        $method, $description, $object, $method, $params;

    return $pod;
}