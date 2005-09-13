package Cache;

use strict;
use Logger;
use Template;
use General;
use Cache_Dir;
use Cache_Peer;

sub new{
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless($self,$class);
	return $self;
}

sub changeDir{
	my $self = shift;
	Cache_Dir->changeCachedir(shift);
}

sub addDir{
	my $self = shift;
	return Cache_Dir->addCachedir(shift);
}

sub delDir{
	my $self = shift;
	Cache_Dir->delCachedir(shift);
}

sub newDir{
	my ($self, $tags) = @_;
	my $c = Template->read('newCachedir');
	if ($tags){
		my $m = _("There was errrors validating the data for the new cache directory.");
		foreach (@{$tags}){
			$m .= _(" The entered path seems to be wrong.") if $_ eq 'cDir';	
			$m .= _(" The entered size seems to be wrong.") if $_ eq 'cSize';	
		}
		$c =~ s/<!-- MESSAGE -->/$m/;
	}
	return $c;
}

sub validateDir{
	shift;
	my $ph = shift;
	my @tags;		# Invalid tags

	# cDir must be a valid system directory.
	push(@tags,'cDir') unless -d $ph->{cDir};

	# cSize must be an integer.
	my $csize = $ph->{cSize};
	push(@tags,'cSize') unless $csize =~ /^\d+$/;
	
	# TODO: cDir must be empty and its filesystem must have cSize free bytes.

	return \@tags if @tags;
	return 0;
}

sub getPeer{
	my $self = shift;
	return Cache_Peer->getCachepeer(shift); 
}

sub getPeers{
	my $self = shift;
	return Cache_Peer->getAll(); 
}

sub changePeer{
	my $self = shift;
	Cache_Peer->changeCachepeer(shift);
}

sub addPeer{
	my $self = shift;
	return Cache_Peer->addCachepeer(shift);
}

sub delPeer{
	my $self = shift;
	Cache_Peer->delCachepeer(shift);
}

sub load{
	shift;
	my $c = shift;
	my $mem = General->getCacheMem;
	my $cda = Cache_Dir->getAll;
	$c =~ s/name="cMem"/name="cMem" value="$mem"/ if $mem;
	if ($cda){
		my ($table, $row) = (Template->read('cache_table'), Template->read('cache_row'));
		foreach my $d (@{$cda}){  $dirs .= &loadCacheRow($dt, $d);  }
		#$dirs .= Template->read('cache_table_end');
		$c =~ s/<!-- CACHE_DIRS -->/$dirs/;
	} else {
		my $no_dir = "<p>"._("There are not cache directories configured.")."</p>";
		$no_dir .= '<div id="sectForm"><p><a href="index.pl?sect=cache&sub=dir&act=new">'._("Agregar nuevo directorio de Cache").'</a></p></div>';
		$c =~ s/<!-- CACHE_DIRS -->/$no_dir/;
	}
	return $c;
}

sub loadCacheRow{
	my ($dt,$d) = @_;
	$dt =~ s/ID/$d->{id}/g;
	$dt =~ s/<!-- DIR -->/$d->{directory}/;
	$dt =~ s/<!-- SIZE -->/$d->{size}/;
	return $dt;
}

sub loadCachedir{
	shift;
	my ($c,$d) = @_;
	$c =~ s/name="cID"/name="cID" value="$d->{id}"/ if $d->{id};
	$c =~ s/name="cDir"/name="cDir" value="$d->{directory}"/ if $d->{directory};
	$c =~ s/name="cSize"/name="cSize" value="$d->{size}"/ if $d->{size};
	return $c;
}

sub result{
	shift;
	my ($r, $sub) = @_;
	my ($t, $m);
	my $res = Template->read('result');
	if ($r){ 
		$t = _('Successful change'); 
		$m = _('The Cache Configuration has been changed successfully.');
	} else { 
		$t = _('Unsuccessful change'); 
		$m = _('There was a problem trying to apply the changes. Please try again.')
	}
	$res =~ s/<!-- TITLE -->/$t/;
	$res =~ s/<!-- MESSAGE -->/$m/;
	$res =~ s/SECTION/cache/g;
	return $res;
}


1;
