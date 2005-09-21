package Status;

use strict;
use Logger;

sub new{
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless($self,$class);
	return $self;
}

sub load{
	shift;
	my ($c, $s) = @_;

	my $sys = $s->{sys} ? _("controlling squid") : _("not controlling squid");
	$c =~ s/<!-- SYS-STATUS -->/$sys/;

	$c =~ s/<!-- CHANGES -->/$s->{changes}/ if $s->{changes};

	my $squ = $s->{squ} ? _("running") : _("stopped");
	$c =~ s/<!-- SQ-STATUS -->/$squ/;

	return $c;
}

1;
