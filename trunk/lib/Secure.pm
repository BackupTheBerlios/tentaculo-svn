package Secure;
# This module execs all the commands that need root privs.

use strict;
use POSIX;

sub new{
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless($self,$class);
	return $self;
}


sub getRoot{
	POSIX::setuid(0);
	delete @ENV{qw(IFS PATH CDPATH ENV BASH_ENV)};   # Make %ENV safer

}

sub startSquid{
	shift;
	my $start;
	my $uid = POSIX::getuid();
	&getRoot();
	system("/etc/init.d/squid","start","1>out 2>err");
	POSIX::setuid($uid);
	return $start;
}

sub stopSquid{
	shift;
	my $stop;
	my $uid = POSIX::getuid();
	&getRoot();
	system("/etc/init.d/squid","stop") > $stop;
	POSIX::setuid($uid);
	return $stop;
}

1;
