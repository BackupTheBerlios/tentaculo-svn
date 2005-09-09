package Template;

use strict;
use Logger;
use I18N;

sub read{
	shift;
	my $file = "templates/".I18N->getLanguage()."/".shift().".html";
	Logger->message("file: $file");
	open(FILE,"<$file") or die "Could not open file ".$file."Error: ".$!;
	my @content=<FILE>;
	close(FILE);
	return join("",@content);
}

sub result{
	shift;
	my ($r, $sect, $sub) = @_;
	my ($t, $m);
	my $res = Template->read('result');

	if ($r){ 
		$t = _('Successful change'); 
		if ($sect eq 'general'){
			$m = _('The General Configuration has been changed successfully.');
		} elsif ($sect eq 'cache'){
			$m = _('The Cache Configuration has been changed successfully.');
		} elsif ($sect eq 'settings'){
			$m = _('The settings has been changed successfully.');
			if ($sub eq 'password'){
				$m .= _(' The password has been changed successfully.');
			}
		}
	} else { 
		$t = _('Unsuccessful change'); 
		$m = _('There was a problem trying to apply the changes. Please try again.')
	}
	$res =~ s/<!-- TITLE -->/$t/;
	$res =~ s/<!-- MESSAGE -->/$m/;
	$res =~ s/SECTION/$sect/g;
	return $res;
}

sub loadGeneral{
	shift;
	my ($c,$s) = @_;
	$c =~ s/name="gEnable"/name="gEnable" checked="checked"/ if $s->{enable};
	$c =~ s/name="gHPort"/name="gHPort" value="$s->{http_port}"/ if $s->{http_port};
	$c =~ s/name="gName"/name="gName" value="$s->{visible_hostname}"/ if $s->{visible_hostname};
	$c =~ s/name="gDomain"/name="gDomain" value="$s->{append_domain}"/ if $s->{append_domain};
	$c =~ s/name="gIPort"/name="gIPort" value="$s->{icp_port}"/ if $s->{icp_port};
	return $c;
}

sub loadCache{
	shift;
	my ($c,$mem,$cda) = @_;		# $cda = cache dirs array
	$c =~ s/name="cMem"/name="cMem" value="$mem"/ if $mem;
	if ($cda){
		my ($dirs, $dt) = (Template->read('cache_table'), Template->read('cache_row'));
		foreach my $d (@{$cda}){  $dirs .= Template->loadCacheRow($dt, $d);  }
		$dirs .= Template->read('cache_table_end');
		$c =~ s/<!-- CACHE_DIRS -->/$dirs/;
	}
	return $c;
}

sub loadCacheRow{
	shift;
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

sub loginError{
	shift;
	my $p = shift;
	my $e = _('Username and/or password incorrect');
	$p =~ s/<!-- ERROR -->/$e/; 
	return $p;
}

1;
