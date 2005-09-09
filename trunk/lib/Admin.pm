package Admin;
use base 'DBIBase';

use strict;

Admin->table('admin');
Admin->columns(All => qw/id user_name pass_word/);


sub check{
	shift;
	my ($u, $p) = @_; 
	my $it = Admin->search(user_name => $u, pass_word => $p);
	return $it->next->id if $it;
	Logger->message("Check failed with username $u and password (md5) $p");
	return 0;
}

sub change{
	shift;
	my ($id, $p) = @_;
	my $a = Admin->retrieve($id);
	$a->pass_word($p);
	return $a->update(); 
}

1;
