#!/usr/bin/perl -wT
# Script that executes root privileged operations.
#

# Always use strict. Application modules are in the 'lib' directory.
use strict;
use lib './lib';

# General system general modules.
use CGI;
use POSIX;
use SessionControl;
use Logger;

my $cgi = new CGI;
my $sc = SessionControl->new($cgi);
$sc->startSession();		# Start a new session or recover an started one.
my $scf = "/etc/squid/squid.conf";

if ( $sc->isLoggedIn() ){
	my $uid = POSIX::getuid();
	my $act = $cgi->url_param('act');
	my $stat = $sc->param('status');

	if($act && $act eq 'status'){
		my $s = { sys => 0, squ => 0};
		&getRoot() or Logger->error("Can't get root privileges");
		# Compare the files to check if the system is controlling squid.
		$s->{sys} = 1 unless `diff etc/squid.conf $scf`;
		# Is squid running?
		$s->{squ} = 1 if `pgrep squid`;
		&holdRoot($uid) or die "Can't hold root privilegs";
		$sc->param('status', $s);
	} elsif($act && $act eq 'restart') {
		&getRoot() or Logger->error("Can't get root privileges");
		# Make a backup the first time.
		`cp $scf $scf.tent` if (-e $scf && !-e $scf."tent");
		# An easy way: copy the configuration file and reload/start squid.
		my $res = `cp -v etc/squid.conf $scf;`;
		if ($stat && $stat->{squ}){ $res .= `squid -k reconfigure`; } # running, just reload
		else {  $res .= `/etc/init.d/squid start`; }
		&holdRoot($uid) or die "Can't hold root privileges";
		Logger->message("Restarting squid result: $res");
		$sc->param('restart', $res);
	}
} else {
	# An error. This script should not be called without being logged in.
	Logger->error("sec.pl: the user is  not logged in. This should not happen!"); die $!;
}

print $cgi->redirect("index.pl");

sub getRoot{
	shift;
	POSIX::setuid(0) or Logger->message($!);
	delete @ENV{qw(IFS PATH CDPATH ENV BASH_ENV)};   # Make %ENV safer
	return 1 if POSIX::getuid() == 0;
	return 0;
}

sub holdRoot{
	shift;
	my $uid = shift;
	POSIX::setuid($uid);
	return 1 if POSIX::getuid() == $uid;
	return 0;
}
