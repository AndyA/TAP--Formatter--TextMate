package TAP::Formatter::TextMate::Session;

use strict;
use TAP::Base;
use HTML::Tiny;
use URI::file;

our $VERSION = '0.1';
use base 'TAP::Formatter::Console::Session';

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

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );
    $self->{queue} = [];
    return $self;
}

=head3 C<header>

Output test preamble

=cut

sub header {
    my $self = shift;
    my $html = $self->_html;
    # print $html->open( 'div', { class => 'test' } ), "\n",
    #   $html->h1( $self->name ), "\n";
    $self->SUPER::header;

}

=head3 C<result>

Called by the harness for each line of TAP it receives.

=cut

# See: http://macromates.com/blog/2005/html-output-for-commands/
sub _link_to_location {
    my ( $self, $file, $line ) = @_;

    return 'txmt://open?'
      . $self->_html->query_encode(
        {
            url => URI::file->new_abs( $file ),
            defined $line ? ( line => $line ) : ()
        }
      );
}

sub _flush_item {
    my $self      = shift;
    my $queue     = $self->{queue};
    my $html      = $self->_html;
    my $formatter = $self->formatter;

    # Get the result...
    my $result = shift @$queue;

    $self->SUPER::result( $result );

    if ( $result->is_test && !$result->is_ok ) {
        my %def = ( file => $self->{test}, );
        if ( @$queue && $queue->[0]->is_yaml ) {
            my $yaml = shift @$queue;
            my $data = $yaml->data;
            %def = ( %def, %$data ) if 'HASH' eq ref $data;
        }
        my $link = $self->_link_to_location( $def{file}, $def{line} );
        $formatter->_newline;
        print $html->span( { class => 'fail' },
            [ $result->raw, ' (', [ \'a', { href => $link }, 'go' ], ')' ] ),
          $html->br, "\n";
    }

}

sub result {
    my ( $self, $result ) = @_;
    my $queue = $self->{queue};
    push @$queue, $result
      unless $result->is_comment || $result->is_unknown;
    $self->_flush_item if @$queue > 1;
}

=head3 C<close_test>

Called to close a test session.

=cut

sub close_test {
    my $self  = shift;
    my $queue = $self->{queue};
    $self->_flush_item while @$queue;
    $self->SUPER::close_test;
}

sub _html {
    my $self = shift;
    return $self->{_html} ||= HTML::Tiny->new;
}

sub _should_show_count { 0 }

1;
