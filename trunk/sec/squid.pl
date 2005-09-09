#!/usr/bin/perl -w
# This script execute the squid specific stuff.
# Start/stop/restart 

use strict;

my $output = `sudo /etc/init.d/squid start 2>hola`;
print $output;

