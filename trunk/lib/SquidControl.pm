package SquidControl;

use strict;
use General;
use Cache_Dir;
use Logger;

sub new{
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless($self,$class);
	return $self;
}

sub writeFile{
	shift;
	my $cont = &header().&general().&cache().&acl().&http_access();
	open(FILE,">etc/squid.conf") or die "Error: ".$!;
	print FILE $cont;
	close(FILE);
	return General->isChanged(0);
}

sub header {
	shift;
	return 	"# Created by tentaculo at ".localtime().".\n".
		"#############################################################\n".
		"#############################################################\n\n";
}

sub general {
	shift;
	my ($ret, $g, @tags) = ('', '', ('http_port','icp_port', 'visible_hostname'));
	$ret  =	"# GENERAL OPTIONS\n";
	$ret .= "# -----------------------------------------------------------\n";
	$ret .= "#############################################################\n\n";
	$g = General->getGeneral();
	foreach my $tag (@tags){  $ret .= &simpleTag($tag, $g->{$tag}) if $g->{$tag}; }
	return $ret;
}

sub cache {
	shift;
	my ($ret, $g);
	$ret  =	"# CACHE OPTIONS\n";
	$ret .= "# -----------------------------------------------------------\n";
	$ret .= "#############################################################\n\n";
	$ret .= &simpleTag('cache_mem', General->getCacheMem());
	# hierarchy_stoplist and no_cache configurations are squid recommended
	$ret .= &simpleTag('hierarchy_stoplist', 'cgi-bin ?');
	$ret .=	"#  TAG: no_cache\n";
	$ret .=	"#  (squid recommended)\n";
	$ret .= "# -----------------------------------------------------------\n";
	$ret .= 'acl QUERY urlpath_regex cgi-bin \?'."\n";
	$ret .= "no_cache deny QUERY\n\n";
	
	# Write a tag for each cache dir entrie.
	my $dirs = Cache_Dir->getAll();
	if($dirs){ for (@{$dirs}){ $ret .= &cacheDirTag($_->{directory}, $_->{size}); } }
	return $ret;
}

sub acl {
	shift;
	my $ret;
	$ret  =	"# ACCESS CONTROL\n";
	$ret .= "# -----------------------------------------------------------\n";
	$ret .= "#############################################################\n\n";
	# Default values. Squid recommended.
	$ret .= "acl manager proto cache_object\n";
	$ret .= "acl SSL_ports port 443 563	# https, snews\n";
	$ret .= "acl SSL_ports port 873		# rsync\n";
	$ret .= "acl Safe_ports port 80		# http\n";
	$ret .= "acl Safe_ports port 21		# ftp\n";
	$ret .= "acl Safe_ports port 443 563	# https, snews\n";
	$ret .= "acl Safe_ports port 70		# gopher\n";
	$ret .= "acl Safe_ports port 210		# wais\n";
	$ret .= "acl Safe_ports port 1025-65535	# unregistered ports\n";
	$ret .= "acl Safe_ports port 280		# http-mgmt\n";
	$ret .= "acl Safe_ports port 488		# gss-http\n";
	$ret .= "acl Safe_ports port 591		# filemaker\n";
	$ret .= "acl Safe_ports port 777		# multiling http\n";
	$ret .= "acl Safe_ports port 631		# cups\n";
	$ret .= "acl Safe_ports port 873		# rsync\n";
	$ret .= "acl Safe_ports port 901		# SWAT\n";
	$ret .= "acl purge method PURGE\n";
	$ret .= "acl CONNECT method CONNECT\n";
	# Write a tag for each cache dir entrie.
	my $acls = Acl->getAll();
	if($acls){ for(@{$acls}){$ret .="acl ".$_->{name}." ".$_->{acltype}." ".$_->{aclstring}; }}
	return $ret;
}

sub http_access {
	shift;
	my $ret;
	# Only allow cachemgr access from localhost
	$ret .= "http_access allow manager localhost\n";
	$ret .= "http_access deny manager\n";
	# Only allow purge requests from localhost
	$ret .= "http_access allow purge localhost\n";
	$ret .= "http_access deny purge\n";
	$ret .= "# Deny requests to unknown ports\n";
	$ret .= "http_access deny !Safe_ports\n";
	# Deny CONNECT to other than SSL ports
	$ret .= "http_access deny CONNECT !SSL_ports\n";
	# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
	$ret .= "http_access allow localhost\n";
	# And finally deny all other access to this proxy
	$ret .= "http_access deny all\n";
	return $ret;
}
sub simpleTag {
	my $ret;
	my ($tag, $value) = @_;
	$ret  =	"#  TAG: $tag\n";
	$ret .= "# -----------------------------------------------------------\n";
	$ret .= "$tag $value\n\n";
	return $ret;
}

sub cacheDirTag {
	my $ret;
	my ($dir, $size) = @_;
	$ret  =	"#  TAG: cache_dir\n";
	$ret .= "# -----------------------------------------------------------\n";
	$ret .= "cache_dir ufs $dir $size 16 256\n\n";
	return $ret;
}

1;
