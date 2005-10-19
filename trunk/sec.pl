#!/usr/bin/perl -wT
# Script that executes root privileged operations.
#

# Always use strict. Application modules are in the 'lib' directory.
use strict;
use lib './lib';

# General system general modules.
use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
$CGI::POST_MAX = 1024 * 100;  	# 100K max. posts
$CGI::DISABLE_UPLOADS = 1;  	# without uploads
use POSIX;
use SessionControl;
use Logger;
use I18N; 
use General;

# Squid vars
my $loc_squ_cfg = "/var/www/html/tentaculo/etc/squid.conf";
my $squ_cfg = "/etc/squid/squid.conf";
my $squ_bin = "/usr/sbin/squid";
my $squ_user = "proxy";

my $cgi = new CGI;
my $sc = SessionControl->new($cgi);
$sc->startSession();		# Start a new session or recover an started one.

if ( $sc->isLoggedIn() ){
	my $uid = POSIX::getuid();
	my $act = $cgi->url_param('act') || 'status';
	my $stat = { cha => 0, squ => 0};

	Logger->message("sec.pl called. act: $act");
	&getRoot() or die "Can't get root privileges: $!";

	# Compare the files to check if the system is controlling squid.
	my $diff = `diff $loc_squ_cfg $squ_cfg 2>&1`;
	if($diff eq '' && $? == 0){ $stat->{cha} = 0; } 
	else { $stat->{cha} = 1; }

	# Is squid running?
	$stat->{squ} = 1 if `pgrep squid`;

	$sc->param('status', $stat);

	if($act eq 'restart') {
		my $res = { file => '', act => ''};

		# Make a backup the first time.
		`cp $squ_cfg $squ_cfg.tent` if (-e $squ_cfg && !-e $squ_cfg."tent");

		# An easy way: copy the configuration file and reload/start squid.
		`cp -v $loc_squ_cfg $squ_cfg`;
		if ($? == 0){ 
			$res->{file} .= _("Squid configuration file copied succesfully."); 
			Logger->message("Conf file copied");
		} else { $res->{file} .= _("Errors copying the squid configuration file: $!"); }

		# If squid is running, reconfigure it.
		if ($stat->{squ} == 1){ 
			my $rec = `$squ_bin -k reconfigure 2>&1`; 
			if ($? == 0){ 
				$res->{act} .= _("Configuration reloaded succesfully. ");  
				Logger->message("Squid reconfigured");
			} else { $res->{act} .= _("Errors reloading the configuration: $!. "); }
			$res->{act} .= _("Command output:").$rec."\n" if $rec;
		}

		# If squid is stopped, start it.
		elsif ($stat->{squ} == 0) {  
			my $rec .= `/etc/init.d/squid start 2>&1`; 
			if ($? == 0){ $res->{act} .= _("Squid started succesfully. ");  } 
			else { $res->{act} .= _("Error starting squid: $!. ");  }
			$res->{act} .= _("Command output").": $rec" if $rec;
		}

		$sc->param('restart', $res);
	} elsif( $act eq 'swap' ) {
		# Create the swap directories running squid -z
		`/etc/init.d/squid stop; $squ_bin -z`;
		General->isSwapCreated(1) if  $? == 0;
	}
	&holdRoot($uid) or die "Can't hold root privileges";
} else {
	# An error. This script should not be called without being logged in.
	Logger->error("sec.pl: the user is  not logged in. This should not happen!"); die $!;
}

$sc->flush();
Logger->message("Redirecting to index.pl");
print $cgi->redirect("index.pl");

sub getRoot{
	POSIX::setuid(0) or Logger->message($!);
	delete @ENV{qw(IFS PATH CDPATH ENV BASH_ENV)};   # Make %ENV safer
	return 1 if POSIX::getuid() == 0;
	return 0;
}

sub holdRoot{
	my $uid = shift;
	POSIX::setuid($uid);
	return 1 if POSIX::getuid() == $uid;
	return 0;
}
