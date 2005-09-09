package Logger;

use strict;
use Carp;

my $logdir  = "/var/log/tentaculo/";
my $logfile = $logdir."messages";
my $errfile = $logdir."errors";

sub message {
	# Writes a message log entry.
	my $self = shift;
	my $message = shift;
	open REG, ">>".$logfile or die "Could not open file: ".$!;
	print REG localtime()." ".$message."\n";
	close(REG) or die "Could not close file:  ".$!;
}

sub error {
	# Writes an entry to error log and to stderr.
	shift;
	my $message = shift;
	print STDERR "Logging error: ".$message;
	open REG, ">>".$errfile or die "Could not open file:  ".$!;
	print REG Carp::longmess(localtime()." ".$message."\n");
	close(REG) or die "Could not close file: ".$!;
}

1;
