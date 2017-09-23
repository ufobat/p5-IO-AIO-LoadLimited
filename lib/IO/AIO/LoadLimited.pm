package IO::AIO::LoadLimited;

use common::sense;
use base qw(Exporter);

# IO:AIO Version 2 supports groups and requests objects
use IO::AIO 2;

our @EXPORT  = qw(aio_load_limited);
our $VERSION = '0.01';

sub aio_load_limited($$\@$) {
    my ($group, $limit, $files, $cb) = @_;

    limit $group $limit;
    feed $group sub {
        my $data;
        my $path = shift @$files or return $group->result(1);
        my $pri  = aioreq_pri;
        my $grp  = aio_group sub { $cb->( $_[0] >= 0 ? ($path, $data) : ($path, undef) )};
        add $group $grp;

        aioreq_pri $pri;
        add $grp aio_open $path, IO::AIO::O_RDONLY, 0, sub {
            my $fh = shift or return $grp->result(-1);
            aioreq_pri $pri;
            add $grp aio_read $fh, 0, (-s $fh), $data, 0, sub { $grp->result($_[0]) };
        };
    };
}

1;

__END__

=head1 NAME

IO::AIO::LoadLimited - a tiny IO::AIO extension that allows to load multiple files

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

The function aio_load_limited loads a list of files asynchronously where the number of open filehandles used are limited so you dont hit the hard limit of your operating system.

Perhaps a little code snippet.

    use IO::AIO::LoadLimited;

    my $foo = IO::AIO::LoadLimited->new();
    ...

=head1 EXPORT

IO::AIO::LoadLimited exports aio_load_limited.

=head1 SUBROUTINES

=over

=item aio_load_limited $group, $limit, @files, $cb;

=back

=head1 AUTHOR

Martin Barth, C<< <martin at senfdax.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-io-aio-loadlimited at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IO-AIO-LoadLimited>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IO::AIO::LoadLimited

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=IO-AIO-LoadLimited>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/IO-AIO-LoadLimited>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/IO-AIO-LoadLimited>

=item * Search CPAN

L<http://search.cpan.org/dist/IO-AIO-LoadLimited/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Martin Barth.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

