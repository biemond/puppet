jdk7 JAVA SE 7 puppet module
============================== 

Works with Puppet 2.7 & 3.0 

Should work for RedHat, CentOS, Ubuntu, Debian, Suse SLES or OracleLinux 

Version updates
---------------

- 0.3.1 Entropy fix for low on entropy, you can configure the rngd or rng-tools service or add it to java.security 
- 0.2.1 added SLES as O.S. plus SED and alternatives fixes
- 0.2 puppet 3.0 compatible, creates download folder


installs only the java tar.gz files
-----------------------------------
this is because rpm post install fails with some pack error

installs jdk on linux based systems with x64 or 32 bits   
add the jdk-7u25-linux-x64.tar.gz (downloaded from Oracle website) to the files folder of this jdk7 module

- download the tar.gz to the download folder of the puppet agent server
- unpack the java tar.gz
- set the java links in /usr/java ( latest and default ) 
- set this java as default
- optional updates urandom device for weblogic performance in java.security

urandomfix class for lack of entropy this rngd or or rng-tools service add extra random number  

example usage
-------------

	  include jdk7
	
	  jdk7::install7{ 'jdk1.7.0_25':
	    version        => "7u25" , 
	    fullVersion    => "jdk1.7.0_25", 
	    x64            => true,
	    downloadDir    => "/install",
	    urandomJavaFix => false,
	  }
	  
	  class { 'jdk7::urandomfix' :}
 
