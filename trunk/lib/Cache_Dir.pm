package Cache_Dir;
use base 'DBIBase';

use strict;
use Logger;
use General;

Cache_Dir->table('cache_dir');
Cache_Dir->columns(All => qw/id directory size/);

sub getAll{
	shift;
	my @dirs;
	foreach my $d (Cache_Dir->retrieve_all){
		push @dirs, { id => $d->id, directory => $d->directory, size => $d->size, };
	}
	return \@dirs if @dirs;
	return 0;
}

sub getCachedir{
	shift;
	my $d = Cache_Dir->retrieve(shift);
	return { id => $d->id, directory => $d->directory, size => $d->size} if $d;
}

sub changeCachedir{
	shift;
	my $ph = shift;
	my $cd = Cache_Dir->retrieve($ph->{cID});
	$cd->directory($ph->{cDir}) if $cd;
	$cd->size($ph->{cSize}) if $cd;
	return $cd->update if ($cd && General->isChanged(1) && !General->isSwapCreated(0));
	return 0;
}

sub addCachedir{
	shift;
	my $ph = shift;
	my $cd = Cache_Dir->create({
		directory => $ph->{cDir},
		size => $ph->{cSize},
	});
	return $cd if ($cd && General->isChanged(1) && !General->isSwapCreated(0));
	return 0;
}

sub delCachedir{
	shift;
	my $d = Cache_Dir->retrieve(shift);
	return $d->delete() if ($d && General->isChanged(1) && !General->isSwapCreated(0));
	return 0;
}

1;
