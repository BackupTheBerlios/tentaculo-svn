package Status;

use strict;
use Logger;
use General;

sub new{
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless($self,$class);
	return $self;
}

sub load{
	shift;
	my ($c, $s, $r) = @_;

	my $sys = _("Not applied changes. Restart squid and apply the changes.") if $s->{cha} == 1;
	$c =~ s/<!-- CHANGES -->/$sys/ if $sys;

	my $squ = $s->{squ} ? _("running") : _("stopped");
	$c =~ s/<!-- SQ-STATUS -->/$squ/;
	
	my $swap = "NO" unless General->isSwapCreated();
	$c =~ s/<!-- SWAP -->/$swap/ if $swap;
	
	if($r){
		my $title = "<h2>"._("Squid restart results")."</h2>";
		$c =~ s/<!-- RES-TITLE -->/$title/;
		$c =~ s/<!-- RES-FILE -->/$r->{file}/ if $r->{file};
		$c =~ s/<!-- RES-ACT -->/$r->{act}/ if $r->{act};
	}

	return $c;
}

1;
