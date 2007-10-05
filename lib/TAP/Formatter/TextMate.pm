package TAP::Formatter::TextMate;

use warnings;
use strict;
use Carp;
use TAP::Formatter::TextMate::Session;

our $VERSION = '0.1';

=head1 NAME

TAP::Formatter::TextMate - Generate TextMate compatible test output

=head1 VERSION

This document describes TAP::Formatter::TextMate version 0.1

=head1 SYNOPSIS

Create a TextMate command that looks something like this:

    test=''
    opts='-rb'
    if [ ${TM_FILEPATH:(-2)} == '.t' ] ; then
        test=$TM_FILEPATH
        opts='-b'
    fi
    cd $TM_PROJECT_DIRECTORY && prove --merge --formatter TAP::Formatter::TextMate $opts $test
  
=head1 DESCRIPTION

Generates TextMate compatible HTML test output.

=head1 INTERFACE 

=head2 C<< new >>

Create a new C<< TAP::Formatter::TextMate >>.

=cut

sub new {
    my ( $class ) = @_;
    return bless { html => HTML::Tiny->new }, $class;
}

=head2 C<prepare>

Called by Test::Harness before any test output is generated. 

=cut

sub prepare {
    my ( $self, @tests ) = @_;
    my $html = $self->{html};
    print $html->open( 'html' ),
      $html->head( [ \'style', $self->_stylesheet ] ), $html->open( 'body' ),
      "\n";
}

=head3 C<open_test>

Called to create a new test session.

=cut

sub open_test {
    my ( $self, $test, $parser ) = @_;

    my $session = TAP::Formatter::TextMate::Session->new( $test, $parser );
    $session->header;

    return $session;
}

=head3 C<summary>

  $harness->summary( $aggregate );

C<summary> prints the summary report after all tests are run.  The argument is
an aggregate.

=cut

sub summary {
    my ( $self, $aggregate ) = @_;
    my $html = $self->{html};
    print $html->close( 'body' ), $html->close( 'html' ), "\n";
}

sub _stylesheet {
    return <<CSS;

h1 {
    margin: 0px;
    padding: 0px;
    padding-bottom: 4px;
    font-size: 1.1em;
}

.test {
    border: 1px dotted gray;
    margin: 2px;
    padding: 4px;
}

.pass {
}

.fail {
    color: red;
}

.summary-pass, .summary-fail {
    font-weight: bold;
}

.summary-fail {
    color: red;
}

CSS
}

1;
__END__

=head1 CONFIGURATION AND ENVIRONMENT
  
TAP::Formatter::TextMate requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-tap-formatter-textmate@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Andy Armstrong  C<< <andy@hexten.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Andy Armstrong C<< <andy@hexten.net> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
