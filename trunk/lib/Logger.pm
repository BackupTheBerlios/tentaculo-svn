package Logger;

use strict;
use Carp;

sub message {
	# Writes a message log entry.
	shift;
	my $message = shift;
	open REG, ">>log/messages" or die "Could not open file: ".$!;
	print REG localtime()." ".$message."\n";
	close(REG) or die "Could not close file:  ".$!;
}

sub error {
	# Writes an entry to error log and to stderr.
	shift;
	my $message = shift;
	print STDERR "Logging error: ".$message;
	open REG, ">>log/errors" or die "Could not open file:  ".$!;
	print REG Carp::longmess(localtime()." ".$message."\n");
	close(REG) or die "Could not close file: ".$!;
}

1;
