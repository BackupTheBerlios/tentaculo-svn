#!/usr/bin/perl -w -T
# Main script.
#

# Always use strict. Application modules are in the 'lib' directory.
use strict;
use lib './lib';

# CGI stuff.
use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
$CGI::POST_MAX = 1024 * 100;  	# 100K max. posts
$CGI::DISABLE_UPLOADS = 1;  	# without uploads
my $cgi = new CGI;
my $phr = $cgi->Vars;		# All (p)arams (h)ash (r)eference

# General system general modules.
use AccessControl;
use Logger;
use Template;
my $ac = AccessControl->new($cgi);
$ac->startSession();		# Start a new session or recover an started one.

# Per-section modules and their objects.
use General;
use Cache;
my $gen = General->new();
my $cach = Cache->new();

# HTML Page variables. t = template. c = content (or template fill).
my ($t,$c);

# Start to check user and process status and petitions.
if ( $ac->isLoggedIn() ){
	# The user is logged in. Get the principal params.
	my $sect = $phr->{'sect'} || $cgi->url_param('sect') || 'status';
	my $sub = $phr->{'sub'} || $cgi->url_param('sub') || '';
	my $act = $phr->{'act'} || $cgi->url_param('act') || '';

	Logger->message("index.pl vars sect: $sect sub: $sub act: $act");
	
	# Valid content sections
	my @csects = qw/general cache settings status/;

	# The admin page is the interface template used when the user is logged in.
	$t = Template->read('admin');

	# Read the template if the sect param is a valid content page.	
	for (@csects) {  if ($sect eq $_) { $c = Template->read($sect); last; }  }

	# Choose the section and call the proper methods in the control objects.
	if ( $sect eq 'status' ) {
		#-- Status section --#
		if($sub eq 'squid'){
			# squid subsection 
			if ( $act eq 'start' ) {
				$c = Secure->startSquid();
			}
		}	
	} elsif ( $sect eq 'general' ) {
		#-- General section --#
		$c = $gen->load($c) unless $act;
		if ( $act eq 'change' ){
			my $err = $gen->validate($phr);
			$c = $gen->result($gen->change($phr)) unless $err;
			$c = $gen->load($c, $err) if $err;
		}
	} elsif ( $sect eq 'cache' ) {
		#-- Cache section --#
		if($sub eq 'dir'){
			# cache_dir subsection 
			if ( $act eq 'view' ) {
				$c = Template->read('cachedir');
				my $id = $cgi->url_param('id');
				$c = Template->loadCachedir($c, $cach->getDir($id)) if $id;
			} elsif ( $act eq 'change' ) {
				$c = Template->result($cach->changeDir($phr), $sect);
			} elsif ( $act eq 'new' ) {
				$c = $cach->newDir() 
			} elsif ( $act eq 'add' ) {
				my $err = $cach->validateDir($phr);
				$c = $cach->result($cach->addDir($phr)) unless $err;
				$c = $cach->newDir($err) if $err;
			} elsif ( $act eq 'del' ) {
				my $id = $cgi->url_param('id');
				$c = Template->result($cach->delDir($id), $sect) if $id;
			}
		} elsif ( !$sub ) {
			$c = $cach->load($c) unless $act;
			if ( $act eq 'change' ){
				my $err = $cach->validateMem($phr);
				$c = $cach->result($cach->changeMem($phr)) unless $err;
				$c = $cach->load($c, $err) if $err;
			}
		}
	} elsif ( $sect eq 'settings' ) {
		#-- Settings section --#
		if($sub eq 'password'){
			# Password subsection 
			if ( $act eq 'change' ) {
				$c = Template->result($ac->changePass($phr), $sect, $sub);
			}
		}	
	} elsif ( $sect eq 'logout' ) {
		$ac->logOut();
		$t = Template->read('login');	
	}
} else {
	# The user is not logged in
	if ($phr->{'logUser'}) {
		# The user is trying to log in.
		if ( $ac->check($phr) ) {
			# The user logged in.
			$t = Template->read('admin');
			$c = Template->read('status');
		} else {
			# The user failed trying to log in.
			$t = Template->read('login');
			$t = Template->loginError($t);
		}
	} else {
		# Login page.
		$t = Template->read('login');	
	}
} 

$t =~ s/<!-- CONTENT -->/$c/ if $t;

print $cgi->header(-cookie=>$ac->cookie); 
print $t if $t;

Logger->error("The is no page to print!") unless $t;
