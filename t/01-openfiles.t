#!perl

use strict;
use warnings;
use Test::More;
use IO::AIO;
use IO::AIO::LoadLimited;

plan tests => 1024;

my %data;
my $limit = 10;
my @files = map { "t/data/" . $_ . ".txt" } (1..1024);
my $grp   = aio_group sub { print "Done!" };

aio_load_limited $grp, $limit, @files, sub {
    my ($file, $content) = @_;
    $data{$file} = $content ? $content : "coudnt read file: $!";
};

IO::AIO::flush;

foreach my $file (sort {$a <=> $b} keys %data) {
    if (my ($fileno) = $file =~ m/(\d+)\.txt$/) {
        is $fileno, $data{$file}, "$file matches content";
    } else {
        fail "filename looks odd: $file";
    }
}

done_testing;
