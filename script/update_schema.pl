#!/usr/bin/perl
 
use strict;
use warnings;
 
use FindBin;
use File::Spec;
 
use DBIx::Class::Schema::Loader qw/make_schema_at/;
 
use Pod::Usage qw(pod2usage);;
use Getopt::Long qw(:config posix_default gnu_compat no_ignore_case);
use List::Util qw(first);
 
my %opt;
$opt{user} = $ENV{PGUSER} || 'postgres';
$opt{password} = $ENV{PGPASSWORD};
$opt{host} = $ENV{PGHOST};
$opt{database} = $ENV{PGDATABASE};
 
GetOptions(
\%opt, qw/
host|h=s
database|d=s
user|u=s
password|p=s
/) or pod2usage(1);
 
 
my @require_options = qw/host database/;
die pod2usage(2) if first { !exists $opt{$_} } @require_options;
 
my $dsn = "dbi:Pg:database=$opt{database};host=$opt{host}";
 
make_schema_at(
'Osero::Model::Schema',
{
dump_directory => File::Spec->catdir($FindBin::Bin, '..', 'lib'),
really_erase_my_file => 1,
debug => 1,
},
[ $dsn, $opt{user}, $opt{password} ],
);
 
__END__
 
=head1 NAME
 
update_schema - DBIx::Class::Schema Loading
 
=head1 SYNOPSIS
 
update_schema.pl [options]
 
Options:
-h --host
ホスト名
-d --database
データベース名
-u --user
ユーザー名
-p --password
パスワード名
 
=cut
