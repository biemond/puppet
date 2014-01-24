Oracle WebLogic / Fusion Middleware puppet module
=================================================

created by Edwin Biemond  email biemond at gmail dot com   
[biemond.blogspot.com](http://biemond.blogspot.com)    
[Github homepage](https://github.com/biemond/puppet)  
[Oracle OpenWorld presentation, how to roll out a complete FMW environment in less than 10 minutes](http://www.slideshare.net/biemond/fmw-puppet-oow13)  

Should work for Solaris x86 64, Windows, RedHat, CentOS, Ubuntu, Debian, Suse SLES or OracleLinux 

New orawls module designed for puppet 3 and totally refactored and optimized for Hiera, see the biemond-orawls module  

Reference implementation, the vagrant test case for full working WebLogic 10.3.6 cluster example  
https://github.com/biemond/biemond-wls-vagrant-10.3.6  

Reference implementation, the vagrant test case for full working WebLogic 12.1.2 cluster example  
https://github.com/biemond/biemond-wls-vagrant-12.1.2  

Reference implementation, the vagrant test case for full working WebLogic SOA Suite, OIM and OAM example  
https://github.com/biemond/biemond-wls-vagrant-oim  

Reference implementation, the vagrant test case for full working WebLogic SOA Suite, OSB example  
https://github.com/biemond/biemond-wls-vagrant-soa-osb  

Reference implementation, the vagrant test case for full working WebLogic WebCenter , Content and BPM example  
https://github.com/biemond/biemond-wls-vagrant-wc  


Version updates
---------------

- 1.3.7 javaParameters param for installwls ( support for Docker -Dspace.detection=false ,thanks Jyrk )
- 1.3.6 remoteFile param for BSU,Opatch,SOA Suite, WebCenter, WebCenter Content and OIM 
- 1.3.5 Nodemanager fix, Added AdminServer startup properties for Nodemanager, Readme update for OIM,OAM
- 1.3.4 Nodemanager listen address, Domain ALSBdebug param check, remoteFile param for installwls ( for vagrant), managed server listen address, logdir fixes in copydomain & nodemanager, packdomain permissions fix, option to use copydomain without sshpass
- 1.3.3 Option to override the Oracle operating user and provide your own domains home
- 1.3.2 better WebLogic Facts checking, Foreign Server and FS objects support
- 1.3.1 soa & soa_bpm domain options, new JMS SubDeployment CF, Queue and Topic options
- 1.3.0 Compatible with earlier linux versions
- 1.2.9 Optimizations, Weblogic install timeout to 0, WLST fixes and separate domain pack ( no auto pack in wlsdomain )
- 1.2.8 BSU / nodemanager / WLST scripts fixes. 
- 1.2.7 Windows fixes. 
- 1.2.6 Webtier installation and associate domain with the Oracle HTTP server. 
- 1.2.5 WebLogic domains also supports Prod mode, set Nodemanager security. 
- 1.2.4 JMS Quota creation, Datasource now supports extra JDBC properties, fixed ruby warning with not escaped chars + arrays in erb files 
- 1.2.3 Wlscontrol support starting of managed servers  
- 1.2.2 Small bug fixes for ADF 12.1.2 install + weblogic configuration examples  
- 1.2.1 Timout fixes + OPatch fix, fix for standard domain and wls 12.1.2, WebLogic 12.1.2 now uses these jars wls_121200.jar, fmw_infra_121200.jar instead of the zip files    
- 1.2.0 Multi node domain support with copydomain class, create Machine, Managed Server & Cluster, less notify output    
- 1.1.1 updated license to Apache 2.0, new wlscontrol class to start or stop a wls server, minimal output in repeating runs, less notify output and a logOutput parameters to control the output    
- 1.1.0 Low on entropy fix with new urandomfix class, add rngd or rng-tools service which adds urandom, removed java.security.egd parameter    


WLS WebLogic Features
---------------------------
- installs WebLogic 10g,11g,12c ( 12.1.1 & 12.1.2 )
- apply BSU patch ( WebLogic Patch )
- installs Oracle ADF 11g & 12c ( 12.1.2)
- installs Oracle Service Bus 11g OSB with or without OEPE ( Oracle Eclipse )
- installs Oracle Soa Suite 11g
- installs Oracle Webcenter 11g
- installs Oracle Webcenter Content 11g
- installs Oracle Webtier and associate domain
- installs Oracle OIM ( identity management ) + OAM ( Access management ) 11.1.2.1
- apply Oracle patch ( OPatch for Oracle products )
- installs Oracle JDeveloper 11g / 12.1.2 + SOA Suite plugin
- configures and starts nodemanager
- start or stop a WebLogic server
- pack a WebLogic domain
- storeUserConfig for storing WebLogic Credentials and using in WLST
- set the log folder of the WebLogic Domain, Managed servers and FMW   
- add JCA resource adapter plan + Entries
- create Machines, Managed Servers, Clusters, Server templates, Dynamic Clusters, Coherence clusters ( all 12.1.2 )
- create File or JDBC Persistence Store
- create JMS Server, Module, SubDeployment, Quota, Connection Factory, JMS (distributed) Queue or Topic,Foreign Servers + entries
- create SAF agents, SAF Remote Destinations, SAF Imported Destinations, SAF objects
- basically can run every WLST script with the flexible WLST define manifest

Other options
-------------
- low on entropy fix ( urandom ) by RNGD or RNG-Tools service
- Multi machine support for a WebLogic domain, can be used for cluster or spreading managed servers

Domain creation options (Dev or Prod mode)
------------------------------------------
all templates creates a WebLogic domain, logs the domain creation output  

- domain 'standard'    -> a default WebLogic    
- domain 'adf'         -> JRF + EM + Coherence (12.1.2) + OWSM (12.1.2) + JAX-WS Advanced + Soap over JMS (12.1.2)   
- domain 'osb'         -> OSB + JRF + EM + OWSM 
- domain 'osb_soa'     -> OSB + SOA Suite + BAM + JRF + EM + OWSM 
- domain 'osb_soa_bpm' -> OSB + SOA Suite + BAM + BPM + JRF + EM + OWSM 
- domain 'soa'         -> SOA Suite + BAM + JRF + EM + OWSM 
- domain 'soa_bpm'     -> SOA Suite + BAM + BPM + JRF + EM + OWSM 
- domain 'wc_wcc_bpm'  -> WC (webcenter) + WCC ( Content ) + BPM + JRF + EM + OWSM 
- domain 'wc'          -> WC (webcenter) + JRF + EM + OWSM 
- domain 'oim'         -> OIM + OAM + SOA Suite 


Linux low on entropy or urandom fix 
-----------------------------------
can cause certain operations to be very slow. Encryption operations need entropy to ensure randomness. Entropy is generated by the OS when you use the keyboard, the mouse or the disk.

If an encryption operation is missing entropy it will wait until enough is generated.

three options  
  use rngd service (use this wls::urandomfix class)  
  set java.security in JDK ( jre/lib/security in my jdk7 module )  
  set -Djava.security.egd=file:/dev/./urandom param 

Repository Creation Utility
---------------------------
For FMW 11g (RCU) For the RCU configuration of the Soa Suite or WebCenter you can use my oradb puppet module   
RCU configuration of the FMW 12.1.2 is supported by this module and its done by the domain creation  

Windows Puppet agents
---------------------
For windows puppet agents it is necessary to install unxutils tools and extract this on the c drive C:\unxutils  
For windows and JDK, you need copy the jdk to c:\oracle\ ( unpossible with the space in c:\program files folder).  
For bsu patches facts you need to have the java bin folder in your path var of your system.  
Also for registry support install this on the master, read this [registry blogpost](http://puppetlabs.com/blog/module-of-the-week-puppetlabs-registry-windows/) and install this forge module on the puppet master<br>
puppet module install puppetlabs/registry

Override the default Oracle operating system user
-------------------------------------------------
default this wls module uses oracle as weblogic install user ( need to create your own user and group and set createUser=false on installwls or installadf )  
you can override this by setting the following fact 'override_weblogic_user', like override_weblogic_user=wls or set FACTER_override_weblogic_user=wls  
/etc/facter/facts.d/ # Puppet Open Source  
/etc/puppetlabs/facter/facts.d/ # Puppet Enterprise  

Override the default Weblogic domains folder like user_projects 
---------------------------------------------------------------
set the following fact 'override_weblogic_domain_folder',  override_weblogic_domain_folder=/opt/oracle/wlsdomains or set FACTER_override_weblogic_domain_folder=/opt/oracle/wlsdomains  
/etc/facter/facts.d/ # Puppet Open Source  
/etc/puppetlabs/facter/facts.d/ # Puppet Enterprise  

Oracle Big files and alternate download location
------------------------------------------------
Some manifests like installwls.pp, opatch.pp, bsupatch.pp, installjdev, installosb, installsoa supports an alternative mountpoint for the big oracle setup/install files.  
When not provided it uses the files location of the wls puppet module  
else you can use $puppetDownloadMntPoint => "/mnt" or "puppet:///modules/wls/" (default) or  "puppet:///middleware/" 

Oracle WebLogic Domain on multi machines
----------------------------------------
When having a Domain on multiple servers you can use the copydomain class, this uses the sshpass and scp utilities to copy the domain to a local folder  
for sshpass you need to install epel yum repository, do this by installing "puppet module install stahnma/epel"  
for a complete multinode cluster example see example_conf_2_multi_node_domain_with_cluster.txt located in your wls module home at the puppet master or look at the my github repos https://github.com/biemond/puppet/tree/master/modules/wls   

Everything on 1 machine WebLogic 12.1.2 (ADF + Coherence)& Database 12c
-----------------------------------------------------------------------
When you want a FMW WebLogic Domain and a Database with a RCU on 1 machine you can look at the following example see example_conf_1_server_with_wls12.1.2_ora_db12c.txt located in your wls module home at the puppet master or look at the my github repos https://github.com/biemond/puppet/tree/master/modules/wls   

Standard WebLogic 10.3.6 cluster on 2 nodes
-------------------------------------------
see example_conf_2_multi_node_domain_with_cluster.txt located in your wls module home at the puppet master or look at the my github repos https://github.com/biemond/puppet/tree/master/modules/wls

Standard WebLogic 12.1.2 server with a domain ( no ADF or FMW )
------------------------------------------------------------------------
see example_conf_3_server_wls12.1.2_standard.txt located in your wls module home at the puppet master or look at the my github repos https://github.com/biemond/puppet/tree/master/modules/wls

Standard WebLogic 10.3.6 server + BSU Patch with 11g PS6 of OSB /SOA Suite / BAM & BPM domain
---------------------------------------------------------------------------------------------
see example_conf_4_weblogic_10.3.6_osb_soa_ps6.txt located in your wls module home at the puppet master or look at the my github repos https://github.com/biemond/puppet/tree/master/modules/wls  
also creates JDBC datasources, Resource adapters, A Cluster with Managed Server, JMS server with a JMS module plus Queues & Topics  

Standard WebLogic 10.3.6 server + BSU Patch with 11g PS6 of Webcenter portal & content domain ( also BPM portal)
----------------------------------------------------------------------------------------------------------------
see example_conf_5_weblogic_10.3.6_webcenter_portal_content_ps6.txt located in your wls module home at the puppet master or look at the my github repos https://github.com/biemond/puppet/tree/master/modules/wls  

Standard WebLogic 12.1.2 windows server with a domain ( no ADF or FMW )
------------------------------------------------------------------------
see example_conf_6_server_wls12.1.2_windows_standard.txt located in your wls module home at the puppet master or look at the my github repos https://github.com/biemond/puppet/tree/master/modules/wls

Standard WebLogic 10.3.6 server with a 11.1.2.1 OIM,OAM, SOA Suite domain 
-------------------------------------------------------------------------
see example_conf_7_oim_oam_11.1.2.1.txt located in your wls module home at the puppet master or look at the my github repos https://github.com/biemond/puppet/tree/master/modules/wls


![Oracle WebLogic Console](https://raw.github.com/biemond/puppet/master/modules/wls/wlsconsole.png)

![Oracle Enterprise Manager Console](https://raw.github.com/biemond/puppet/master/modules/wls/em.png)

WLS WebLogic Facter
-------------------

Contains WebLogic Facter which displays the following: Middleware homes, Oracle Software, BSU & OPatch patches, Domain configuration ( everything of a domain like deployments, datasource, JMS, SAF)

![Oracle Puppet Facts](https://raw.github.com/biemond/puppet/master/modules/wls/facts.png)

### My WLS module Files folder, you need to download it yourself and agree to the Oracle (Developer) License
WebLogic 11g + patches: wls1036_generic.jar, p13573621_1036_Generic.zip, p14736139_1036_Generic.zip  
WebLogic 12.1.2: wls_121200.jar, fmw_infra_121200.jar  
IDE: jdevstudio11117install.jar, soa-jdev-extension_11117.zip, oepe-indigo-all-in-one-11.1.1.8.0.201110211138-linux-gtk-x86_64.zip  
OSB + SOA software: ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip, ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip, ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip    
Webcenter software: ofm_wc_generic_11.1.1.7.0_disk1_1of1.zip, ofm_wcc_generic_11.1.1.7.0_disk1_1of2.zip, ofm_wcc_generic_11.1.1.7.0_disk1_2of2.zip  
    
![Oracle Puppet Facts](https://raw.github.com/biemond/puppet/master/modules/wls/modulefiles.png)
    
WebLogic settings for ulimits and kernel parameters
---------------------------------------------------

install the following module to set the database kernel parameters  
puppet module install fiddyspence-sysctl  

install the following module to set the database user limits parameters  
puppet module install erwbgy-limits  

     sysctl { 'kernel.msgmnb': ensure => 'present', permanent => 'yes', value => '65536',}
     sysctl { 'kernel.msgmax': ensure => 'present', permanent => 'yes', value => '65536',}
     sysctl { 'kernel.shmmax': ensure => 'present', permanent => 'yes', value => '2147483648',}
     sysctl { 'kernel.shmall': ensure => 'present', permanent => 'yes', value => '2097152',}
     sysctl { 'fs.file-max': ensure => 'present', permanent => 'yes', value => '344030',}
     sysctl { 'net.ipv4.tcp_keepalive_time': ensure => 'present', permanent => 'yes', value => '1800',}
     sysctl { 'net.ipv4.tcp_keepalive_intvl': ensure => 'present', permanent => 'yes', value => '30',}
     sysctl { 'net.ipv4.tcp_keepalive_probes': ensure => 'present', permanent => 'yes', value => '5',}
     sysctl { 'net.ipv4.tcp_fin_timeout': ensure => 'present', permanent => 'yes', value => '30',}
   
     class { 'limits':
       config => {'*'       => { 'nofile'  => { soft => '2048'   , hard => '8192',   },},
                  'oracle'  => {  'nofile'  => { soft => '65535'  , hard => '65535',  },
                                  'nproc'   => { soft => '2048'   , hard => '2048',   },
                                  'memlock' => { soft => '1048576', hard => '1048576',},},},
       use_hiera => false,}

WebLogic configuration examples
-------------------------------

    class application_wls12 {
       include wls12_adf, wls12c_adf_domain
       Class['wls12_adf'] -> Class['wls12c_adf_domain']
    }
    class application_osb_soa {
       include wls1036osb_soa, wls_osb_soa_domain, wls_OSB_application_JDBC, wls_OSB_application_JMS
       Class['wls1036osb_soa'] -> Class['wls_osb_soa_domain'] -> Class['wls_OSB_application_JDBC'] -> Class['wls_OSB_application_JMS']
    }
    class application_wc {
  
     include wls1036_wc, wls_wc_wcc_bpm_domain
     Class['wls1036_wc'] -> Class['wls_wc_wcc_bpm_domain']
    }
    class application_osb {
       include wls1036osb, wls_osb_domain, wls_OSB_application_JDBC
       Class['wls1036osb'] -> Class['wls_osb_domain'] -> Class['wls_OSB_application_JDBC']
    }
    class application_wc {
     include wls1036_wc
    }    

### templates.pp

    include wls

    class wls12_adf{
     
    class { 'wls::urandomfix' :}

    if $jdkWls12cJDK == undef {
      $jdkWls12cJDK = 'jdk1.7.0_25'
    }
    if $wls12cVersion == undef {
      $wls12cVersion = "1212"
    }
    case $operatingsystem {
       CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
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
       adfFile      => 'fmw_infra_121200.jar',
       createUser   => true,
    } 
    } 
              
    class wls1036osb_soa{

      class { 'wls::urandomfix' :}

      if $jdkWls11gJDK == undef {
        $jdkWls11gJDK = 'jdk1.7.0_25'
      }
      if $wls11gVersion == undef {
        $wls11gVersion = "1036"
      }
      #$puppetDownloadMntPoint = "puppet:///middleware/"   
      $puppetDownloadMntPoint = "puppet:///modules/wls/" 
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
           $osOracleHome = "/opt/wls"
           $osMdwHome    = "/opt/wls/Middleware11gR1"
           $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
           $user         = "oracle"
           $group        = "dba"
           $downloadDir  = "/data/install/"
           $logDir      = "/data/logs"   
         }
         windows: { 
           $osOracleHome = "c:/oracle"
           $osMdwHome    = "c:/oracle/wls11g"
           $osWlHome     = "c:/oracle/wls11g/wlserver_10.3"
           $user         = "Administrator"
           $group        = "Administrators"
           $serviceName  = "C_oracle_wls11g_wlserver_10.3"
           $downloadDir  = "c:/temp"
           $logDir      = "c:/oracle/logs" 
         }
      }

      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, SLES, Debian: { 
            $mtimeParam = "1"
         }
         Solaris: { 
            $mtimeParam = "+1"
         }
      }

      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
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
     
      cron { 'oracle_soa1_lsinv' :
        command => "find ${osMdwHome}/Oracle_SOA1/cfgtoollogs/opatch/lsinv -name 'lsinventory*.txt'  -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_lsinv_soa1_purge.log 2>&1",
        user    => oracle,
        hour    => 06,
        minute  => 33,
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
      wls::installwls{'11gPS5':
        createUser   => true,
      }
    
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
         logDir      => $logDir,
         require     =>  Wls::Installsoa['soaPS6'],
       }
    
    }

    class wls1036_wc{

    class { 'wls::urandomfix' :}

    if $jdkWls11gJDK == undef {
      $jdkWls11gJDK = 'jdk1.7.0_25'
    }
    if $wls11gVersion == undef {
      $wls11gVersion = "1036"
    }
    $puppetDownloadMntPoint = "puppet:///middleware/"
    #  $puppetDownloadMntPoint = "puppet:///modules/wls/"                       
  
    case $operatingsystem {
       CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
         $osOracleHome = "/opt/oracle/wls"
         $osMdwHome    = "/opt/oracle/wls/Middleware11gR1"
         $osWlHome     = "/opt/oracle/wls/Middleware11gR1/wlserver_10.3"
         $user         = "oracle"
         $group        = "dba"
         $downloadDir  = "/data/install"
         $logDir       = "/data/logs"       
       }
       windows: { 
         $osOracleHome = "c:/oracle/middleware"
         $osMdwHome    = "c:/oracle/middleware/wls11g"
         $osWlHome     = "c:/oracle/middleware/wls11g/wlserver_10.3"
         $user         = "Administrator"
         $group        = "Administrators"
         $serviceName  = "C_oracle_middleware_wls11g_wlserver_10.3"
         $downloadDir  = "c:/temp"
         $logDir       = "c:/oracle/logs" 
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
      logDir      => $logDir,
      require     => Wls::Installsoa['soaPS6'],
    }
    }
    
    class wls1036osb{
      class { 'wls::urandomfix' :}

      if $jdkWls11gJDK == undef {
        $jdkWls11gJDK = 'jdk1.7.0_25'
      }
      if $wls11gVersion == undef {
        $wls11gVersion = "1036"
      }
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
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
    $adminListenPort = "7001"
    $nodemanagerPort = "5556"
    $address         = "localhost"
  
    case $operatingsystem {
       CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
         $osOracleHome = "/opt/oracle/wls"
         $osMdwHome    = "/opt/oracle/wls/Middleware12cADF"
         $osWlHome     = "/opt/oracle/wls/Middleware12cADF/wlserver"
         $user         = "oracle"
         $group        = "dba"
         $downloadDir  = "/data/install"
         $logDir       = "/data/logs" 
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
       CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: { 
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
      fullJDKName  => $jdkWls12gJDK,  
      user         => $user,
      group        => $group,
      serviceName  => $serviceName,  
    }
  
     #nodemanager starting 
     # in 12c start it after domain creation
     wls::nodemanager{'nodemanager12c':
       version    => "1212",
       listenPort => $nodemanagerPort,
       domain     => $wlsDomainName,     
       require    => Wls::Wlsdomain['adfDomain12c'],
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
      wlsUser      => "weblogic",
      password     => hiera('weblogic_password_default'),
    }

    # start AdminServers for configuration
    wls::wlscontrol{'startWLSAdminServer12c':
      wlsDomain     => $wlsDomainName,
      wlsDomainPath => "${osMdwHome}/user_projects/domains/${wlsDomainName}",
      wlsServer     => "AdminServer",
      action        => 'start',
      wlHome        => $osWlHome,
      fullJDKName   => $jdkWls12gJDK,  
      wlsUser       => "weblogic",
      password      => hiera('weblogic_password_default'),
      address       => $address,
      port          => $nodemanagerPort,
      user          => $user,
      group         => $group,
      downloadDir   => $downloadDir,
      logOutput     => true, 
      require       => Wls::Nodemanager['nodemanager12c'],
    }


    # create Server template for Dynamic Clusters 
    wls::wlstexec { 
      'createServerTemplate1':
       wlstype       => "server_templates",
       wlsObjectName => "serverTemplate1",
       script        => 'createServerTemplateCluster.py',
       params        =>  ["server_template_name          = 'serverTemplate1'",
                          "server_template_listen_port   = 7100",
                          "dynamic_server_name_arguments ='-XX:PermSize=128m -XX:MaxPermSize=256m -Xms512m -Xmx1024m'"],
       require       => Wls::Wlscontrol['startWLSAdminServer12c'];
    }
  
    # create Dynamic Cluster 
    wls::wlstexec { 
      'createDynamicCluster':
       wlstype       => "cluster",
       wlsObjectName => "dynamicCluster",
       script        => 'createDynamicCluster.py',
       params        =>  ["server_template_name       = 'serverTemplate1'",
                          "dynamic_cluster_name       = 'dynamicCluster'",
                          "dynamic_nodemanager_match  = 'LocalMachine'",
                          "dynamic_server_name_prefix = 'dynamic_server_'"],
       require       => Wls::Wlstexec['createServerTemplate1'];
    }
  
    # create file persistence store 1 for dynamic cluster 
    wls::wlstexec { 
      'createFilePersistenceStoreDynamicCluster':
       wlstype       => "filestore",
       wlsObjectName => "jmsModuleFilePersistence1",
       script        => 'createFilePersistenceStore2.py',
       params        =>  ["fileStoreName = 'jmsModuleFilePersistence1'",
                        "target          = 'dynamicCluster'",
                        "targetType      = 'Cluster'"],
       require       => Wls::Wlstexec['createDynamicCluster'];
    }
  
    # create jms server 1 for dynamic cluster 
    wls::wlstexec { 
      'createJmsServerDynamicCluster':
       wlstype       => "jmsserver",
       wlsObjectName => "jmsServer1",
       script      => 'createJmsServer2.py',
       params      =>  ["storeName      = 'jmsModuleFilePersistence1'",
                        "target         = 'dynamicCluster'",
                        "targetType     = 'Cluster'",
                        "jmsServerName  = 'jmsServer1'",
                        "storeType      = 'file'",
                        ],
       require     => Wls::Wlstexec['createFilePersistenceStoreDynamicCluster'];
    }
  
    # create jms module for dynamic cluster 
    wls::wlstexec { 
      'createJmsModuleCluster':
       wlstype       => "jmsmodule",
       wlsObjectName => "jmsClusterModule",
       script        => 'createJmsModule.py',
       params        =>  ["target         = 'dynamicCluster'",
                          "jmsModuleName  = 'jmsClusterModule'",
                          "targetType     = 'Cluster'",
                         ],
       require       => Wls::Wlstexec['createJmsServerDynamicCluster'];
    }
  
    # create jms subdeployment for dynamic cluster 
    wls::wlstexec { 
      'createJmsSubDeploymentForCluster':
       wlstype       => "jmssubdeployment",
       wlsObjectName => "jmsClusterModule/dynamicCluster",
       script        => 'createJmsSubDeployment.py',
       params        => ["target         = 'dynamicCluster'",
                         "jmsModuleName  = 'jmsClusterModule'",
                         "subName        = 'dynamicCluster'",
                         "targetType     = 'Cluster'"
                        ],
       require       => Wls::Wlstexec['createJmsModuleCluster'];
    }
  
    # create jms connection factory for jms module 
    wls::wlstexec { 
    
      'createJmsConnectionFactoryforCluster':
       wlstype       => "jmsobject",
       wlsObjectName => "cf",
       script        => 'createJmsConnectionFactory.py',
       params        =>["subDeploymentName = 'dynamicCluster'",
                        "jmsModuleName     = 'jmsClusterModule'",
                        "cfName            = 'cf'",
                        "cfJNDIName        = 'jms/cf'",
                        "transacted        = 'false'",
                        "timeout           = 'xxxx'"
                        ],
       require       => Wls::Wlstexec['createJmsSubDeploymentForCluster'];
    }
  
    # create jms error Queue for jms module 
    wls::wlstexec { 
    
      'createJmsErrorQueueforJmsModule':
       wlstype       => "jmsobject",
       wlsObjectName => "ErrorQueue2",
       script        => 'createJmsQueueOrTopic.py',
       params        =>["subDeploymentName = 'dynamicCluster'",
                        "jmsModuleName     = 'jmsClusterModule'",
                        "jmsName           = 'ErrorQueue2'",
                        "jmsJNDIName       = 'jms/ErrorQueue2'",
                        "jmsType           = 'queue'",
                        "distributed       = 'true'",
                        "balancingPolicy   = 'Round-Robin'",
                        "useRedirect       = 'false'",
                        "limit             = 'xxxxx'",
                        "policy            = 'xxxxx'",
                        "errorObject       = 'xxxxx'"
                        ],
       require       => Wls::Wlstexec['createJmsConnectionFactoryforCluster'];
    }
  
    # create jms Queue for jms module 
    wls::wlstexec { 
      'createJmsQueueforJmsModule':
       wlstype       => "jmsobject",
       wlsObjectName => "Queue1",
       script        => 'createJmsQueueOrTopic.py',
       params        => ["subDeploymentName  = 'dynamicCluster'",
                        "jmsModuleName       = 'jmsClusterModule'",
                        "jmsName             = 'Queue1'",
                        "jmsJNDIName         = 'jms/Queue1'",
                        "jmsType             = 'queue'",
                        "distributed         = 'true'",
                        "balancingPolicy     = 'Round-Robin'",
                        "useRedirect         = 'true'",
                        "limit               = '3'",
                        "policy              = 'Redirect'",
                        "errorObject         = 'ErrorQueue2'"
                        ],
       require     => Wls::Wlstexec['createJmsErrorQueueforJmsModule'];
    }

    # create Server template for Dynamic Coherence Clusters 
    wls::wlstexec { 
      'createServerTemplateCoherence':
       wlstype       => "server_templates",
       wlsObjectName => "serverTemplateCoherence",
       script        => 'createServerTemplateCluster.py',
       params        =>  ["server_template_name          = 'serverTemplateCoherence'",
                          "server_template_listen_port   = 7200",
                          "dynamic_server_name_arguments ='-XX:PermSize=128m -XX:MaxPermSize=256m -Xms512m -Xmx1024m'"],
       require       => Wls::Wlstexec['createJmsQueueforJmsModule'];
    }
  
    # create Dynamic Coherence Cluster 
    wls::wlstexec { 
      'createDynamicClusterCoherence':
       wlstype       => "cluster",
       wlsObjectName => "dynamicClusterCoherence",
       script        => 'createDynamicCluster.py',
       params        =>  ["server_template_name       = 'serverTemplateCoherence'",
                          "dynamic_cluster_name       = 'dynamicClusterCoherence'",
                          "dynamic_nodemanager_match  = 'LocalMachine'",
                          "dynamic_server_name_prefix = 'dynamic_coherence_server_'"],
       require       => Wls::Wlstexec['createServerTemplateCoherence'];
    }
  
    # create Coherence Cluster 
    wls::wlstexec { 
      'createClusterCoherence':
       wlstype       => "coherence",
       wlsObjectName => "clusterCoherence",
       script        => 'createCoherenceCluster.py',
       params        =>  ["coherence_cluster_name = 'clusterCoherence'",
                          "target                 = 'dynamicClusterCoherence'",
                          "targetType             = 'Cluster'",
                          "storage_enabled        = true",
                          "unicast_address        = 'localhost'",
                          "unicast_port           = 8088",
                          "multicast_address      = '231.1.1.1'",
                          "multicast_port         = 33387",
                          "machines               = ['localhost']"],
       require       => Wls::Wlstexec['createDynamicClusterCoherence'];
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
      $reposPrefix     = "DEV"
      # rcu soa repository schema password
      $reposPassword   = "Welcome02"
     
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
           $osOracleHome  = "/opt/wls"
           $osMdwHome     = "/opt/wls/Middleware11gR1"
           $osWlHome      = "/opt/wls/Middleware11gR1/wlserver_10.3"
           $user          = "oracle"
           $group         = "dba"
           $downloadDir   = "/data/install"
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

      # start AdminServers for configuration
      wls::wlscontrol{'startOSBSOAAdminServer':
       wlsDomain     => $wlsDomainName,
       wlsDomainPath => "${osMdwHome}/user_projects/domains/${wlsDomainName}",
       wlsServer     => "AdminServer",
       action        => 'start',
       wlHome        => $osWlHome,
       fullJDKName   => $jdkWls11gJDK,  
       wlsUser       => "weblogic",
       password      => hiera('weblogic_password_default'),
       address       => $address,
       port          => $nodemanagerPort,
       user          => $user,
       group         => $group,
       downloadDir   => $downloadDir,
       logOutput     => true, 
       require       =>  Wls::Wlsdomain['osbSoaDomain'],
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
        require       => Wls::Wlscontrol['startOSBSOAAdminServer'],
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
     }

	class wls_cluster2 {
	  
	    if $jdkWls11gJDK == undef {
	      $jdkWls11gJDK = 'jdk1.7.0_25'
	    }
	  
	    $wlsDomainName   = "WlsDomain"
	  
	  
	    $adminListenPort = "7001"
	    $nodemanagerPort = "5556"
	    $address         = "devagent40.alfa.local"
	  
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
	   
	    case $operatingsystem {
	       CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
	         $osOracleHome  = "/opt/oracle"
	         $osMdwHome     = "/opt/oracle/wls/Middleware11gR1"
	         $osWlHome      = "/opt/oracle/wls/Middleware11gR1/wlserver_10.3"
	         $user          = "oracle"
	         $group         = "dba"
	         $downloadDir   = "/data/install"
	         $logDir        = "/data/logs"
	       }
	       windows: { 
	         $osOracleHome  = "c:/oracle"
	         $osMdwHome     = "c:/oracle/middleware/wls11g"
	         $osWlHome      = "c:/oracle/middleware/wls11g/wlserver_10.3"
	         $user          = "Administrator"
	         $group         = "Administrators"
	         $serviceName   = "C_oracle_middleware_wls11g_wlserver_10.3"
	         $downloadDir   = "c:/temp"
	         $logDir        = "c:/oracle/logs" 
	       }
	    }
	  
	    $userConfigFile = "${userConfigDir}/${user}-${wlsDomainName}-WebLogicConfig.properties"
	    $userKeyFile    = "${userConfigDir}/${user}-${wlsDomainName}-WebLogicKey.properties"
	  
	    # default parameters for the wlst scripts
	    Wls::Wlstexec {
	      wlsDomain      => $wlsDomainName,
	      wlHome         => $osWlHome,
	      fullJDKName    => $jdkWls11gJDK,  
	      user           => $user,
	      group          => $group,
	      address        => "localhost",
	      userConfigFile => $userConfigFile,
	      userKeyFile    => $userKeyFile,
	      port           => "7001",
	      downloadDir    => $downloadDir,
	      logOutput      => false, 
	    }
	
	
	    # create machine
	    wls::wlstexec { 
	      'createRemoteMachine':
	       wlstype       => "machine",
	       wlsObjectName => "RemoteMachine",
	       script        => 'createMachine.py',
	       params        => ["machineName      = 'RemoteMachine'",
	                         "machineDnsName   = 'devagent41.alfa.local'",
	                        ],
	    }
	  
	  
	    # create managed server 1
	    wls::wlstexec { 
	      'createManagerServerWlsServer1':
	       wlstype       => "server",
	       wlsObjectName => "wlsServer1",
	       script        => 'createServer.py',
	       params        => ["javaArguments    = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Dweblogic.Stdout=/data/logs/wlsServer1.out -Dweblogic.Stderr=/data/logs/wlsServer1_err.out'",
	                         "wlsServerName    = 'wlsServer1'",
	                         "machineName      = 'LocalMachine'",
	                         "listenPort       = 9201",
	                         "nodeMgrLogDir    = '/data/logs'",
	                        ],
	      require        => Wls::Wlstexec['createRemoteMachine'],
	    }
	  
	    # create managed server 2
	    wls::wlstexec { 
	      'createManagerServerWlsServer2':
	       wlstype       => "server",
	       wlsObjectName => "wlsServer2",
	       script        => 'createServer.py',
	       params        => ["javaArguments    = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Dweblogic.Stdout=/data/logs/wlsServer2.out -Dweblogic.Stderr=/data/logs/wlsServer2_err.out'",
	                         "wlsServerName    = 'wlsServer2'",
	                         "machineName      = 'RemoteMachine'",
	                         "listenPort       = 9202",
	                         "nodeMgrLogDir    = '/data/logs'",
	                        ],
	      require        => Wls::Wlstexec['createManagerServerWlsServer1'],
	    }
	  
	    # create cluster
	    wls::wlstexec { 
	      'createClusterWeb':
	       wlstype       => "cluster",
	       wlsObjectName => "WebCluster",
	       script        => 'createCluster.py',
	       params        => ["clusterName      = 'WebCluster'",
	                         "clusterNodes     = 'wlsServer1,wlsServer2'",
	                        ],
	      require        => Wls::Wlstexec['createManagerServerWlsServer2'],
	    }
	}
	
	
	class wls_copydomain2 {
	
	    if $jdkWls11gJDK == undef {
	      $jdkWls11gJDK = 'jdk1.7.0_25'
	    }
	  
	    $wlsDomainName   = "WlsDomain"
	  
	  
	    $adminListenPort = "7001"
	    $nodemanagerPort = "5556"
	    $address         = "devagent40.alfa.local"
	  
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
	   
	    case $operatingsystem {
	       CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
	         $osOracleHome  = "/opt/oracle"
	         $osMdwHome     = "/opt/oracle/wls/Middleware11gR1"
	         $osWlHome      = "/opt/oracle/wls/Middleware11gR1/wlserver_10.3"
	         $user          = "oracle"
	         $group         = "dba"
	         $downloadDir   = "/data/install"
	         $logDir        = "/data/logs"
	       }
	       windows: { 
	         $osOracleHome  = "c:/oracle"
	         $osMdwHome     = "c:/oracle/middleware/wls11g"
	         $osWlHome      = "c:/oracle/middleware/wls11g/wlserver_10.3"
	         $user          = "Administrator"
	         $group         = "Administrators"
	         $serviceName   = "C_oracle_middleware_wls11g_wlserver_10.3"
	         $downloadDir   = "c:/temp"
	         $logDir        = "c:/oracle/logs" 
	       }
	    }
	 	
	    # install SOA OSB domain
	    wls::copydomain{'copyWlsDomain':
	     version         => '1111',
	     wlHome          => $osWlHome,
	     mdwHome         => $osMdwHome,
	     fullJDKName     => $jdkWls11gJDK, 
	     domain          => $wlsDomainName,
	     adminListenAdr  => $address,
	     adminListenPort => $adminListenPort,
	     wlsUser         => "weblogic",
	     password        => hiera('weblogic_password_default'),
	     user            => $user,
	     userPassword    => 'oracle',
	     group           => $group,    
	     downloadDir     => $downloadDir, 
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
       CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: { 
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
       CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
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

    # start AdminServers for configuration
    wls::wlscontrol{'startWCAdminServer':
      wlsDomain     => $wlsDomainName,
      wlsDomainPath => "${osMdwHome}/user_projects/domains/${wlsDomainName}",
      wlsServer     => "AdminServer",
      action        => 'start',
      wlHome        => $osWlHome,
      fullJDKName   => $jdkWls11gJDK,  
      wlsUser       => "weblogic",
      password      => hiera('weblogic_password_default'),
      address       => $address,
      port          => $nodemanagerPort,
      user          => $user,
      group         => $group,
      downloadDir   => $downloadDir,
      logOutput     => true, 
      require       =>  Wls::Wlsdomain['wcWccBpmDomain'],
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
      require       => Wls::Wlscontrol['startWCAdminServer'],
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
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
           $osOracleHome = "/opt/wls"
           $osMdwHome    = "/opt/wls/Middleware11gR1"
           $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
           $user         = "oracle"
           $group        = "dba"
           $downloadDir  = "/data/install"
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
           $downloadDir  = "c:\\temp"
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

      # start AdminServers for configuration
      wls::wlscontrol{'startOSBAdminServer':
       wlsDomain     => $wlsDomainName,
       wlsDomainPath => "${osMdwHome}/user_projects/domains/${wlsDomainName}",
       wlsServer     => "AdminServer",
       action        => 'start',
       wlHome        => $osWlHome,
       fullJDKName   => $jdkWls11gJDK,  
       wlsUser       => "weblogic",
       password      => hiera('weblogic_password_default'),
       address       => $address,
       port          => $nodemanagerPort,
       user          => $user,
       group         => $group,
       downloadDir   => $downloadDir,
       logOutput     => true, 
       require       =>  Wls::Wlsdomain['osbDomain'],
      }
    
      Wls::Changefmwlogdir {
        mdwHome        => $osMdwHome,
        user           => $user,
        group          => $group,
        address        => $address,
        port           => $adminListenPort,
        wlsUser        => "weblogic",
        password       => "weblogic1",
        downloadDir    => $downloadDir, 
      }
    
      wls::changefmwlogdir{
       'AdminServer':
        wlsServer    => "AdminServer",
        logDir       => $logDir,
        require      => Wls::Wlscontrol['startOSBAdminServer'],
      }
     }
    
    class wls_OSB_application_JDBC{
    
      if $jdkWls11gJDK == undef {
        $jdkWls11gJDK = 'jdk1.7.0_09'
      }
    
      $userConfigFile  = '/home/oracle/oracle-osbSoaDomain-WebLogicConfig.properties'
      $userKeyFile     = '/home/oracle/oracle-osbSoaDomain-WebLogicKey.properties'
    
      $wlsDomainName   = 'osbSoaDomain'
    
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
           $osMdwHome    = "/opt/wls/Middleware11gR1"
           $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
           $user         = "oracle"
           $group        = "dba"
           $downloadDir  = "/data/install"
         }
         windows: { 
           $osMdwHome    = "c:/oracle/wls11g"
           $osWlHome     = "c:/oracle/wls11g/wlserver_10.3"
           $user         = "Administrator"
           $group        = "Administrators"
           $serviceName  = "C_oracle_wls11g_wlserver_10.3"
           $downloadDir  = "c:\\temp"
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
                          "extraProperties             = 'oracle.net.CONNECT_TIMEOUT,SendStreamAsBlob'",
                          "extraPropertiesValues       = '10000,true'",
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
      $userConfigFile  = '/home/oracle/oracle-osbSoaDomain-WebLogicConfig.properties'
      $userKeyFile     = '/home/oracle/oracle-osbSoaDomain-WebLogicKey.properties'
    
      $wlsDomainName   = 'osbSoaDomain'
     
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
           $osMdwHome    = "/opt/wls/Middleware11gR1"
           $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
           $user         = "oracle"
           $group        = "dba"
           $downloadDir  = "/data/install"
         }
         windows: { 
           $osMdwHome    = "c:/oracle/wls11g"
           $osWlHome     = "c:/oracle/wls11g/wlserver_10.3"
           $user         = "Administrator"
           $group        = "Administrators"
           $serviceName  = "C_oracle_wls11g_wlserver_10.3"
           $downloadDir  = "c:\\temp"
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
    
      # create file persistence store for osb_server1 
      wls::wlstexec { 
        'createFilePersistenceStoreOSBServer':
         wlstype       => "filestore",
         wlsObjectName => "jmsModuleFilePersistence",
         script        => 'createFilePersistenceStore.py',
         port          => $adminServerPort,
         params        =>  ["fileStoreName = 'jmsModuleFilePersistence'",
                          "serverTarget  = 'osb_server1'"],
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
         require       => Wls::Wlstexec['createJmsServerOSBServer'];
      }

      # create jms Quota for osb_server1 jms module
      wls::wlstexec { 
        'createJmsModuleQuotaHigh':
         wlstype       => "jmsquota",
         wlsObjectName => "jmsModule/QuotaHigh",
         script        => 'createJmsQuota.py',
         params        =>  ["jmsQuotaName    = 'QuotaHigh'",
                            "jmsModuleName   = 'jmsModule'",
                            "policy          = 'FIFO'",
                            "bytesMaximum    = 9223372036854775807",
                            "messagesMaximum = 9223372036854775807",
                            "shared          = false",
                           ],
         require       => Wls::Wlstexec['createJmsModuleOSBServer'];
      }
    
      # create jms Quota for osb_server1 jms module
      wls::wlstexec { 
        'createJmsModuleQuotaLow':
         wlstype       => "jmsquota",
         wlsObjectName => "jmsModule/QuotaLow",
         script        => 'createJmsQuota.py',
         params        =>  ["jmsQuotaName    = 'QuotaLow'",
                            "jmsModuleName   = 'jmsModule'",
                            "policy          = 'PREEMPTIVE'",
                            "bytesMaximum    = 1000000000000",
                            "messagesMaximum = 1000000000000",
                            "shared          = true",
                           ],
         require       => Wls::Wlstexec['createJmsModuleQuotaHigh'];
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
                           "targetType     = 'Server'",
                          ],
         require       => Wls::Wlstexec['createJmsModuleQuotaLow'];
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
                           "targetType     = 'JMSServer'",
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
                          "timeout           = 'xxxx'",
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
                          "errorObject       = 'xxxxx'",
                          "jmsQuota          = 'QuotaLow'",
                          ],
         require     => Wls::Resourceadapter['JmsAdapter_hr'];
      }
     }  
