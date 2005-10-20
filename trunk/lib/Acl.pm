package Acl;
use base 'DBIBase';

use strict;
use Logger;
use General;
use Data::Types qw(:int);

Acl->table('acl');
Acl->columns(All => qw/id name acltype aclstring/);

sub new{
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless($self,$class);
	return $self;
}

sub getAll{
	shift;
	my @acls;
	foreach my $d (Acl->retrieve_all){
		push @acls, { 	id => $d->id, 
				name => $d->name, 
				acltype => $d->acltype, 
				aclstring => $d->aclstring, 
		};
	}
	return \@acls if @acls;
	return 0;
}

sub getAcl{
	shift;
	my $a = Acl->retrieve(shift);
	return{	id => $a->id,
		name => $a->name, 
		acltype => $a->acltype, 
		aclstring => $a->aclstring, 
	} if $a;
	return 0;
}

sub changeAcl{
	shift;
	my $ph = shift;
	my $dir = Acl->retrieve($ph->{cID});
	$dir->name($ph->{aName}) if $dir;
	$dir->acltype($ph->{aType}) if $dir;
	$dir->aclstring($ph->{aString}) if $dir;
	return $dir->update if ($dir && General->isChanged(1));
	return 0;
}

sub addAcl{
	shift;
	my $ph = shift;
	my $acl = Acl->create({
		name => $ph->{aName},
		acltype => $ph->{aType},
		aclstring => $ph->{aString},
	});
	return $acl if ( $acl && General->isChanged(1) );
	return 0;
}

sub delAcl{
	shift;
	my $d = Acl->retrieve(shift);
	return $d->delete() if ($d && General->isChanged(1) && !General->isSwapCreated(0));
	return 0;
}

sub load{
	shift;
	my ($c, $tags) = @_;
	my $aa = Acl->getAll;

	if ($aa){
		my $acls;
		my $row = Template->read('acl_row');
		foreach my $acl (@{$aa}){ $acls .= &loadRow($row, $acl); }
		$c =~ s/<!-- ACLS -->/$acls/;
	} else {
		my $no_acl = _("There are not ACLs configured.");
		$c =~ s/<!-- NO_ACL -->/$no_acl/;
	}
	return $c;
}

sub loadRow{
	my ($row,$acl) = @_;
	$row =~ s/ID/$acl->{id}/g;
	$row =~ s/<!-- NAME -->/$acl->{name}/;
	$row =~ s/<!-- ACLTYPE -->/$acl->{acltype}/;
	$row =~ s/<!-- ACLSTRING -->/$acl->{aclstring}/;
	return $row;
}

sub newAcl{
	my ($self, $tags) = @_;
	my $c = Template->read('newAcl');
	if ($tags){
		my $m = _("There was errrors validating the data for the new cache directory.");
		foreach (@{$tags}){
			$m .= _(" The entered name seems to be wrong.") if $_ eq 'aName';	
			$m .= _(" The entered type seems to be wrong.") if $_ eq 'aType';	
			$m .= _(" The entered string seems to be wrong.") if $_ eq 'aString';	
		}
		$c =~ s/<!-- MESSAGE -->/$m/;
	}
	return $c;
}

sub result{
	shift;
	my $r = @_;
	my ($t, $m);
	my $res = Template->read('result');
	if ($r){ 
		$t = _('Successful change'); 
		$m = _('The ACL Configuration has been changed successfully.');
	} else { 
		$t = _('Unsuccessful change'); 
		$m = _('There was a problem trying to apply the changes. Please try again.')
	}
	$res =~ s/<!-- TITLE -->/$t/;
	$res =~ s/<!-- MESSAGE -->/$m/;
	$res =~ s/SECTION/acl/g;
	return $res;
}

sub validateAcl{
	shift;
	my $ph = shift;
	my @tags;		# Invalid tags

	# The name must be a word.
	push(@tags,'aName') unless $ph->{aName} =~ /\w/;

	# The type must be one of src, dst, port or proto.
	push(@tags,'aType') unless $ph->{aType} =~ /src|dst|port|proto/;

	# The string depends on the type.
	if($ph->{aType} eq 'src' or $ph->{aType} eq 'dst'){
		# If src or dst, the string must be an IP address or network.
		my $regexp =    '^((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.){3}
				(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])
				(\/(((0|255)\.){3}(0|128|255)|\d{1,2}))?$';
		push(@tags,'aString') unless $ph->{aString} =~ /$regexp/x;
	} elsif ($ph->{aType} eq 'port') {
		my $port = $ph->{aString};
		if($port =~ /^\d+$/){
			$port = to_int($port);
			push(@tags,'aString') if ($port < 1 || $port > 65535);
		} else { push(@tags,'aString'); }
	} elsif ($ph->{aType} eq 'proto'){
		push(@tags,'aString') unless $ph->{aString} =~ /(cache_object|http|ftp)/;
	}

	return \@tags if @tags;
	return 0;
}

1;
