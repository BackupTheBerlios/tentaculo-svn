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
use SessionControl;
use Logger;
use Template;
use SquidControl;
my $sc = SessionControl->new($cgi);
$sc->startSession();		# Start a new session or recover an started one.
my $squc = SquidControl->new();

# Per-section modules and their objects.
use General;
use Cache;
use Status;
my $gen = General->new();
my $cach = Cache->new();
my $stat = Status->new();

# HTML Page variables. t = template. c = content (or template fill).
my ($t,$c);

# Start to check user and process status and petitions.
if ( $sc->isLoggedIn() ){
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
		if(!$act){
			my $s = $sc->param("status");
			my $r = $sc->param("restart");
			print $cgi->redirect("sec.pl?act=status") unless $s;
			$c = $stat->load($c, $s, $r) if $s;
			$sc->clear(["status"]); # clear session params 
		} elsif( $act eq 'restart'){
			print $cgi->redirect("sec.pl?act=restart");
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
		if(!$sub){
			$c = $cach->load($c) unless $act;
			if ( $act eq 'change' ){
				my $err = $cach->validateMem($phr);
				$c = $cach->result($cach->changeMem($phr)) unless $err;
				$c = $cach->load($c, $err) if $err;
			}
		} elsif($sub eq 'dir'){
			# cache_dir subsection 
			if ( $act eq 'view' ) {
				$c = Template->read('cachedir');
				my $id = $cgi->url_param('id');
				$c = $cach->loadCachedir($c, $id) if $id;
			} elsif ( $act eq 'change' ) {
				my ($err, $id) = ($cach->validateDir($phr), $phr->{cID});
				$c = $cach->result($cach->changeDir($phr)) unless $err;
				$c = Template->read('cachedir') if $err;
				$c = $cach->loadCachedir($c, $id, $err) if $id || $err;
			} elsif ( $act eq 'new' ) {
				$c = $cach->newDir();
			} elsif ( $act eq 'add' ) {
				my $err = $cach->validateDir($phr);
				$c = $cach->result($cach->addDir($phr)) unless $err;
				$c = $cach->newDir($err) if $err;
			} elsif ( $act eq 'del' ) {
				my $id = $cgi->url_param('id');
				$c = $cach->result($cach->delDir($id)) if $id;
			}
		}
	} elsif ( $sect eq 'settings' ) {
		#-- Settings section --#
		if($sub eq 'password'){
			# Password subsection 
			if ( $act eq 'change' ) {
				$c = Template->result($sc->changePass($phr), $sect, $sub);
			}
		}	
	} elsif ( $sect eq 'logout' ) {
		$sc->logOut();
		print $cgi->redirect("index.pl");
	}
} else {
	# The user is not logged in
	if ($phr->{'logUser'}) {
		# The user is trying to log in.
		if ( $sc->check($phr) ) {
			# The user logged in.
			print $cgi->redirect('index.pl');
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

# Write the configuration file locally.
$squc->writeFile() if $gen->isChanged() == 1;

# Replace the content in the template and print it if exists, else log an error.
$t =~ s/<!-- CONTENT -->/$c/ if ($t && $c);
print $cgi->header(-cookie=>$sc->cookie),$t if $t; 
