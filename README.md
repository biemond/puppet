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

Should work for RedHat,CentOS ,Ubuntu, Debian, Suse SLES or OracleLinux 

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

Should work for Solaris x86 64, Windows, RedHat, CentOS, Ubuntu, Debian, Suse SLES or OracleLinux 

See the wls module for all the latest details


Oracle WebLogic orautils puppet module
=======================================================

Autostart the WebLogic Nodemanager ( etc/init.d , chkconfig )

Generates WLS Scripts in /opt/scripts/wls
-----------------------------------------

1. cleanOracleEnvironment.sh
2. showStatus.sh
3. startNodeManager.sh
4. stopNodeManager.sh
5. startWeblogicAdmin.sh
6. stopWeblogicAdmin.sh                                            