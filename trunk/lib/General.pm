package General;
use base 'DBIBase';

use strict;
use Logger;
use Template;
use Data::Types qw(:int);

General->table('general');
General->columns(All => qw/id changed swap http_port visible_hostname append_domain icp_port cache_mem/);

sub new{
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless($self,$class);
	return $self;
}

sub getGeneral{
	shift;
	my $g = General->retrieve(1);
	return {
		http_port 	 => 	$g->http_port,
		visible_hostname =>	$g->visible_hostname,
		append_domain	 =>	$g->append_domain,
		icp_port	 => 	$g->icp_port,		
	} if $g;
}

sub getCacheMem{
	shift;
	my $g = General->retrieve(1);
	return $g->cache_mem if $g;
}

sub change{
	shift;
	my $ph = shift;
	my $g = General->retrieve(1);
	if ($g){
		$g->http_port($ph->{gHPort});
		$g->visible_hostname($ph->{gName});
		$g->append_domain($ph->{gDomain});
		$g->icp_port($ph->{gIPort});
		return $g->update if General->isChanged(1);
	}
	return 0;
}

sub validate{
	shift;
	my $ph = shift;
	my @tags;		# Invalid tags

	# gHPort must be an integer between 1 and 65535
	my $gHPort = $ph->{gHPort};
	if($gHPort =~ /^\d+$/){
		$gHPort = to_int($gHPort);
		push(@tags,'gHPort') if ($gHPort < 1 || $gHPort > 65535);
	} else { push(@tags,'gHPort'); }

	# gIPort must be an integer between 1 and 65535 or empty
	my $gIPort = $ph->{gIPort};
	if($gIPort =~ /^\d+$/){
		$gIPort = to_int($gIPort);
		push(@tags,'gIPort') if ($gIPort < 1 || $gIPort > 65535);
	} else { push(@tags,'gIPort') if $gIPort ne ''; }

	# Regexp to match valid domain or host names.
	my $name_regexp = '	^([a-zA-Z0-9]
					([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])
				?\.)*
				[a-zA-Z0-9]*
				([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?$
			  ';
	# gName must be a valid hostname or empty
	push(@tags,'gName') if ($ph->{gName} !~ /$name_regexp/x);
	push(@tags,'gDomain') if ($ph->{gDomain} !~ /$name_regexp/x);

	return \@tags if @tags;
	return 0;
}

sub changeCacheMem{
	shift;
	my $ph = shift;
	my $g = General->retrieve(1);
	$g->cache_mem($ph->{cMem});
	return $g->update if General->isChanged(1);
	return 0;
}

sub isChanged{
	shift;
	my $var;
	$var = shift if @_;		# method called with a param.		
	my $g = General->retrieve(1);
	if (defined($var) && ($var == 1 || $var == 0)){
		$g->changed($var);
		$g->update;
	} 
	return $g->changed();
}

sub isSwapCreated{
	shift;
	my $var;
	$var = shift if @_;		# method called with a param.		
	my $g = General->retrieve(1);
	if (defined($var) && ($var == 1 || $var == 0)){
		$g->swap($var);
		$g->update;
	} 
	return $g->swap();
}

sub load{
	shift;
	my ($c,$tags) = @_;
	my $s = &getGeneral();
	$c =~ s/name="gHPort"/name="gHPort" value="$s->{http_port}"/ if $s->{http_port};
	$c =~ s/name="gIPort"/name="gIPort" value="$s->{icp_port}"/ if $s->{icp_port};
	$c =~ s/name="gName"/name="gName" value="$s->{visible_hostname}"/ if $s->{visible_hostname};
	$c =~ s/name="gDomain"/name="gDomain" value="$s->{append_domain}"/ if $s->{append_domain};
	# Look for errors and change the class
	if ($tags) {
		foreach (@{$tags}){
			$c =~ s/label for="gHPort"/label class="invalid" for="gHPort"/ if $_ eq 'gHPort';	
			$c =~ s/label for="gIPort"/label class="invalid" for="gIPort"/ if $_ eq 'gIPort';	
			$c =~ s/label for="gName"/label class="invalid" for="gName"/ if $_ eq 'gName';
			$c =~ s/label for="gDomain"/label class="invalid" for="gDomain"/ if $_ eq 'gDomain';
		}
			my $m = '<div id="sectForm"><p class="invalid">'._("There were errors procesing the form. Please check the marked values.")."</p></div>";
			$c =~ s/<!-- MESSAGE -->/$m/;
	}
	return $c;
}

sub result{
	shift;
	my ($r, $sub) = @_;
	my ($t, $m);
	my $res = Template->read('result');
	if ($r){ 
		$t = _('Successful change'); 
		$m = _('The general configuration has been changed successfully.');
	} else { 
		$t = _('Unsuccessful change'); 
		$m = _('There was a problem trying to apply the changes. Please try again.')
	}
	$res =~ s/<!-- TITLE -->/$t/;
	$res =~ s/<!-- MESSAGE -->/$m/;
	$res =~ s/SECTION/general/g;
	return $res;
}

1;
