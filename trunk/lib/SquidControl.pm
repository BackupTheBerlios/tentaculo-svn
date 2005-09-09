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
	my $cont;		# The squid.conf file content
	$cont .= &header();
	$cont .= &general();
	$cont .= &cache();
	open(FILE,">etc/squid.conf") or die "Error: ".$!;
	print FILE $cont;
	close(FILE);
}

sub header {
	shift;
	return 	"# File created by nc. Creation date: ".localtime()."\n".
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
	foreach my $tag (@tags){  $ret .= &simpleTag($tag, $g->{$tag});  }
	return $ret;
}

sub cache {
	shift;
	# hierarchy_stoplist and no_cache are squid recommended
	my ($ret, $g);
	$ret  =	"# CACHE OPTIONS\n";
	$ret .= "# -----------------------------------------------------------\n";
	$ret .= "#############################################################\n\n";
	$ret .= &simpleTag('cache_mem', General->getCacheMem());
	# The following two tags are squid recomended
	$ret .= &simpleTag('hierarchy_stoplist', 'cgi-bin ?');
	$ret .=	"#  TAG: no_cache\n";
	$ret .= "# -----------------------------------------------------------\n";
	$ret .= 'acl QUERY urlpath_regex cgi-bin \?'."\n";
	$ret .= "no_cache deny QUERY\n\n";
	
	# Write a tag for each cache dir entrie.
	foreach (@{Cache_Dir->getAll}){  $ret .= &cacheDirTag($_->{directory}, $_->{size});  }
	return $ret;
}

sub simpleTag {
	my $ret;
	my ($tag, $value) = @_;
	$ret  =	"#  TAG: $tag\n";
	$ret .= "# -----------------------------------------------------------\n";
	$ret .= "$tag = $value\n\n";
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

sub isRunning{
	shift;
	open(SQ,"</var/run/squid.conf");
	my $pid = <SQ>;
}
1;
