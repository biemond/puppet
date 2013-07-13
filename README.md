Puppet modules
==============

jdk7 JAVA SE 7 puppet module
============================== 

installs only the java tar.gz files
-----------------------------------
this is because rpm post install fails with some pack error

installs jdk on linux based systems with x64 or 32 bits   
add the jdk-7u7-linux-x64.tar.gz (downloaded from Oracle website) to the files folder of this jdk7 module

- download the tar.gz to the download folder of the puppet agent server
- unpack the java tar.gz
- set the java links in /usr/java ( latest and default ) 
- set this java as default
- updates urandom device for weblogic performance in java.security

JRockit JAVA SE 6 puppet module
==============================

Installs the jdk and optionally the jre, demos etc.
---------------------------------------------------

Installs the jrockit jdk on linux and windows based systems with 64 or 32 bit architecture. The approriate installer must be copied to the files directory of the module; for example jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin

The module does the following:

- downloads the installer to the download folder of the puppet agent host
- performs a silent installation
- sets the java links in /usr/java ( latest and default ) 
- adds to alternatives for linux systems
- optionally sets JRockit as default java

The default settings are:

- Demos are not installed
- Source is not installed
- The jre is installed
- The installed version is set as the default


Oracle Database Linux puppet module
=================================================

created by Edwin Biemond   
[biemond.blogspot.com](http://biemond.blogspot.com)    
[Github homepage](https://github.com/biemond/puppet)    

Should work for RedHat,CentOS ,Ubuntu, Debian or OracleLinux 

Oracle Database Features
---------------------------

- Oracle Database 12.1.0.1 Linux installation
- Oracle Database 11.2.0.3 Linux installation
- Oracle Database 11.2.0.1 Linux installation
- Oracle Database Net configuration   
- Oracle Database Listener
- OPatch upgrade      
- Apply OPatch  
- Create database instances  
- Stop/Start database instances  
- Installs RCU repositoy for Oracle SOA Suite / Webcenter ( 11.1.1.6.0 and 11.1.1.7.0 )   

   
  
Oracle WebLogic / Fusion Middleware puppet module
=================================================

created by Edwin Biemond  email biemond at gmail dot com   
[biemond.blogspot.com](http://biemond.blogspot.com)    
[Github homepage](https://github.com/biemond/puppet)    

Should work for Solaris x86 64, Windows, RedHat, CentOS, Ubuntu, Debian or OracleLinux 

Version updates
---------------

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

- installs Oracle JDeveloper 11g + soa suite plugin

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


Oracle WebLogic orautils puppet module
=======================================================

Generates WLS Scripts in /opt/scripts/wls
-----------------------------------------

1. cleanOracleEnvironment.sh
2. showStatus.sh
3. startNodeManager.sh
4. stopNodeManager.sh
5. startWeblogicAdmin.sh
6. stopWeblogicAdmin.sh                                            