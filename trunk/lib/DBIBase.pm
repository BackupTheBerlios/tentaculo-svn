package DBIBase;
use base 'Class::DBI';

use strict;

DBIBase->connection('dbi:mysql:nc;host=localhost','tentaculo','squid');

1;
