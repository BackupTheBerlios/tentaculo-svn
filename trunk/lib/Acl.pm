package Acl;
use base 'DBIBase';

use strict;
use Logger;
use General;

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
	my $d = Acl->retrieve(shift);
	return{	id => $d->id,
		name => $d->name, 
		acltype => $d->acltype, 
		aclstring => $d->aclstring, 
	};
}

sub changeAcl{
	shift;
	my $ph = shift;
	my $cd = Acl->retrieve($ph->{cID});
	$cd->name($ph->{cDir}) if $cd;
	$cd->acltype($ph->{cSize}) if $cd;
	return $cd->update if ($cd && General->isChanged(1) && !General->isSwapCreated(0));
	return 0;
}

sub addAcl{
	shift;
	my $ph = shift;
	my $cd = Acl->create({
		name => $ph->{cDir},
		acltype => $ph->{cSize},
	});
	return $cd if ($cd && General->isChanged(1) && !General->isSwapCreated(0));
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

1;
