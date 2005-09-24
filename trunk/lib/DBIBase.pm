package DBIBase;
use base 'Class::DBI';

use strict;

DBIBase->connection('dbi:mysql:tentaculo;host=localhost','tentaculo','squid');

1;
