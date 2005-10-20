-- Database: `tentaculo`
-- --------------------------------------------------------

-- 
-- Structure for table `access`
-- 

CREATE TABLE access (
  id int(10) unsigned NOT NULL auto_increment,
  atype char(1) default NULL,
  ad char(1) default NULL,
  aclname int(10) unsigned default NULL,
  PRIMARY KEY  (id)
) AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure for table `acl`
-- 

CREATE TABLE acl (
  id int(10) unsigned NOT NULL auto_increment,
  name varchar(20) default NULL,
  acltype varchar(8) default NULL,
  aclstring varchar(255) default NULL,
  PRIMARY KEY  (id)
) AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure for table `admin`
-- 

CREATE TABLE admin (
  id int(11) NOT NULL auto_increment,
  user_name varchar(20) default NULL,
  pass_word varchar(50) default NULL,
  PRIMARY KEY  (id)
) AUTO_INCREMENT=2 ;

-- 
-- Data for table `admin`
-- 

INSERT INTO admin VALUES (1, 'admin', '4d186321c1a7f0f354b297e8914ab240');

-- --------------------------------------------------------

-- 
-- Structure for table `cache_dir`
-- 

CREATE TABLE cache_dir (
  id int(10) unsigned NOT NULL auto_increment,
  directory varchar(255) default NULL,
  size mediumint(8) unsigned default NULL,
  PRIMARY KEY  (id)
) AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure for table `cache_peer`
-- 

CREATE TABLE cache_peer (
  id int(10) unsigned NOT NULL auto_increment,
  address varchar(255) default NULL,
  http_port smallint(5) unsigned NOT NULL default '3128',
  icp_port smallint(5) unsigned NOT NULL default '3130',
  PRIMARY KEY  (id)
) AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure for table `delay_access`
-- 

CREATE TABLE delay_access (
  ord tinyint(3) unsigned default NULL,
  ad char(1) default NULL,
  aclname varchar(20) default NULL,
  delay_pool_id int(10) unsigned default NULL
);

-- --------------------------------------------------------

-- 
-- Structure for table `delay_pool`
-- 

CREATE TABLE delay_pool (
  id int(10) unsigned NOT NULL auto_increment,
  class tinyint(3) unsigned default NULL,
  parameters varchar(255) default NULL,
  PRIMARY KEY  (id)
) AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Structure for table `general`
-- 

CREATE TABLE general (
  id int(11) NOT NULL default '1',
  changed tinyint(1) NOT NULL default '0',
  swap tinyint(1) NOT NULL default '0',
  http_port smallint(5) unsigned NOT NULL default '3128',
  icp_port smallint(5) unsigned NOT NULL default '3130',
  visible_hostname varchar(255) default NULL,
  append_domain varchar(255) default NULL,
  cache_mem varchar(20) NOT NULL default '8M',
  PRIMARY KEY  (id)
);

-- 
-- Data for table `general`
-- 

INSERT INTO general VALUES (1, 0, 0, 3128, 3130, NULL, NULL, '8 Mb');
