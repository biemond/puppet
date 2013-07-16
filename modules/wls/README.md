Oracle WebLogic / Fusion Middleware puppet module
=================================================

created by Edwin Biemond  email biemond at gmail dot com   
[biemond.blogspot.com](http://biemond.blogspot.com)    
[Github homepage](https://github.com/biemond/puppet)    

Should work for Solaris x86 64, Windows, RedHat, CentOS, Ubuntu, Debian or OracleLinux 

Version updates
---------------

- 1.0.5 JDeveloper 12.1.2 with soa plugin install for Linux + small bug fixes
- 1.0.4 Weblogic 12.1.2 adf domain creation with RCU 
- 1.0.3 Weblogic 12.1.2 standard domain creation and start nodemanager of weblogic 12.1.2 domain 
- 1.0.2 Weblogic 12.1.2 support plus ADF 11g / 12c install manifest, refactoring for weblogic 12.1.2  
- 1.0.1 Webcenter, BPM and Webcenter Content domain creation, set Domain and Nodemanager passwords in the domain templates + Crossdomain 
- 1.0.0 Webcenter and Webcenter Content installer support 
- 0.9.9 solaris plus resource adapter fixes 
- 0.9.8 compatible with puppet 3.0  
- 0.9.7 Windows bugfixes  
- 0.9.6 support for Solaris x86 64  
- 0.9.5 support not existing parent directory for OracleHome, DownloadDir and LogDir  
        added wlsTemplate  ( wlsdomain.pp ) for osb + soa + bpm and adf domain templates    
- 0.9.4 add a JCA resource adapter plan for AQ,JMS & DB plus add AQ,JMS,DB resource adapter entries   
- 0.9.3 added storeUserConfig(WLST), this way don't need to provide username/password for the wlst scripts plus small bug fixes in check_artifacts   
- 0.9.2 added (FMW & WLS ) log folder location to the domain and nodemanager   

for more infomation about this Oracle WebLogic / FMW puppet module see this [AMIS blogpost](http://technology.amis.nl/2012/10/13/configure-fmw-servers-with-puppet/)

Repository Creation Utility (RCU)
---------------------------------
For the RCU configuration of the Soa Suite or WebCenter you can use my oradb puppet module 

Windows Puppet agents
---------------------
For windows puppet agents it is necessary to install unxutils tools and extract this on the c drive C:\unxutils  
For windows and JDK, you need copy the jdk to c:\oracle\ ( unpossible with the space in c:\program files folder).  
For bsu patches facts you need to have the java bin folder in your path var of your system.  

Also for registry support install this on the master, read this [registry blogpost](http://puppetlabs.com/blog/module-of-the-week-puppetlabs-registry-windows/) and install this forge module on the puppet master<br>
puppet module install puppetlabs/registry

For other agents like Solaris, RedHat,CentOS ,Ubuntu, Debian or OracleLinux should work without any problems 

Oracle Big files and alternate download location
------------------------------------------------

Some manifests like installwls.pp, opatch.pp, bsupatch.pp, installjdev, installosb, installsoa supports an alternative mountpoint for the big oracle setup/install files.  
When not provided it uses the files location of the wls puppet module  
else you can use $puppetDownloadMntPoint => "/mnt" or "puppet:///modules/wls/" (default) or  "puppet:///middleware/" 


WLS WebLogic Features
---------------------------

- installs WebLogic 10g,11g,12c ( 12.1.1 & 12.1.2 )
- apply bsu patch ( WebLogic Patch )

- installs Oracle ADF 11g & 12c ( 12.1.2)
- installs Oracle Service Bus 11g OSB with or without OEPE ( Oracle Eclipse )
- installs Oracle Soa Suite 11g
- installs Oracle Webcenter 11g
- installs Oracle Webcenter Content 11g
- apply oracle patch ( OPatch for Oracle products )

- installs Oracle JDeveloper 11g / 12.1.2 + soa suite plugin

- configures + starts nodemanager
- storeUserConfig for storing credentials and using in WLST

- domain creation + domain pack -> template name = 'standard'   
- domain OSB creation + domain pack -> template name = 'osb'  
- domain OSB + SOA creation + domain pack -> template name = 'osb_soa'  
- domain OSB + SOA + BPM creation + domain pack -> template name = 'osb_soa_bpm'  
- domain ADF creation + domain pack -> template name = 'adf'  
- domain WC (webcenter) + WCC (Content)  + BPM creation + domain pack -> template name = 'wc_wcc_bpm'  
- domain WC (webcenter) + domain pack -> template name = 'wc'  

- set the log folder of the WebLogic Domain, Managed servers and FMW   

- can start the AdminServer for WLST Domain configuration 
- add JCA resource adapter plan
- add JCA resource adapter entries
- create File or JDBC Persistence Store
- create JMS Server
- create JMS Module
- create JMS subdeployment
- create JMS connection factory
- create JMS queue or topic
- create users with group
- create SAF agents 
- create SAF Remote Destinations
- create SAf imported Destinations
- create SAF objects
- create Foreign Servers
- create Foreign Servers entries
- run every wlst script with the flexible WLST define
- deploy an OSB project to the OSB server

![Oracle WebLogic Console](https://raw.github.com/biemond/puppet/master/modules/wls/wlsconsole.png)

![Oracle Enterprise Manager Console](https://raw.github.com/biemond/puppet/master/modules/wls/em.png)

WLS WebLogic Facter
-------------------

Contains WebLogic Facter which displays the following  

- Middleware homes
- Oracle Software
- BSU patches
- Opatch patches
- Domains
- Domain configuration ( deployments, datasource, JMS, SAF)
- running nodemanagers
- running WebLogic servers

![Oracle Puppet Facts](https://raw.github.com/biemond/puppet/master/modules/wls/facts.png)

### My Files folder of the wls module
     1068506707 wls1036_generic.jar
      922712414 ofm_wls_generic_12.1.2.0.0_disk1_1of1.zip  
     1887405692 jdevstudio11116install.jar
     1904618055 jdevstudio11117install.jar
      375895263 oepe-indigo-all-in-one-11.1.1.8.0.201110211138-linux-gtk-x86_64.zip
     1149088683 ofm_osb_generic_11.1.1.6.0_disk1_1of1.zip
     1195403620 ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip
     1629875643 ofm_soa_generic_11.1.1.6.0_disk1_1of2.zip
     1291863724 ofm_soa_generic_11.1.1.6.0_disk1_2of2.zip
     1720182214 ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip
     1292438758 ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip
        1024644 p13573621_1036_Generic.zip
       17283347 p14389126_111160_Generic.zip
      653488012 p14406487_111160_Generic.zip
       42264472 p14736139_1036_Generic.zip
      208538583 soa-jdev-extension_11116.zip
      300343386 soa-jdev-extension_11117.zip
     2077610918 ofm_wc_generic_11.1.1.7.0_disk1_1of1.zip
     2052379536 ofm_wcc_generic_11.1.1.7.0_disk1_1of2.zip
      202204151 ofm_wcc_generic_11.1.1.7.0_disk1_2of2.zip
    
![Oracle Puppet Facts](https://raw.github.com/biemond/puppet/master/modules/wls/modulefiles.png)
    
Set for WebLogic the following ulimits and kernel parameters
------------------------------------------------------------

install the following module to set the database kernel parameters  
puppet module install fiddyspence-sysctl  

install the following module to set the database user limits parameters  
puppet module install erwbgy-limits  

     # Controls the default maxmimum size of a mesage queue
     sysctl { 'kernel.msgmnb':
       ensure    => 'present',
       permanent => 'yes',
       value     => '65536',
     }
   
     # Controls the maximum size of a message, in bytes
     sysctl { 'kernel.msgmax':
       ensure    => 'present',
       permanent => 'yes',
       value     => '65536',
     }
   
     # Controls the maximum number of shared memory segments, in pages
     sysctl { 'kernel.shmmax':
       ensure    => 'present',
       permanent => 'yes',
       value     => '2147483648',
     }
   
     # Controls the maximum shared segment size, in bytes
     sysctl { 'kernel.shmall':
       ensure    => 'present',
       permanent => 'yes',
       value     => '2097152',
     }
   
     sysctl { 'fs.file-max':
       ensure    => 'present',
       permanent => 'yes',
       value     => '344030',
     }
   
     # The interval between the last data packet sent (simple ACKs are not considered data) and the first keepalive probe
     sysctl { 'net.ipv4.tcp_keepalive_time':
       ensure    => 'present',
       permanent => 'yes',
       value     => '1800',
     }
   
     # The interval between subsequential keepalive probes, regardless of what the connection has exchanged in the meantime
     sysctl { 'net.ipv4.tcp_keepalive_intvl':
       ensure    => 'present',
       permanent => 'yes',
       value     => '30',
     }
   
     # The number of unacknowledged probes to send before considering the connection dead and notifying the application layer
     sysctl { 'net.ipv4.tcp_keepalive_probes':
       ensure    => 'present',
       permanent => 'yes',
       value     => '5',
     }
   
     # The time that must elapse before TCP/IP can release a closed connection and reuse its resources. During this TIME_WAIT state, reopening the connection to the client costs less than establishing a new connection. By reducing the value of this entry, TCP/IP can release closed connections faster, making more resources available for new connections.
     sysctl { 'net.ipv4.tcp_fin_timeout':
       ensure    => 'present',
       permanent => 'yes',
       value     => '30',
     }
   
     class { 'limits':
       config => {
                  '*'        => { 'nofile'  => { soft => '2048'   , hard => '8192',   },
                                },
                  'oracle'  => {  'nofile'  => { soft => '65535'  , hard => '65535',  },
                                  'nproc'   => { soft => '2048'   , hard => '2048',   },
                                  'memlock' => { soft => '1048576', hard => '1048576',},
                                },
                  },
       use_hiera => false,
     }

WebLogic configuration examples
-------------------------------

    class application_wls12 {
       include wls12_adf, wls12c_adf_domain
       Class['wls12_adf'] -> Class['wls12c_adf_domain']
    }
    class application_osb_soa {
       include wls1036osb_soa, wls_osb_soa_domain, wls_OSB_application_JDBC, wls_OSB_application_JMS
       include orautils
       Class['wls1036osb_soa'] -> Class['wls_osb_soa_domain'] -> Class['wls_OSB_application_JDBC'] -> Class['wls_OSB_application_JMS']
    }
	class application_wc {
	
	   include wls1036_wc, wls_wc_wcc_bpm_domain
	   include orautils
	   Class['wls1036_wc'] -> Class['wls_wc_wcc_bpm_domain']
	}
    class application_osb {
       include wls1036osb, wls_osb_domain, wls_OSB_application_JDBC
       include orautils
       Class['wls1036osb'] -> Class['wls_osb_domain'] -> Class['wls_OSB_application_JDBC']
    }
	class application_wc {
	   include wls1036_wc
	}    

### templates.pp

    include wls

	class wls12_adf{
	  if $jdkWls12cJDK == undef {
	    $jdkWls12cJDK = 'jdk1.7.0_25'
	  }
	  if $wls12cVersion == undef {
	    $wls12cVersion = "1212"
	  }
	  case $operatingsystem {
	     CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
	       $osOracleHome = "/opt/oracle/wls"
	       $osMdwHome    = "/opt/oracle/wls/Middleware12cADF"
	       $osWlHome     = "/opt/oracle/wls/Middleware12cADF/wlserver"
	       $user         = "oracle"
	       $group        = "dba"
	       $downloadDir  = "/data/install"
	     }
	     windows: { 
	       $osOracleHome = "c:/oracle"
	       $osMdwHome    = "c:/oracle/Middleware12cADF"
	       $osWlHome     = "c:/oracle/Middleware12cADF/wlserver"
	       $user         = "Administrator"
	       $group        = "Administrators"
	       $serviceName  = "C_oracle_middleware12cadf_wlserver"
	       $downloadDir  = "c:/temp"
	     }
	  }
	
	  $puppetDownloadMntPoint = "puppet:///middleware/"
	#  $puppetDownloadMntPoint = "puppet:///modules/wls/"                       
	
	  # set the adf defaults
	  Wls::Installadf {
	    mdwHome                => $osMdwHome,
	    wlHome                 => $osWlHome,
	    oracleHome             => $osOracleHome,
	    fullJDKName            => $jdkWls11gJDK, 
	    user                   => $user,
	    group                  => $group,   
	    downloadDir            => $downloadDir,
	    puppetDownloadMntPoint => $puppetDownloadMntPoint, 
	  }
	
	  wls::installadf{'adf12c':
	     adfFile      => 'ofm_wls_jrf_generic_12.1.2.0.0_disk1_1of1.zip',
	  } 
	} 
	            
    class wls1036osb_soa{
      if $jdkWls11gJDK == undef {
        $jdkWls11gJDK = 'jdk1.7.0_25'
      }
      if $wls11gVersion == undef {
        $wls11gVersion = "1036"
      }
      #$puppetDownloadMntPoint = "puppet:///middleware/"   
      $puppetDownloadMntPoint = "puppet:///modules/wls/" 
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
           $osOracleHome = "/opt/wls"
           $osMdwHome    = "/opt/wls/Middleware11gR1"
           $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
           $user         = "oracle"
           $group        = "dba"
           $downloadDir  = "/data/install/"
           $logsDir      = "/data/logs"   
         }
         windows: { 
           $osOracleHome = "c:/oracle"
           $osMdwHome    = "c:/oracle/wls11g"
           $osWlHome     = "c:/oracle/wls11g/wlserver_10.3"
           $user         = "Administrator"
           $group        = "Administrators"
           $serviceName  = "C_oracle_wls11g_wlserver_10.3"
           $downloadDir  = "c:/temp"
           $logsDir      = "c:/oracle/logs" 
         }
      }

      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 
            $mtimeParam = "1"
         }
         Solaris: { 
            $mtimeParam = "+1"
         }
      }

      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
		  cron { 'cleanwlstmp' :
		    command => "find /tmp -name '*.tmp' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/tmp_purge.log 2>&1",
		    user    => oracle,
		    hour    => 06,
		    minute  => 25,
		  }
		 
		  cron { 'mdwlogs' :
		    command => "find ${osMdwHome}/logs -name 'wlst_*.*' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/wlst_purge.log 2>&1",
		    user    => oracle,
		    hour    => 06,
		    minute  => 30,
		  }
		 
		  cron { 'oracle_common_lsinv' :
		    command => "find ${osMdwHome}/oracle_common/cfgtoollogs/opatch/lsinv -name 'lsinventory*.txt' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_lsinv_common_purge.log 2>&1",
		    user    => oracle,
		    hour    => 06,
		    minute  => 31,
		  }
		 
		  cron { 'oracle_osb1_lsinv' :
		    command => "find ${osMdwHome}/Oracle_OSB1/cfgtoollogs/opatch/lsinv -name 'lsinventory*.txt' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_lsinv_osb1_purge.log 2>&1",
		    user    => oracle,
		    hour    => 06,
		    minute  => 32,
		  }
		 
		  cron { 'oracle_soa1_lsinv' :
		    command => "find ${osMdwHome}/Oracle_SOA1/cfgtoollogs/opatch/lsinv -name 'lsinventory*.txt'  -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_lsinv_soa1_purge.log 2>&1",
		    user    => oracle,
		    hour    => 06,
		    minute  => 33,
		  }
		 
		  cron { 'oracle_common_opatch' :
		    command => "find ${osMdwHome}/oracle_common/cfgtoollogs/opatch -name 'opatch*.log' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_common_purge.log 2>&1",
		    user    => oracle,
		    hour    => 06,
		    minute  => 34,
		  }
		 
		  cron { 'oracle_osb1_opatch' :
		    command => "find ${osMdwHome}/Oracle_OSB1/cfgtoollogs/opatch -name 'opatch*.log' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_osb_purge.log 2>&1",
		    user    => oracle,
		    hour    => 06,
		    minute  => 35,
		  }
		 
		  cron { 'oracle_soa1_opatch' :
		    command => "find ${osMdwHome}/Oracle_SOA1/cfgtoollogs/opatch -name 'opatch*.log' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_soa_purge.log 2>&1",
		    user    => oracle,
		    hour    => 06,
		    minute  => 35,
		  }
         }
      }
    
      # set the defaults
      Wls::Installwls {
        version      => $wls11gVersion,
        fullJDKName  => $jdkWls11gJDK,
        oracleHome   => $osOracleHome,
        mdwHome      => $osMdwHome,
        user         => $user,
        group        => $group,    
        downloadDir  => $downloadDir,
        puppetDownloadMntPoint => $puppetDownloadMntPoint, 
      }
    
      Wls::Installosb {
        mdwHome      => $osMdwHome,
        wlHome       => $osWlHome,
        oracleHome   => $osOracleHome,
        fullJDKName  => $jdkWls11gJDK,	
        user         => $user,
        group        => $group,    
        downloadDir  => $downloadDir,
        puppetDownloadMntPoint => $puppetDownloadMntPoint, 
      }
    
      Wls::Installsoa {
        mdwHome      => $osMdwHome,
        wlHome       => $osWlHome,
        oracleHome   => $osOracleHome,
        fullJDKName  => $jdkWls11gJDK,	
        user         => $user,
        group        => $group,    
        downloadDir  => $downloadDir,
        puppetDownloadMntPoint => $puppetDownloadMntPoint, 
      }
      
      Wls::Nodemanager {
        wlHome       => $osWlHome,
        fullJDKName  => $jdkWls11gJDK,	
        user         => $user,
        group        => $group,
        serviceName  => $serviceName,  
        downloadDir  => $downloadDir, 
      }
    
      Wls::Bsupatch {
        mdwHome      => $osMdwHome ,
        wlHome       => $osWlHome,
        fullJDKName  => $jdkWls11gJDK,
        user         => $user,
        group        => $group,
        downloadDir  => $downloadDir,
        puppetDownloadMntPoint => $puppetDownloadMntPoint, 
      }
    
      # install
      wls::installwls{'11gPS5':}
    
    	# weblogic patch
      wls::bsupatch{'p14736139':
         patchId      => 'HYKC',    
         patchFile    => 'p14736139_1036_Generic.zip',  
         require      => Wls::Installwls['11gPS5'],
       }
    
    
       wls::installosb{'osbPS6':
         osbFile      => 'ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip',
         require      => Wls::Bsupatch['p14736139'],
       }
    
       wls::installsoa{'soaPS6':
         soaFile1      => 'ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip',
         soaFile2      => 'ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip',
         require       =>  Wls::Installosb['osbPS6'],
       }
    
       #nodemanager configuration and starting
       wls::nodemanager{'nodemanager11g':
         listenPort  => '5556',
         logDir      => $logsDir,
         require     =>  Wls::Installsoa['soaPS6'],
       }
    
    }

	class wls1036_wc{
	
	  if $jdkWls11gJDK == undef {
	    $jdkWls11gJDK = 'jdk1.7.0_25'
	  }
	
	  if $wls11gVersion == undef {
	    $wls11gVersion = "1036"
	  }
	                       
	  $puppetDownloadMntPoint = "puppet:///middleware/"
	  #  $puppetDownloadMntPoint = "puppet:///modules/wls/"                       
	
	  case $operatingsystem {
	     CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
	       $osOracleHome = "/opt/oracle/wls"
	       $osMdwHome    = "/opt/oracle/wls/Middleware11gR1"
	       $osWlHome     = "/opt/oracle/wls/Middleware11gR1/wlserver_10.3"
	       $user         = "oracle"
	       $group        = "dba"
	       $downloadDir  = "/data/install"
	       $logsDir      = "/data/logs"       
	     }
	     windows: { 
	       $osOracleHome = "c:/oracle/middleware"
	       $osMdwHome    = "c:/oracle/middleware/wls11g"
	       $osWlHome     = "c:/oracle/middleware/wls11g/wlserver_10.3"
	       $user         = "Administrator"
	       $group        = "Administrators"
	       $serviceName  = "C_oracle_middleware_wls11g_wlserver_10.3"
	       $downloadDir  = "c:/temp"
	       $logsDir      = "c:/oracle/logs" 
	     }
	  }
	
	  # set the defaults
	  Wls::Installwls {
	    version                => $wls11gVersion,
	    fullJDKName            => $jdkWls11gJDK,
	    oracleHome             => $osOracleHome,
	    mdwHome                => $osMdwHome,
	    user                   => $user,
	    group                  => $group,    
	    downloadDir            => $downloadDir,
	    puppetDownloadMntPoint => $puppetDownloadMntPoint,
	  }
	  
	  Wls::Nodemanager {
	    wlHome       => $osWlHome,
	    fullJDKName  => $jdkWls11gJDK,	
	    user         => $user,
	    group        => $group,
	    serviceName  => $serviceName,  
	    downloadDir  => $downloadDir, 
	  }
	
	  Wls::Bsupatch {
	    mdwHome                => $osMdwHome,
	    wlHome                 => $osWlHome,
	    fullJDKName            => $jdkWls11gJDK,
	    user                   => $user,
	    group                  => $group,
	    downloadDir            => $downloadDir, 
	    puppetDownloadMntPoint => $puppetDownloadMntPoint, 
	  }
	
	  Wls::Installwc {
	    mdwHome                => $osMdwHome,
	    wlHome                 => $osWlHome,
	    oracleHome             => $osOracleHome,
	    fullJDKName            => $jdkWls11gJDK,	
	    user                   => $user,
	    group                  => $group,    
	    downloadDir            => $downloadDir,
	    puppetDownloadMntPoint => $puppetDownloadMntPoint, 
	  }
	
	  Wls::Installwcc {
	    mdwHome                => $osMdwHome,
	    wlHome                 => $osWlHome,
	    oracleHome             => $osOracleHome,
	    fullJDKName            => $jdkWls11gJDK,	
	    user                   => $user,
	    group                  => $group,    
	    downloadDir            => $downloadDir,
	    puppetDownloadMntPoint => $puppetDownloadMntPoint, 
	  }
	
	
	  Wls::Installsoa {
	    mdwHome                => $osMdwHome,
	    wlHome                 => $osWlHome,
	    oracleHome             => $osOracleHome,
	    fullJDKName            => $jdkWls11gJDK,	
	    user                   => $user,
	    group                  => $group,    
	    downloadDir            => $downloadDir,
	    puppetDownloadMntPoint => $puppetDownloadMntPoint, 
	  }
	
	  # install
	  wls::installwls{'11gPS5':}
	
		# weblogic patch
	  wls::bsupatch{'p14736139':
	     patchId      => 'HYKC',    
	     patchFile    => 'p14736139_1036_Generic.zip',  
	     require      => Wls::Installwls['11gPS5'],
	  }
	
	  # webcenter  
	  wls::installwc{'wcPS6':
	     wcFile      => 'ofm_wc_generic_11.1.1.7.0_disk1_1of1.zip',
	     require     => Wls::Bsupatch['p14736139'],
	  }
	
	  # webcenter content
	  wls::installwcc{'wccPS6':
	    wccFile1    => 'ofm_wcc_generic_11.1.1.7.0_disk1_1of2.zip',
	    wccFile2    => 'ofm_wcc_generic_11.1.1.7.0_disk1_2of2.zip',
	    require     => Wls::Installwc['wcPS6'],
	  }
	
	  wls::installsoa{'soaPS6':
	     soaFile1      => 'ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip',
	     soaFile2      => 'ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip',
	     require       =>  Wls::Installwcc['wccPS6'],
	  }
	
	
	  #nodemanager configuration and starting
	  wls::nodemanager{'nodemanager11g':
	    listenPort  => '5556',
	    logDir      => $logsDir,
	    require     => Wls::Installsoa['soaPS6'],
	  }
	
	}
    
    class wls1036osb{
    
      if $jdkWls11gJDK == undef {
        $jdkWls11gJDK = 'jdk1.7.0_25'
      }
    
      if $wls11gVersion == undef {
        $wls11gVersion = "1036"
      }
     
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
           $osOracleHome = "/opt/wls"
           $osMdwHome    = "/opt/wls/Middleware11gR1"
           $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
           $user         = "oracle"
           $group        = "dba"
           $downloadDir  = "/data/install/"
         }
         windows: { 
           $osOracleHome = "c:/oracle"
           $osMdwHome    = "c:/oracle/wls11g"
           $osWlHome     = "c:/oracle/wls11g/wlserver_10.3"
           $user         = "Administrator"
           $group        = "Administrators"
           $serviceName  = "C_oracle_wls11g_wlserver_10.3"
           $downloadDir  = "c:\\temp\\"
         }
      }
    
      # set the defaults
      Wls::Installwls {
        version      => $wls11gVersion,
        fullJDKName  => $jdkWls11gJDK,
        oracleHome   => $osOracleHome,
        mdwHome      => $osMdwHome,
        user         => $user,
        group        => $group,    
        downloadDir  => $downloadDir, 
      }
    
      Wls::Installosb {
        mdwHome      => $osMdwHome,
        wlHome       => $osWlHome,
        oracleHome   => $osOracleHome,
        fullJDKName  => $jdkWls11gJDK,	
        user         => $user,
        group        => $group,    
        downloadDir  => $downloadDir, 
      }
    
      
      Wls::Nodemanager {
        wlHome       => $osWlHome,
        fullJDKName  => $jdkWls11gJDK,	
        user         => $user,
        group        => $group,
        serviceName  => $serviceName,  
        downloadDir  => $downloadDir, 
      }
    
      Wls::Bsupatch {
        mdwHome      => $osMdwHome ,
        wlHome       => $osWlHome,
        fullJDKName  => $jdkWls11gJDK,
        user         => $user,
        group        => $group,
        downloadDir  => $downloadDir, 
      }
    
      # install
      wls::installwls{'11gPS5':}
    
    	# weblogic patch
      wls::bsupatch{'p14736139':
         patchId      => 'HYKC',    
         patchFile    => 'p14736139_1036_Generic.zip',  
         require      => Wls::Installwls['11gPS5'],
       }
    
       wls::installosb{'osbPS6':
         osbFile      => 'ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip',
         require      => Wls::Bsupatch['p14736139'],
       }
    
       #nodemanager configuration and starting
       wls::nodemanager{'nodemanager11g':
         listenPort  => '5556',
         logDir      => '/data/logs',
         require     => Wls::Installosb['osbPS5'],
       }
    
    }
 
	class jdeveloper11g_1212_soa {
	
	  if $jdkWls11gJDK == undef {
	    $jdkWls11gJDK = 'jdk1.7.0_25'
	  }
	  $user         = "oracle"
	  $group        = "dba"
	  $downloadDir  = "/data/install"
	
	  wls::installjdev {'jdev_suite_121200':
	    version                => "1212",
	    jdevFile               => "jdev_suite_121200.jar",
	    fullJDKName            => $jdkWls11gJDK,
	    mdwHome                => "/opt/oracle/jdeveloper12c",
	    oracleHome             => "/opt/oracle",
	    soaAddon               => true,
	    soaAddonFile           => "soa-jdev-extension_11117.zip",
	    user                   => $user,
	    group                  => $group,
	    downloadDir            => $downloadDir,
	    puppetDownloadMntPoint => "puppet:///middleware/",
	  }
	}

	class jdeveloper11g_soa {
	
	  if $jdkWls11gJDK == undef {
	    $jdkWls11gJDK = 'jdk1.7.0_25'
	  }
	
	  $user         = "oracle"
	  $group        = "dba"
	  $downloadDir  = "/data/install"
	
	  wls::installjdev {'jdevstudio11117':
	    version      => "1111",
	    jdevFile     => "jdevstudio11117install.jar",
	    fullJDKName  => $jdkWls11gJDK,
	    mdwHome      => "/opt/oracle/jdeveloper11gR1PS6",
	    oracleHome   => "/opt/oracle",
	    soaAddon     => true,
	    soaAddonFile => "soa-jdev-extension_11117.zip",
	    user         => $user,
	    group        => $group,
	    downloadDir  => $downloadDir,
	  }
	}
    
    class osb_oepe{
    
      if $jdkWls11gJDK == undef {
        $jdkWls11gJDK = 'jdk1.7.0_25'
      }
    
      if $wls11gVersion == undef {
        $wls11gVersion = "1036"
      }
    
      $osOracleHome = "/opt/wls"
      $osMdwHome    = "/opt/wls/Middleware11gR1"
      $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
      $user         = "oracle"
      $group        = "dba"
      $downloadDir  = "/install/"
    
      $oepeFile     = "oepe-indigo-all-in-one-11.1.1.8.0.201110211138-linux-gtk-x86_64.zip"
    
      # set the defaults
      Wls::Installwls {
        version      => $wls11gVersion,
        fullJDKName  => $jdkWls11gJDK,
        oracleHome   => $osOracleHome,
        mdwHome      => $osMdwHome,
        user         => $user,
        group        => $group,
        downloadDir  => $downloadDir,        
      }
    
      Wls::Installosb {
        mdwHome      => $osMdwHome,
        wlHome       => $osWlHome,
        oracleHome   => $osOracleHome,
        fullJDKName  => $jdkWls11gJDK,	
        user         => $user,
        group        => $group,    
        downloadDir  => $downloadDir, 
      }
    
      # install
      wls::installwls{'11gPS5_hudson':}
    
      # download oepe to hudson server
      if ! defined(File["/install/${oepeFile}"]) {
        file { "/install/${oepeFile}":
           source  => "puppet:///modules/wls/${oepeFile}",
           require => Wls::Installwls['11gPS5_hudson'],
           ensure  => present,
           mode    => 0775,
        }
      }
    
      # extract oepe in middleware home
      if ! defined(Exec["extract ${oepeFile}"]) {
         exec { "extract ${oepeFile}":
              command   => "unzip -n /install/${oepeFile} -d ${osMdwHome}/oepe11.1.1.8",
              require   => File["/install/${oepeFile}"],
              creates   => "${osMdwHome}/oepe11.1.1.8",
              path      => "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:",
              user      => $user,
              group     => $group,
              logoutput => true,
             }
      }
    
      #install OSB with OEPE
      wls::installosb{'osbPS6_oepe':
        osbFile      => 'ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip',
        oepeHome     => 'oepe11.1.1.8',
        require      => Exec["extract ${oepeFile}"],
      }
    
    }

    
### templates_app.pp


    include wls

	class wls12c_adf_domain{
	
	
	  if $jdkWls12gJDK == undef {
	    $jdkWls12gJDK = 'jdk1.7.0_25'
	  }
	
	  $wlsDomainName   = "adf"
	
	  $osTemplate      = "adf"
	  #$osTemplate      = "standard"
	
	  $adminListenPort = "7001"
	  $nodemanagerPort = "5556"
	  $address         = "localhost"
	
	  case $operatingsystem {
	     CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
	       $osOracleHome = "/opt/oracle/wls"
	       $osMdwHome    = "/opt/oracle/wls/Middleware12cADF"
	       $osWlHome     = "/opt/oracle/wls/Middleware12cADF/wlserver"
	       $user         = "oracle"
	       $group        = "dba"
	       $downloadDir  = "/data/install"
	       $logDir      = "/data/logs" 
	     }
	     windows: { 
	       $osOracleHome = "c:/oracle"
	       $osMdwHome    = "c:/oracle/Middleware12cADF"
	       $osWlHome     = "c:/oracle/Middleware12cADF/wlserver"
	       $user         = "Administrator"
	       $group        = "Administrators"
	       $serviceName  = "C_oracle_middleware12cadf_wlserver"
	       $downloadDir  = "c:/temp"
	       $logDir      = "c:/oracle/logs"
	     }
	  }
	
	  case $operatingsystem {
	     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 
	       $userConfigDir = '/home/oracle'
	     }
	     Solaris: { 
	       $userConfigDir = '/export/home/oracle'
	     }
	     windows: { 
	       $userConfigDir = "c:/oracle"
	     }
	   }
	   # rcu wc wcc bpm repository
	   $reposUrl        = "jdbc:oracle:thin:@dbagent2.alfa.local:1521/test.oracle.com"
	   $rcuDbUrl        = "dbagent2.alfa.local:1521:test"
	   $reposPrefix     = "DEV3"
	   # rcu wc repository schema password
	   $reposPassword   = hiera('database_test_rcu_dev_password')
	   $sysPassword     = hiera('database_test_sys_password')
	
	
		#   wls::utils::rcu{ "RCU_12c dev3 delete":
		#                   product                => 'adf',
		#                   oracleHome             => "${osMdwHome}/oracle_common",
		#                   fullJDKName            => $jdkWls12gJDK,
		#                   user                   => $user,
		#                   group                  => $group,
		#                   downloadDir            => $downloadDir,
		#                   action                 => 'delete',
		#                   dbUrl                  => $rcuDbUrl,  
		#                   sysPassword            => $sysPassword,
		#                   schemaPrefix           => $reposPrefix,
		#                   reposPassword          => $reposPassword,
		#  }
		#
	
	  # install domain and in 12.1.2 it also creates a RCU schema plus a nodemanager
	  wls::wlsdomain{
	   'adfDomain12c':
	    version         => "1212",
	    wlHome          => $osWlHome,
	    mdwHome         => $osMdwHome,
	    fullJDKName     => $jdkWls12gJDK,  
	    user            => $user,
	    group           => $group,    
	    downloadDir     => $downloadDir, 
	    wlsTemplate     => $osTemplate,
	    domain          => $wlsDomainName,
	    adminListenPort => $adminListenPort,
	    nodemanagerPort => $nodemanagerPort,
	    wlsUser         => "weblogic",
	    password        => hiera('weblogic_password_default'),
	    logDir          => $logDir,
	    reposDbUrl      => $reposUrl,
	    reposPrefix     => $reposPrefix,
	    reposPassword   => $reposPassword,
	    dbUrl           => $rcuDbUrl,
	    sysPassword     => $sysPassword,
	  #    require         => Wls::Utils::Rcu["RCU_12c dev3 delete"],
	  }
	
	  Wls::Nodemanager {
	    wlHome       => $osWlHome,
	    fullJDKName  => $jdkWls11gJDK,  
	    user         => $user,
	    group        => $group,
	    serviceName  => $serviceName,  
	  }
	
	   #nodemanager starting 
	   # in 12c start it after domain creation
	   wls::nodemanager{'nodemanager11g':
	     version   => "1212",
	     domain    => $wlsDomainName,      
	     require   => Wls::Wlsdomain['adfDomain12c'],
	   }  
	  
	
	  # default parameters for the wlst scripts
	  Wls::Wlstexec {
	    version      => "1212", 
	    wlsDomain    => $wlsDomainName,
	    wlHome       => $osWlHome,
	    fullJDKName  => $jdkWls12gJDK,  
	    user         => $user,
	    group        => $group,
	    address      => $address,
	    downloadDir  => $downloadDir, 
	  }
	  
	  # start AdminServer for configuration
	  wls::wlstexec { 
	    'startWLSAdminServer12c':
	     wlsUser     => "weblogic",
	     password    => hiera('weblogic_password_default'),
	     script      => 'startWlsServer.py',
	     port        =>  $nodemanagerPort,
	     params      =>  ["domain = '${wlsDomainName}'",
	                      "domainPath = '${osMdwHome}/user_projects/domains/${wlsDomainName}'",
	                      "wlsServer = 'AdminServer'"],
	     require     => Wls::Nodemanager['nodemanager11g'];
	
	  }
	}
    
    class wls_osb_soa_domain{
    
    
      if $jdkWls11gJDK == undef {
        $jdkWls11gJDK = 'jdk1.7.0_25'
      }
    
      $wlsDomainName   = "osbSoaDomain"
      $osTemplate      = "osb_soa"
      $adminListenPort = "7001"
      $nodemanagerPort = "5556"
      $address         = "localhost"
    
     
      # rcu soa repository
      $reposUrl        = "jdbc:oracle:thin:@dbagent1.alfa.local:1521/test.oracle.com"
    
      if $hostname == 'devagent1' {
        $reposPrefix     = "DEV"
    
      } elsif $hostname == 'devagent4' {
        $reposPrefix     = "DEV2"
    
      } else {
        $reposPrefix     = "DEV"
      }
      # rcu soa repository schema password
      $reposPassword   = "Welcome02"
    
     
     
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
           $osOracleHome  = "/opt/wls"
           $osMdwHome     = "/opt/wls/Middleware11gR1"
           $osWlHome      = "/opt/wls/Middleware11gR1/wlserver_10.3"
           $user          = "oracle"
           $group         = "dba"
           $downloadDir   = "/data/install/"
           $userConfigDir = '/home/oracle'
           $logDir        = "/data/logs"
         }
         windows: { 
           $osOracleHome  = "c:/oracle"
           $osMdwHome     = "c:/oracle/wls11g"
           $osWlHome      = "c:/oracle/wls11g/wlserver_10.3"
           $user          = "Administrator"
           $group         = "Administrators"
           $serviceName   = "C_oracle_wls11g_wlserver_10.3"
           $downloadDir   = "c:/temp"
           $userConfigDir = "c:/oracle"
           $logDir        = "c:/oracle/logs"       
         }
      }
    
    
      # install SOA OSB domain
      wls::wlsdomain{'osbSoaDomain':
        wlHome          => $osWlHome,
        mdwHome         => $osMdwHome,
        fullJDKName     => $jdkWls11gJDK, 
        wlsTemplate     => $osTemplate,
        domain          => $wlsDomainName,
        adminServerName => "AdminServer",
        adminListenAdr  => "localhost",
        adminListenPort => $adminListenPort,
        nodemanagerPort => $nodemanagerPort,
        wlsUser         => "weblogic",
        password        => "weblogic1",
        user            => $user,
        group           => $group,    
        logDir          => $logDir,
        downloadDir     => $downloadDir, 
        reposDbUrl      => $reposUrl,
        reposPrefix     => $reposPrefix,
        reposPassword   => $reposPassword,
      }
    
    
      # default parameters for the wlst scripts
      Wls::Wlstexec {
        wlsDomain    => $wlsDomainName,
        wlHome       => $osWlHome,
        fullJDKName  => $jdkWls11gJDK,  
        user         => $user,
        group        => $group,
        address      => $address,
        downloadDir  => $downloadDir, 
      }
      
      # start AdminServers for configuration of WLS Domain
      wls::wlstexec { 
        'startOSBSOAAdminServer':
         wlsUser     => "weblogic",
         password    => "weblogic1",
       #  userConfigFile => "${userConfigDir}/${user}-osbSoaDomain-WebLogicConfig.properties"
       #  userKeyFile    => "${userConfigDir}/${user}-osbSoaDomain-WebLogicKey.properties", 
         script      => 'startWlsServer.py',
         port        => $nodemanagerPort,
         params      =>  ["domain     = '${wlsDomainName}'",
                          "domainPath = '${osMdwHome}/user_projects/domains/${wlsDomainName}'",
                          "wlsServer  = 'AdminServer'"],
         require     => Wls::Wlsdomain['osbSoaDomain'];
      }
    
      # create keystores for automatic WLST login
      wls::storeuserconfig{
       'osbSoaDomain_keys':
        wlHome        => $osWlHome,
        fullJDKName   => $jdkWls11gJDK,
        domain        => $wlsDomainName, 
        address       => $address,
        wlsUser       => "weblogic",
        password      => "weblogic1",
        port          => $adminListenPort,
        user          => $user,
        group         => $group,
        userConfigDir => $userConfigDir, 
        downloadDir   => $downloadDir, 
        require       => Wls::Wlstexec['startOSBSOAAdminServer'],
      }
    
      # set the defaults
      Wls::Changefmwlogdir {
        mdwHome        => $osMdwHome,
        user           => $user,
        group          => $group,
        address        => $address,
        port           => $adminListenPort,
      #    wlsUser        => "weblogic",
      #    password       => "weblogic1",
        userConfigFile => "${userConfigDir}/${user}-osbSoaDomain-WebLogicConfig.properties
        userKeyFile    => "${userConfigDir}/${user}-osbSoaDomain-WebLogicKey.properties", 
        downloadDir    => $downloadDir, 
      }
    
      # change the FMW logfiles
      wls::changefmwlogdir{
       'AdminServer':
        wlsServer    => "AdminServer",
        logDir       => $logDir,
        require      => Wls::Storeuserconfig['osbSoaDomain_keys'],
      }
    
      wls::changefmwlogdir{
       'soa_server1':
        wlsServer    => "soa_server1",
        logDir       => $logDir,
        require      => Wls::Changefmwlogdir['AdminServer'],
      }
    
      wls::changefmwlogdir{
       'osb_server1':
        wlsServer    => "osb_server1",
        logDir       => $logDir,
        require      => Wls::Changefmwlogdir['soa_server1'],
      }
    
    }
    
	class wls_wc_wcc_bpm_domain{
	
	
	  if $jdkWls11gJDK == undef {
	    $jdkWls11gJDK = 'jdk1.7.0_25'
	  }
	
	  $wlsDomainName   = "wcWccBpmDomain"
	  
	  #$osTemplate      = "standard"
	  #$osTemplate      = "osb"
	  #$osTemplate      = "osb_soa"
	  #$osTemplate      = "osb_soa_bpm"
	  #$osTemplate      = "wc"
	  $osTemplate      = "wc_wcc_bpm"
	
	
	  $adminListenPort = "7001"
	  $nodemanagerPort = "5556"
	  $address         = "localhost"
	
	  case $operatingsystem {
	     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 
	       $userConfigDir = '/home/oracle'
	     }
	     Solaris: { 
	       $userConfigDir = '/export/home/oracle'
	     }
	     windows: { 
	       $userConfigDir = "c:/oracle"
	     }
	  }
	 
	  # rcu wc wcc bpm repository
	  $reposUrl        = "jdbc:oracle:thin:@dbagent2.alfa.local:1521/test.oracle.com"
	
	  $reposPrefix     = "DEV2"
	  # rcu wc repository schema password
	  $reposPassword   = hiera('database_test_rcu_dev_password')
	 
	  case $operatingsystem {
	     CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
	       $osOracleHome  = "/opt/oracle/wls"
	       $osMdwHome     = "/opt/oracle/wls/Middleware11gR1"
	       $osWlHome      = "/opt/oracle/wls/Middleware11gR1/wlserver_10.3"
	       $user          = "oracle"
	       $group         = "dba"
	       $downloadDir   = "/data/install"
	       $logDir        = "/data/logs"
	     }
	     windows: { 
	       $osOracleHome  = "c:/oracle/middleware"
	       $osMdwHome     = "c:/oracle/middleware/wls11g"
	       $osWlHome      = "c:/oracle/middleware/wls11g/wlserver_10.3"
	       $user          = "Administrator"
	       $group         = "Administrators"
	       $serviceName   = "C_oracle_middleware_wls11g_wlserver_10.3"
	       $downloadDir   = "c:/temp"
	       $logDir        = "c:/oracle/logs" 
	     }
	  }
	
	
	  # install WC WCC BPM domain
	  wls::wlsdomain{'wcWccBpmDomain':
	    wlHome          => $osWlHome,
	    mdwHome         => $osMdwHome,
	    fullJDKName     => $jdkWls11gJDK, 
	    wlsTemplate     => $osTemplate,
	    domain          => $wlsDomainName,
	    adminServerName => "AdminServer",
	    adminListenAdr  => "localhost",
	    adminListenPort => $adminListenPort,
	    nodemanagerPort => $nodemanagerPort,
	    wlsUser         => "weblogic",
	    password        => hiera('weblogic_password_default'),
	    user            => $user,
	    group           => $group,    
	    logDir          => $logDir,
	    downloadDir     => $downloadDir, 
	    reposDbUrl      => $reposUrl,
	    reposPrefix     => $reposPrefix,
	    reposPassword   => $reposPassword,
	  }
	
	  # default parameters for the wlst scripts
	  Wls::Wlstexec {
	    wlsDomain    => $wlsDomainName,
	    wlHome       => $osWlHome,
	    fullJDKName  => $jdkWls11gJDK,  
	    user         => $user,
	    group        => $group,
	    address      => $address,
	    downloadDir  => $downloadDir, 
	  }
	  
	  # start AdminServers for configuration of WLS Domain
	  wls::wlstexec { 
	    'startWCAdminServer':
	     wlsUser     => "weblogic",
	     password    => hiera('weblogic_password_default'),
	     script      => 'startWlsServer.py',
	     port        => $nodemanagerPort,
	     params      =>  ["domain     = '${wlsDomainName}'",
	                      "domainPath = '${osMdwHome}/user_projects/domains/${wlsDomainName}'",
	                      "wlsServer  = 'AdminServer'"],
	     require     => Wls::Wlsdomain['wcWccBpmDomain'];
	  }
	
	  # create keystores for automatic WLST login
	  wls::storeuserconfig{
	   'wcDomain_keys':
	    wlHome        => $osWlHome,
	    fullJDKName   => $jdkWls11gJDK,
	    domain        => $wlsDomainName, 
	    address       => $address,
	    wlsUser       => "weblogic",
	    password      => hiera('weblogic_password_default'),
	    port          => $adminListenPort,
	    user          => $user,
	    group         => $group,
	    userConfigDir => $userConfigDir, 
	    downloadDir   => $downloadDir, 
	    require       => Wls::Wlstexec['startWCAdminServer'],
	  }
	
	
	}
    
    class wls_osb_domain{
    
      if $jdkWls11gJDK == undef {
        $jdkWls11gJDK = 'jdk1.7.0_25'
      }
    
      $wlsDomainName   = "osbDomain"
      $osTemplate      = "osb"
      $adminListenPort = "7001"
      $nodemanagerPort = "5556"
      $address         = "localhost"
    
     
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
           $osOracleHome = "/opt/wls"
           $osMdwHome    = "/opt/wls/Middleware11gR1"
           $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
           $user         = "oracle"
           $group        = "dba"
           $downloadDir  = "/data/install/"
           $userConfigDir = '/home/oracle'
           $logDir        = "/data/logs"
         }
         windows: { 
           $osOracleHome = "c:/oracle"
           $osMdwHome    = "c:/oracle/wls11g"
           $osWlHome     = "c:/oracle/wls11g/wlserver_10.3"
           $user         = "Administrator"
           $group        = "Administrators"
           $serviceName  = "C_oracle_wls11g_wlserver_10.3"
           $downloadDir  = "c:\\temp\\"
           $userConfigDir = "c:/oracle"
           $logDir        = "c:/oracle/logs"  
         }
      }
      
      # install OSB domain
      wls::wlsdomain{'osbDomain':
        wlHome          => $osWlHome,
        mdwHome         => $osMdwHome,
        fullJDKName     => $jdkWls11gJDK, 
        wlsTemplate     => $osTemplate,
        domain          => $wlsDomainName,
        adminServerName => "AdminServer",
        adminListenAdr  => "localhost",
        adminListenPort => $adminListenPort,
        nodemanagerPort => $nodemanagerPort,
        wlsUser         => "weblogic",
        password        => "weblogic1",
        user            => $user,
        group           => $group,    
        logDir          => $logDir,
        downloadDir     => $downloadDir, 
      }
    
      # default parameters for the wlst scripts
      Wls::Wlstexec {
        wlsDomain    => $wlsDomainName,
        wlHome       => $osWlHome,
        fullJDKName  => $jdkWls11gJDK,  
        user         => $user,
        group        => $group,
        address      => $address,
        downloadDir  => $downloadDir, 
      }
      
      # start AdminServers for configuration of WLS Domain
      wls::wlstexec { 
        'startOSBAdminServer':
         wlsUser     => "weblogic",
         password    => "weblogic1",
    #     userConfigFile => '/home/oracle/oracle-osbDomain-WebLogicConfig.properties',
    #     userKeyFile    => '/home/oracle/oracle-osbDomain-WebLogicKey.properties',
         script      => 'startWlsServer.py',
         port        => $nodemanagerPort,
         params      =>  ["domain     = '${wlsDomainName}'",
                          "domainPath = '${osMdwHome}/user_projects/domains/${wlsDomainName}'",
                          "wlsServer  = 'AdminServer'"],
         require     => Wls::Wlsdomain['osbDomain'];
      }
    
      # create keystores for automatic WLST login
      wls::storeuserconfig{
       'osbDomain_keys':
        wlHome        => $osWlHome,
        fullJDKName   => $jdkWls11gJDK,
        domain        => $wlsDomainName, 
        address       => $address,
        wlsUser       => "weblogic",
        password      => "weblogic1",
        port          => $adminListenPort,
        user          => $user,
        group         => $group,
        userConfigDir => $userConfigDir, 
        downloadDir   => $downloadDir, 
        require       => Wls::Wlstexec['startOSBAdminServer'],
      }
    
    
      Wls::Changefmwlogdir {
        mdwHome        => $osMdwHome,
        user           => $user,
        group          => $group,
        address        => $address,
        port           => $adminListenPort,
    #    wlsUser        => "weblogic",
    #    password       => "weblogic1",
        userConfigFile => '/home/oracle/oracle-osbDomain-WebLogicConfig.properties',
        userKeyFile    => '/home/oracle/oracle-osbDomain-WebLogicKey.properties',
        downloadDir    => $downloadDir, 
      }
    
      wls::changefmwlogdir{
       'AdminServer':
        wlsServer    => "AdminServer",
        logDir       => $logDir,
        require      => Wls::Storeuserconfig['osbDomain_keys'],
      }
    
    
      wls::changefmwlogdir{
       'osb_server1':
        wlsServer    => "osb_server1",
        logDir       => $logDir,
        require      => Wls::Changefmwlogdir['AdminServer'],
      }
    
    
    }
  

    
    class wls_OSB_application_JDBC{
    
      if $jdkWls11gJDK == undef {
        $jdkWls11gJDK = 'jdk1.7.0_09'
      }
    
      if $hostname == 'devagent1' {
    
        $userConfigFile  = '/home/oracle/oracle-osbSoaDomain-WebLogicConfig.properties'
        $userKeyFile     = '/home/oracle/oracle-osbSoaDomain-WebLogicKey.properties'
    
        $wlsDomainName   = 'osbSoaDomain'
    
      } elsif $hostname == 'devagent2' {
    
        $userConfigFile  = '/home/oracle/oracle-osbDomain-WebLogicConfig.properties'
        $userKeyFile     = '/home/oracle/oracle-osbDomain-WebLogicKey.properties'
    
        $wlsDomainName   = 'osbDomain'
      } 
    
    
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
           $osMdwHome    = "/opt/wls/Middleware11gR1"
           $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
           $user         = "oracle"
           $group        = "dba"
           $downloadDir  = "/data/install/"
         }
         windows: { 
           $osMdwHome    = "c:/oracle/wls11g"
           $osWlHome     = "c:/oracle/wls11g/wlserver_10.3"
           $user         = "Administrator"
           $group        = "Administrators"
           $serviceName  = "C_oracle_wls11g_wlserver_10.3"
           $downloadDir  = "c:\\temp\\"
         }
      }
    
      # default parameters for the wlst scripts
      Wls::Wlstexec {
        wlsDomain      => $wlsDomainName,
        wlHome         => $osWlHome,
        fullJDKName    => $jdkWls11gJDK,  
        user           => $user,
        group          => $group,
        address        => "localhost",
    #    wlsUser        => "weblogic",
    #    password       => "weblogic1",
        userConfigFile => $userConfigFile,
        userKeyFile    => $userKeyFile,
        port           => "7001",
        downloadDir    => $downloadDir, 
      }
    
      # create jdbc datasource for osb_server1 
      wls::wlstexec { 
      
        'createJdbcDatasourceHr':
         wlstype       => "jdbc",
         wlsObjectName => "hrDS",
         script        => 'createJdbcDatasource.py',
         params        => ["dsName                      = 'hrDS'",
                          "jdbcDatasourceTargets       = 'AdminServer,osb_server1'",
                          "dsJNDIName                  = 'jdbc/hrDS'",
                          "dsDriverName                = 'oracle.jdbc.xa.client.OracleXADataSource'",
                          "dsURL                       = 'jdbc:oracle:thin:@dbagent1.alfa.local:1521/test.oracle.com'",
                          "dsUserName                  = 'hr'",
                          "dsPassword                  = 'hr'",
                          "datasourceTargetType        = 'Server'",
                          "globalTransactionsProtocol  = 'xxxx'"
                          ],
      }
    
      wls::resourceadapter{
       'DbAdapter_hr':
        wlHome         => $osWlHome,
        fullJDKName    => $jdkWls11gJDK,
        domain         => $wlsDomainName, 
        adapterName          => 'DbAdapter' ,
        adapterPath          => '/opt/wls/Middleware11gR1/Oracle_SOA1/soa/connectors/DbAdapter.rar',
        adapterPlanDir       => '/opt/wls/Middleware11gR1/Oracle_SOA1/soa/connectors' ,
        adapterPlan          => 'Plan_DB.xml' ,
        adapterEntry         => 'eis/DB/hr',
        adapterEntryProperty => 'xADataSourceName',
        adapterEntryValue    => 'jdbc/hrDS',
        address        => "localhost",
        port           => "7001",
    #    wlsUser       => "weblogic",
    #    password      => "weblogic1",
        userConfigFile => $userConfigFile,
        userKeyFile    => $userKeyFile,
        user           => $user,
        group          => $group,
        downloadDir    => $downloadDir,
        require        => Wls::Wlstexec['createJdbcDatasourceHr'];
      }
    
      wls::resourceadapter{
       'AqAdapter_hr':
        wlHome         => $osWlHome,
        fullJDKName    => $jdkWls11gJDK,
        domain         => $wlsDomainName, 
        adapterName          => 'AqAdapter' ,
        adapterPath          => '/opt/wls/Middleware11gR1/Oracle_SOA1/soa/connectors/AqAdapter.rar',
        adapterPlanDir       => '/opt/wls/Middleware11gR1/Oracle_SOA1/soa/connectors' ,
        adapterPlan          => 'Plan_AQ.xml' ,
        adapterEntry         => 'eis/AQ/hr',
        adapterEntryProperty => 'xADataSourceName',
        adapterEntryValue    => 'jdbc/hrDS',
        address        => "localhost",
        port           => "7001",
        wlsUser        => "weblogic",
        password       => "weblogic1",
    #    userConfigFile => $userConfigFile,
    #    userKeyFile    => $userKeyFile,
        user           => $user,
        group          => $group,
        downloadDir    => $downloadDir,
        require        => Wls::Resourceadapter['DbAdapter_hr'];
      }
    
    
    }  
    
    class wls_OSB_application_JMS{
    
    
      if $jdkWls11gJDK == undef {
        $jdkWls11gJDK = 'jdk1.7.0_25'
      }
    
      if $hostname == 'devagent1' {
    
        $userConfigFile  = '/home/oracle/oracle-osbSoaDomain-WebLogicConfig.properties'
        $userKeyFile     = '/home/oracle/oracle-osbSoaDomain-WebLogicKey.properties'
    
        $wlsDomainName   = 'osbSoaDomain'
    
      } elsif $hostname == 'devagent2' {
    
        $userConfigFile  = '/home/oracle/oracle-osbDomain-WebLogicConfig.properties'
        $userKeyFile     = '/home/oracle/oracle-osbDomain-WebLogicKey.properties'
    
        $wlsDomainName   = 'osbDomain'
      } 
    
    
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
           $osMdwHome    = "/opt/wls/Middleware11gR1"
           $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
           $user         = "oracle"
           $group        = "dba"
           $downloadDir  = "/data/install/"
         }
         windows: { 
           $osMdwHome    = "c:/oracle/wls11g"
           $osWlHome     = "c:/oracle/wls11g/wlserver_10.3"
           $user         = "Administrator"
           $group        = "Administrators"
           $serviceName  = "C_oracle_wls11g_wlserver_10.3"
           $downloadDir  = "c:\\temp\\"
         }
      }
    
      # default parameters for the wlst scripts
      Wls::Wlstexec {
        wlsDomain      => $wlsDomainName,
        wlHome         => $osWlHome,
        fullJDKName    => $jdkWls11gJDK,  
        user           => $user,
        group          => $group,
        address        => "localhost",
    #    wlsUser      => "weblogic",
    #    password     => "weblogic1",
        userConfigFile => $userConfigFile,
        userKeyFile    => $userKeyFile,
        port           => "7001",
        downloadDir    => $downloadDir, 
      }
    
      # create jdbc jms datasource for jms server 
      wls::wlstexec { 
        'createJdbcDatasourceJms':
         wlstype       => "jdbc",
         wlsObjectName => "jmsDS",
         script        => 'createJdbcDatasource.py',
         params        => ["dsName                      = 'jmsDS'",
                          "jdbcDatasourceTargets       = 'AdminServer,osb_server1'",
                          "dsJNDIName                  = 'jdbc/jmsDS'",
                          "dsDriverName                = 'oracle.jdbc.OracleDriver'",
                          "dsURL                       = 'jdbc:oracle:thin:@dbagent1.alfa.local:1521/test.oracle.com'",
                          "dsUserName                  = 'jms'",
                          "dsPassword                  = 'jms'",
                          "datasourceTargetType        = 'Server'",
                          "globalTransactionsProtocol  = 'None'"
                          ],
      }
    
      # create jdbc persistence store for jmsmodule 
      wls::wlstexec { 
        'createJdbcPersistenceStoreOSBServer':
         wlstype       => "jdbcstore",
         wlsObjectName => "jmsModuleJdbcPersistence",
         script        => 'createJdbcPersistenceStore.py',
         params        => ["jdbcStoreName = 'jmsModuleJdbcPersistence'",
                          "serverTarget  = 'osb_server1'",
                          "prefix        = 'jms1'",
                          "datasource    = 'jmsDS'"
                          ],
         require     => Wls::Wlstexec['createJdbcDatasourceJms'];
      }
    
      # create file persistence store for osb_server1 
      wls::wlstexec { 
        'createFilePersistenceStoreOSBServer':
         wlstype       => "filestore",
         wlsObjectName => "jmsModuleFilePersistence",
         script        => 'createFilePersistenceStore.py',
         port          => $adminServerPort,
         params        =>  ["fileStoreName = 'jmsModuleFilePersistence'",
                          "serverTarget  = 'osb_server1'"],
         require       => Wls::Wlstexec['createJdbcPersistenceStoreOSBServer'];
      }
      
      # create jms server for osb_server1 
      wls::wlstexec { 
        'createJmsServerOSBServer':
         wlstype       => "jmsserver",
         wlsObjectName => "jmsServer",
         script      => 'createJmsServer.py',
         params      =>  ["storeName      = 'jmsModuleFilePersistence'",
                          "serverTarget   = 'osb_server1'",
                          "jmsServerName  = 'jmsServer'",
                          "storeType      = 'file'",
                          ],
         require     => Wls::Wlstexec['createFilePersistenceStoreOSBServer'];
      }
    
      # create jms server for osb_server1 
      wls::wlstexec { 
        'createJmsServerOSBServer2':
         wlstype       => "jmsserver",
         wlsObjectName => "jmsServer2",
         script      => 'createJmsServer.py',
         port        => $adminServerPort,
         params      =>  ["storeName      = 'jmsModuleJdbcPersistence'",
                          "serverTarget   = 'osb_server1'",
                          "jmsServerName  = 'jmsServer2'",
                          "storeType      = 'jdbc'",
                          ],
         require     => Wls::Wlstexec['createJmsServerOSBServer'];
      }
    
      # create jms module for osb_server1 
      wls::wlstexec { 
        'createJmsModuleOSBServer':
         wlstype       => "jmsmodule",
         wlsObjectName => "jmsModule",
         script        => 'createJmsModule.py',
         params        =>  ["target         = 'osb_server1'",
                            "jmsModuleName  = 'jmsModule'",
                            "targetType     = 'Server'",
                           ],
         require       => Wls::Wlstexec['createJmsServerOSBServer2'];
      }
    
    
      # create jms subdeployment for jms module 
      wls::wlstexec { 
        'createJmsSubDeploymentWLSforJmsModule':
         wlstype       => "jmssubdeployment",
         wlsObjectName => "jmsModule/wlsServer",
         script        => 'createJmsSubDeployment.py',
         params        => ["target         = 'osb_server1'",
                           "jmsModuleName  = 'jmsModule'",
                           "subName        = 'wlsServer'",
                           "targetType     = 'Server'"
                          ],
         require       => Wls::Wlstexec['createJmsModuleOSBServer'];
     }
    
    
      # create jms subdeployment for jms module 
      wls::wlstexec { 
        'createJmsSubDeploymentWLSforJmsModule2':
         wlstype       => "jmssubdeployment",
         wlsObjectName => "jmsModule/JmsServer",
         script        => 'createJmsSubDeployment.py',
         params        => ["target         = 'jmsServer'",
                           "jmsModuleName  = 'jmsModule'",
                           "subName        = 'JmsServer'",
                           "targetType     = 'JMSServer'"
                          ],
         require     => Wls::Wlstexec['createJmsSubDeploymentWLSforJmsModule'];
      }
    
      # create jms connection factory for jms module 
      wls::wlstexec { 
      
        'createJmsConnectionFactoryforJmsModule':
         wlstype       => "jmsobject",
         wlsObjectName => "cf",
         script        => 'createJmsConnectionFactory.py',
         params        => ["subDeploymentName = 'wlsServer'",
                          "jmsModuleName     = 'jmsModule'",
                          "cfName            = 'cf'",
                          "cfJNDIName        = 'jms/cf'",
                          "transacted        = 'false'",
                          "timeout           = 'xxxx'"
                          ],
         require     => Wls::Wlstexec['createJmsSubDeploymentWLSforJmsModule2'];
      }
    
      wls::resourceadapter{
       'JmsAdapter_hr':
        wlHome         => $osWlHome,
        fullJDKName    => $jdkWls11gJDK,
        domain         => $wlsDomainName, 
        adapterName          => 'JmsAdapter' ,
        adapterPath          => '/opt/wls/Middleware11gR1/Oracle_SOA1/soa/connectors/JmsAdapter.rar',
        adapterPlanDir       => '/opt/wls/Middleware11gR1/Oracle_SOA1/soa/connectors' ,
        adapterPlan          => 'Plan_JMS.xml' ,
        adapterEntry         => 'eis/JMS/cf',
        adapterEntryProperty => 'ConnectionFactoryLocation',
        adapterEntryValue    => 'jms/cf',
        address        => "localhost",
        port           => "7001",
    #    wlsUser       => "weblogic",
    #    password      => "weblogic1",
        userConfigFile => $userConfigFile,
        userKeyFile    => $userKeyFile,
        user           => $user,
        group          => $group,
        downloadDir    => $downloadDir,
        require        => Wls::Wlstexec['createJmsConnectionFactoryforJmsModule'];
      }
    
    
    
      # create jms error Queue for jms module 
      wls::wlstexec { 
      
        'createJmsErrorQueueforJmsModule':
         wlstype       => "jmsobject",
         wlsObjectName => "ErrorQueue",
         script        => 'createJmsQueueOrTopic.py',
         params        => ["subDeploymentName = 'JmsServer'",
                          "jmsModuleName     = 'jmsModule'",
                          "jmsName           = 'ErrorQueue'",
                          "jmsJNDIName       = 'jms/ErrorQueue'",
                          "jmsType           = 'queue'",
                          "distributed       = 'false'",
                          "balancingPolicy   = 'xxxxx'",
                          "useRedirect       = 'false'",
                          "limit             = 'xxxxx'",
                          "policy            = 'xxxxx'",
                          "errorObject       = 'xxxxx'"
                          ],
         require     => Wls::Resourceadapter['JmsAdapter_hr'];
      }
    
      # create jms Queue for jms module 
      wls::wlstexec { 
        'createJmsQueueforJmsModule':
         wlstype       => "jmsobject",
         wlsObjectName => "Queue1",
         script        => 'createJmsQueueOrTopic.py',
         params        => ["subDeploymentName   = 'JmsServer'",
                          "jmsModuleName       = 'jmsModule'",
                          "jmsName             = 'Queue1'",
                          "jmsJNDIName         = 'jms/Queue1'",
                          "jmsType             = 'queue'",
                          "distributed         = 'false'",
                          "balancingPolicy     = 'xxxxx'",
                          "useRedirect         = 'true'",
                          "limit               = '3'",
                          "policy              = 'Redirect'",
                          "errorObject         = 'ErrorQueue'"
                          ],
         require     => Wls::Wlstexec['createJmsErrorQueueforJmsModule'];
      }
    
      # create jms Topic for jms module 
      wls::wlstexec { 
        'createJmsTopicforJmsModule':
         wlstype       => "jmsobject",
         wlsObjectName => "Topic1",
         script        => 'createJmsQueueOrTopic.py',
         params        => ["subDeploymentName   = 'JmsServer'",
                          "jmsModuleName       = 'jmsModule'",
                          "jmsName             = 'Topic1'",
                          "jmsJNDIName         = 'jms/Topic1'",
                          "jmsType             = 'topic'",
                          "distributed         = 'false'",
                          "balancingPolicy     = 'xxxxx'",
                          "useRedirect         = 'false'",
                          "limit               = 'xxxxx'",
                          "policy              = 'xxxxx'",
                          "errorObject         = 'xxxxx'"
                          ],
         require     => Wls::Wlstexec['createJmsQueueforJmsModule'];
      }
    
    }  
