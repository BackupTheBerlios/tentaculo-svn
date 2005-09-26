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
	my $cont = &header().&general().&cache().&acl();
	open(FILE,">etc/squid.conf") or die "Error: ".$!;
	print FILE $cont;
	close(FILE);
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
	$ret .= "acl all src 0.0.0.0/0.0.0.0\n";
	$ret .= "acl manager proto cache_object\n";
	$ret .= "acl localhost src 127.0.0.1/255.255.255.255\n";
	$ret .= "acl to_localhost dst 127.0.0.0/8\n";
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
