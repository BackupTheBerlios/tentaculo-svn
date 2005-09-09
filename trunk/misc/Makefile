#!/bin/bash

# xgettext options
domain = -d nc
copyright = --copyright-holder="Diego Andrés Asenjo G. <dasenjo@unicauca.edu.co>"
language = -L Perl
keyword = -k_
bugs = --msgid-bugs-address=dasenjo@unicauca.edu.co
options = $(domain) $(language) $(keyword) $(copyright) $(bugs)
# xgettext input files
files = ../lib/Template.pm

po:	
	xgettext $(options) $(files)
mo:	
	msgfmt -v -o nc.mo nc.po
clean:
	rm -f nc.po nc.mo
