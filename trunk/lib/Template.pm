package Template;

use strict;
use Logger;
use I18N;

my $tmpl_dir = "/var/www/html/tentaculo/templates/";

sub read{
	shift;
	my $file = $tmpl_dir.I18N->getLanguage()."/".shift().".html";
	Logger->message("file: $file");
	open(FILE,"<$file") or die "Could not open file ".$file."Error: ".$!;
	my @content=<FILE>;
	close(FILE);
	return join("",@content);
}

sub result{
	shift;
	my ($r, $sect, $sub) = @_;
	my ($t, $m);
	my $res = Template->read('result');

	if ($r){ 
		$t = _('Successful change'); 
		if ($sect eq 'general'){
			$m = _('The General Configuration has been changed successfully.');
		} elsif ($sect eq 'cache'){
			$m = _('The Cache Configuration has been changed successfully.');
		} elsif ($sect eq 'settings'){
			$m = _('The settings has been changed successfully.');
			if ($sub eq 'password'){
				$m .= _(' The password has been changed successfully.');
			}
		}
	} else { 
		$t = _('Unsuccessful change'); 
		$m = _('There was a problem trying to apply the changes. Please try again.')
	}
	$res =~ s/<!-- TITLE -->/$t/;
	$res =~ s/<!-- MESSAGE -->/$m/;
	$res =~ s/SECTION/$sect/g;
	return $res;
}
sub loginError{
	shift;
	my $p = shift;
	my $e = _('Username and/or password incorrect');
	$p =~ s/<!-- ERROR -->/$e/; 
	return $p;
}

1;
