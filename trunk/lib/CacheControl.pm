package CacheControl;

use strict;
use General;
use Cache_Dir;

sub new{
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless($self,$class);
	return $self;
}

sub getMem{
	my $self = shift;
	return General->getCacheMem(); 
}

sub getDirs{
	my $self = shift;
	return Cache_Dir->getAll(); 
}

sub changeMem{
	my $self = shift;
	return General->changeCacheMem(shift);
}

sub getDir{
	my $self = shift;
	return Cache_Dir->getCachedir(shift); 
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

1;
