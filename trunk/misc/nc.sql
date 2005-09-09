-- Database : `nc`
CREATE DATABASE `nc`;
USE nc;

-- 
-- `admin` table structure
-- 

CREATE TABLE `admin` (
  `id` int(11) NOT NULL auto_increment,
  `user_name` varchar(20) default NULL,
  `pass_word` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) TYPE=MyISAM AUTO_INCREMENT=2 ;

-- 
-- `admin` table data
-- 

INSERT INTO `admin` VALUES (1, 'admin', 'd41d8cd98f00b204e9800998ecf8427e');

-- 
-- `file` table structure
-- 

CREATE TABLE `file` (
  `id` int(11) NOT NULL auto_increment,
  `extension` varchar(50) NOT NULL default '',
  `bandwith` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) TYPE=MyISAM AUTO_INCREMENT=1 ;

-- 
-- `file` table data
-- 

-- 
-- `state` table structure
-- 

CREATE TABLE `state` (
  `id` int(11) NOT NULL auto_increment,
  `enable` tinyint(4) NOT NULL default '0',
  `port` int(11) NOT NULL default '3128',
  `act_time` varchar(30) NOT NULL default '',
  `dom_enable` tinyint(4) NOT NULL default '0',
  `refresh_list` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) TYPE=MyISAM AUTO_INCREMENT=2 ;

--
--`state` table data 
-- 

INSERT INTO `state` VALUES (1, 1, 3128, '', 0, 0);
