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

IO::AIO::LoadLimited - A tiny IO::AIO extension that allows to load multiple files

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use strict;
    use warnings;
    use IO::AIO;
    use IO::AIO::LoadLimited;

    my @files = (...);
    my $grp = aio_group sub { ... };
    aio_load_limited $grp, 10, @files, sub {
        my ($file, $content) = @_;

        warn "could not read $file: $!" unless defined $content;
        # whatever is neccessary...
        ...
    };

=head1 EXPORT

IO::AIO::LoadLimited exports aio_load_limited.

=head1 SUBROUTINES

=over

=item aio_load_limited $group, $limit, @files, $cb;

The function aio_load_limited loads a list of files asynchronously where the number of open filehandles used are limited so you don't hit the hard limit of your operating system. The limit is archived using the group and limit functionality of C<IO::AIO>. The callback $cb gets invoked once for each file with the filename as the first parameter and the content of the file as the second. If the file can not be opened or read the content is C<undef>.

=back

=head1 SEE ALSO

=over

=item L<IO::AIO>

=back

=head1 AUTHOR

Martin Barth, C<< <martin at senfdax.de> >>

=head1 BUGS

Please report any bugs or feature requests to
L<https://github.com/ufobat/p5-IO-AIO-LoadLimited/issues>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IO::AIO::LoadLimited

You can also look for information at:

=over 4

=item * Github: issue and request tracker (report bugs here)

L<https://github.com/ufobat/p5-IO-AIO-LoadLimited/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/IO-AIO-LoadLimited>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/IO-AIO-LoadLimited>

=item * Search CPAN

L<http://search.cpan.org/dist/IO-AIO-LoadLimited/>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to M.Lehmann for IO::AIO and thanks to L<www.netdescribe.com>.

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Martin Barth.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

