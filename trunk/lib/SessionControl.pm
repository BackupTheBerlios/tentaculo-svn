package SessionControl;
# This module manages the session stuff.

use strict;
use CGI::Session;
use User;
use Digest::MD5 'md5_hex';
use Logger qw(message error);

sub new{
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	$self->{cgi}= shift;
	$self->{session}=0;
	$self->{cookie}=0;
	bless($self,$class);
	return $self;
}

sub cookie{
	my $self = shift;
	return $self->{cookie};
}

sub param{
	my $self = shift;
	my $variable = shift;
	if (@_){ return $self->{session}->param($variable,shift) if $self->{session};}
	else {my $ret = $self->{session}->param($variable) || '' ; return $ret; }
}

sub clear{
	my $self = shift;
	my $variable = shift;
	return $self->{session}->clear($variable);
}

sub expires{
	my $self = shift;
	my $variable = shift;
	my $time = shift;
	return $self->{session}->expires($variable,$time);
}

sub flush{
	my $self = shift;
	return $self->{session}->flush();
}

sub check{
	my $self = shift;
	my $ph = shift;
	my ($u, $p) = ($ph->{'logUser'}, md5_hex($ph->{'logPass'}) );
	my $id = User->check($u,$p);
	if ( $id ) {
		$self->param('logged_in',1);
		$self->{session}->expires('logged_in',"+10m");
		$self->param('user_name',$u);
		$self->param('user_id',$id);
		Logger->message("User logged in with user name $u, id: ".$self->{session}->id);
		return 1;
	} else { return 0; }
}

sub changePass {
	my $self = shift;
	my $ph = shift;		# Param hash obtained with Vars() method
	my ($o, $n1, $n2 ) = ($ph->{'oldPass'}, $ph->{'newPass'}, $ph->{'newPass2'});
	my ($u, $id) = ( $self->param('user_name'), $self->param('user_id') );

	if ( User->check($u, md5_hex($o)) && ($n1 eq $n2) && User->change($id, md5_hex($n1)) ){
		Logger->message("Changed password for user $u");
		return 1;
	} else { return 0; } 
}

sub startSession{
        my $self = shift;
        my $cgi = $self->{cgi};
        my $id = $cgi->cookie('CGISESSID') || $cgi->url_param('sid') || $cgi->param('sid') || undef;
	$self->{session} = new CGI::Session(undef, $id, {Directory=>'/tmp'});
        $self->{cookie} = $cgi->cookie(CGISESSID => $self->{session}->id());
        Logger->message("NEW session. id=".$self->{session}->id) unless $id; # Log if new sessid
}

sub isLoggedIn{
	my $self = shift;
	if ($self->{session}){
		Logger->message("Checking logged_in for id:".$self->{session}->id);
		return $self->{session}->param("logged_in");
	} else {
		Logger->error('No $self->session');
		return 0;
	}
}

sub logOut{
	my $self = shift;
	$self->{session}->delete();
	undef $self;
}

1;
