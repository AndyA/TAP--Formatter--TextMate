package TAP::Formatter::TextMate::Session;

use strict;
use TAP::Base;
use HTML::Tiny;
use URI::file;

our $VERSION = '0.1';

=head1 NAME

TAP::Formatter::TextMate::Session - Harness output delegate for TextMate output

=head1 VERSION

Version 0.1

=cut

$VERSION = '0.1';

=head1 DESCRIPTION

This provides output formatting for TAP::Harness.

=head1 SYNOPSIS

=cut

=head1 METHODS

=head2 Class Methods

=head3 C<new>

Make a new TAP::Formatter::TextMate::Session.

=cut

sub new {
    my ( $class, $test, $parser ) = @_;
    return bless {
        test   => $test,
        parser => $parser,
        queue  => [],
        html   => HTML::Tiny->new
    }, $class;
}

=head3 C<header>

Output test preamble

=cut

sub header {
    my $self = shift;
    my $html = $self->{html};
    print $html->open( 'div', { class => 'test' } ), "\n",
      $html->h1( $self->{test} ), "\n";

}

=head3 C<result>

Called by the harness for each line of TAP it receives.

=cut

# See: http://macromates.com/blog/2005/html-output-for-commands/
sub _link_to_location {
    my ( $self, $file, $line ) = @_;

    return 'txmt://open?'
      . $self->{html}->query_encode(
        {
            url => URI::file->new_abs( $file ),
            defined $line ? ( line => $line ) : ()
        }
      );
}

sub _flush_item {
    my $self  = shift;
    my $queue = $self->{queue};
    my $html  = $self->{html};

    # Get the result...
    my $result = shift @$queue;

    my %def = ( file => $self->{test}, );
    if ( @$queue && $queue->[0]->is_yaml ) {
        my $yaml = shift @$queue;
        my $data = $yaml->data;
        %def = ( %def, %$data ) if 'HASH' eq ref $data;
    }

    if ( $result->is_test && !$result->is_ok ) {
        my $class = $result->is_ok ? 'pass' : 'fail';
        my @out = ( $result->raw );
        unless ( $result->is_ok ) {
            my $link = $self->_link_to_location( $def{file}, $def{line} );
            push @out, ' (', [ \'a', { href => $link }, 'go' ], ')';
        }
        print $html->span( { class => $class }, \@out ), $html->br, "\n";
    }

}

sub result {
    my ( $self, $result ) = @_;
    my $queue = $self->{queue};
    push @$queue, $result unless $result->is_comment;
    $self->_flush_item if @$queue > 1;
}

=head3 C<close_test>

Called to close a test session.

=cut

sub close_test {
    my $self   = shift;
    my $html   = $self->{html};
    my $parser = $self->{parser};
    my $queue  = $self->{queue};
    $self->_flush_item while @$queue;

    my ( $status, $class )
      = $parser->has_problems
      ? ( 'FAIL', 'summary-fail' )
      : ( 'PASS', 'summary-pass' );

    print $html->div(
        { class => $class },
        [
            "$status: ",
            $parser->tests_run,
            ' tests run, ',
            scalar $parser->passed,
            ' passed, ',
            scalar $parser->failed,
            ' failed'
        ]
      ),
      $html->close( 'div' ), "\n";
}

1;
