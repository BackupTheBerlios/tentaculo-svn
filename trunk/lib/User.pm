package User;
use base 'DBIBase';

use strict;

User->table('user');
User->columns(All => qw/id user_name pass_word type/);


sub check{
	shift;
	my ($u, $p) = @_; 
	my $it = User->search(user_name => $u, pass_word => $p);
	return $it->next->id if $it;
	Logger->message("Check failed with username $u and password (md5) $p");
	return 0;
}

sub change{
	shift;
	my ($id, $p) = @_;
	my $a = User->retrieve($id);
	$a->pass_word($p);
	return $a->update(); 
}

1;
