package Cache_Peer;
use base 'DBIBase';

use strict;
use Logger;

Cache_Peer->table('cache_peer');
Cache_Peer->columns(All => qw/id address http_port icp_port/);

sub getAll{
	shift;
	my @peers;
	foreach my $p (Cache_Peer->retrieve_all){
		push @peers, { id => $p->id, address => $p->directory, http_port => $p->http_port, cp_port => $p->icp_port, };
	}
	return \@peers;
}

sub getCachepeer{
	shift;
	my $p = Cache_Peer->retrieve(shift);
	return { id => $p->id, address => $p->directory, http_port => $p->http_port, cp_port => $p->icp_port, } if $p;
}

sub changeCachedir{
	shift;
	my $ph = shift;
	my $cd = Cache_Peer->retrieve($ph->{cID});
	$cd->directory($ph->{cPeer});
	$cd->size($ph->{cSize});
	return $cd->update;
}

sub addCachedir{
	shift;
	my $ph = shift;
	return Cache_Peer->create({
		directory => $ph->{cPeer},
		size => $ph->{cSize},
	});
}

sub delCachedir{
	shift;
	my $p = Cache_Peer->retrieve(shift);
	return $p->delete() if $p;
}

1;
