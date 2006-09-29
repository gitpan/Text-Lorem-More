package Text::Lorem::More;

use warnings;
use strict;

use Text::Lorem::More::Source;
use Carp;

our $AUTOLOAD;

use constant MAXIMUM_RECURSION => 2 ** 7;
our ($RECURSION, $COUNT, $PRUNE);

our $SOURCE = new Text::Lorem::More::Source;
our %GENERATOR = (
	name => sub { my $tlm = shift; return ucfirst lc $tlm->word },

	fullname => \"+name +name",

	word => [ map { s/\W//g; lc } split m/\s/, <<_END_ ],
alias consequatur aut perferendis sit voluptatem accusantium doloremque aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis Nemo enim ipsam voluptatem quia voluptas sit suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae  et iusto odio dignissimos ducimus qui blanditiis praesentium laudantium, totam rem voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, Sed ut perspiciatis unde omnis iste natus error similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo porro quisquam est, qui minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? At vero eos et accusamus officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores doloribus asperiores repellat.
_END_

	sentence => sub { return ucfirst join(" ", ("+word") x (4 + int rand 6)) . "." },

	paragraph => sub { return join " ", ("+sentence") x (3 + int rand 4) },

	words => sub {
		my $tlm = shift;
		$PRUNE = 1;
		return join " ", ("+word") x $COUNT;
	},

	sentences => sub {
		my $tlm = shift;
		$PRUNE = 1;
		my $count = $COUNT;
		my @sentence;
		while ($count > 0) {
			push @sentence, ucfirst $tlm->words(4 + int rand 6);
			$count--;
		}
		return join(". ", @sentence) . ".";
	},

	paragraphs => sub {
		my $tlm = shift;
		$PRUNE = 1;
		my $count = $COUNT;
		my @paragraph;
		while ($count > 0) {
			push @paragraph, $tlm->sentences(3 + int rand 4);
			$count--;
		}
		return join("\n\n", @paragraph);
	},

	host => "hostname",

	hostname => [ split m/\n/, <<_END_ ],
+word.+domainname
+domainname
_END_

	email => [ split m/\n/, <<_END_ ],
+word\@+hostname
+word\@+domainame
_END_

	mail => "email",

	relativepath => '',
	absolutepath => '',

	path => sub { return join "/", '', ("+word") x (1 + int rand 6) },

	httpurl => [ split m/\n/, <<_END_ ],
http://+hostname+path
http://+hostname:+port+path
_END_
	port => sub { int rand(1 + (2 ** 15)) },

	mailto => \"mailto:+email",

	tld => "topleveldomain",

	topleveldomain => [ split m/\s/, <<_END_ ],
com org net
_END_

	domain => "domainname",

	domainname => [ split m/\n/, <<_END_ ],
example.+tld
_END_
);
$SOURCE->push(\%GENERATOR);

=head1 NAME

Text::Lorem::More - More methods to create a wider variety of Latin-looking text.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 MORE TESTING NEEDED

=head1 MORE DOCUMENTATION NEEDED

=head1 ...but it should work...

=head1 SYNOPSIS

This module is useful for creating random content.

    use Text::Lorem::More;

    my $tlm = Text::Lorem::More->new();

=head1 EXPORT

=head1 FUNCTIONS

=head2 new

=head2 name

=head2 fullname

=head2 generate

=head2 _generate

=cut

sub new {
	my $self = bless {}, shift;
	my $source = shift;
	$source = new Text::Lorem::More::Source if ref $source eq "HASH";
	$source = $SOURCE->copy unless $source;
	$self->{source} = $source;
	return $self;
}

sub generate {
	my $self = shift;
	$RECURSION = 0;
	return $self->_generate(@_);
}

sub _generate {
	my $self = shift;
	my $content = shift;
	my $count = shift;
	my $separator = shift;

	$RECURSION += 1;
	croak "too much recursion on \"$content\"" if $RECURSION >= MAXIMUM_RECURSION;

	$count = 1 unless defined $count;
	$separator = " " unless defined $separator;
	carp "count must be a number, not \"$count\"" if ref $count || $count !~ m/^\d$/;

	local $Text::Lorem::More::COUNT = $count; $COUNT = $COUNT;
	local $Text::Lorem::More::PRUNE = 0;

	my @content;
	while ($count >= 0) {
		local $_ = $content;
		s/\+(\w+)/$self->_replace_pattern($1)/eg;
		push @content, $_ if $Text::Lorem::More::PRUNE;
		last if 0 == $count || $Text::Lorem::More::PRUNE;
		push @content, $_;
		$count--;
	}

#	my @content = map { local $_ = $_; s/\+(\w+)/$self->_replace_pattern($1)/eg; $_ } ($content) x $count;

	return $content[0] if 1 == @content;
	return wantarray ? @content : join $separator, @content;
}

sub _replace_pattern {
	my $self = shift;
	my $pattern = shift;

	my $generatelet = $self->{source}->find($pattern);
	my $content;

	if (ref $generatelet eq "ARRAY") {
		$content = $generatelet->[int rand @$generatelet];
	}
	elsif (ref $generatelet eq "SCALAR") {
		$content = $$generatelet;
	}
	else {
		$content = $generatelet->($self);
	}

	return $self->_generate($content);
}

#sub words { shift and return $tl->words(@_) }

#sub sentences { shift and return $tl->sentences(@_) }

#sub paragraphs { shift and return $tl->paragraphs(@_) }

sub AUTOLOAD {
	my $self = shift;
	my $method = $AUTOLOAD;
	$method =~ s/.*:://;

	if ($self->{source}->find($method)) {
		no strict 'refs';
		*$AUTOLOAD = sub { my $self = shift; $self->generate("+$method", @_) };
		$AUTOLOAD->($self, @_);
	}
}

sub DESTROY {
}

=head1 AUTHOR

Robert Krimen, C<< <robertkrimen at gmail.com> >>

=head1 SEE ALSO

L<Text::Lorem> and L<WWW::Lipsum> and L<http://lipsum.com/>

=head1 ACKNOWLEDGEMENTS

Thanks to Adeola Awoyemi for writing L<Text::Lorem> which was the inspiration
behind this module.

=head1 COPYRIGHT & LICENSE

Copyright 2006 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-text-lorem-more at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-Lorem-More>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::Lorem::More

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-Lorem-More>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-Lorem-More>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Lorem-More>

=item * Search CPAN

L<http://search.cpan.org/dist/Text-Lorem-More>

=back

=cut

1; # End of Text::Lorem::More
