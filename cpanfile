requires perl => 5.024;

requires 'Carp'            => 0;
requires 'JSON::Validator' => 4.10;
requires 'Moo'             => 1.003001;
requires 'MooX::Singleton' => 0;
requires 'Mojolicious'     => 8;
requires 'Types::Mojo'     => 0.04;
requires 'Types::Standard' => 1.012;

on test => sub {
    requires 'Test::LongString'       => 0.16;
    requires 'Pod::Coverage::TrustPod => 0;
};
