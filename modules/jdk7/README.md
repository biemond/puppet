JDK JAVA SE 7, 8 puppet module
============================== 
[![Build Status](https://travis-ci.org/biemond/biemond-jdk7.png)](https://travis-ci.org/biemond/biemond-jdk7)

Works with Puppet 2.7 or higher

Should work for RedHat, CentOS, Ubuntu, Debian, Suse SLES or OracleLinux 

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
	
	  jdk7::install7{ 'jdk1.7.0_40':
	    version              => "7u40" , 
	    fullVersion          => "jdk1.7.0_40",
	    javaHomes            => '/usr/java/',
	    alternativesPriority => 18000, 
	    x64                  => true,
	    downloadDir          => "/install",
	    urandomJavaFix       => false,
	    sourcePath           => "puppet:///modules/jdk7/"
	  }

or Java 8 and with rsa keySize Fix

      jdk7::install7{ 'jdk1.8.0':
        version              => "8" , 
        fullVersion          => "jdk1.8.0",
        alternativesPriority => 19000, 
        x64                  => true,
        downloadDir          => "/data/install",
        urandomJavaFix       => true,
        rsakeySizeFix        => false,
        sourcePath           => "/software",
      }

or with cryptography Extension File US export

	  jdk7::install7{ 'jdk1.7.0_51':
	      version                   => "7u51" , 
	      fullVersion               => "jdk1.7.0_51",
	      alternativesPriority      => 18000, 
	      x64                       => true,
	      downloadDir               => "/data/install",
	      urandomJavaFix            => true,
	      rsakeySizeFix             => true,
	      cryptographyExtensionFile => "UnlimitedJCEPolicyJDK7.zip",
	      sourcePath                => "/software",
	  }
	  
	  class { 'jdk7::urandomfix' :}
  
  
 
