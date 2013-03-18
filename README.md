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

Oracle Database Linux puppet module
=================================================

created by Edwin Biemond   
[biemond.blogspot.com](http://biemond.blogspot.com)    
[Github homepage](https://github.com/biemond/puppet)    

Should work for RedHat,CentOS ,Ubuntu, Debian or OracleLinux 

Oracle Database Features
---------------------------

- Oracle Database 11.2.0.3 Linux installation
- Oracle Database 11.2.0.1 Linux installation
- Oracle Database Net configuration   
- Oracle Database Listener   
- Apply OPatch  
- Create database instances  
- Stop/Start database instances  
- Installs RCU repositoy for Oracle SOA Suite   

Coming in next release

- Oracle Database 11.2.0.1 Linux Client installation
   
  

Oracle WebLogic / Fusion Middleware puppet module
=================================================

created by Edwin Biemond   
[biemond.blogspot.com](http://biemond.blogspot.com)    
[Github homepage](https://github.com/biemond/puppet)    

for more infomation about this Oracle WebLogic / FMW puppet module see this [AMIS blogpost](http://technology.amis.nl/2012/10/13/configure-fmw-servers-with-puppet/)

Windows Puppet agents
--------------
for windows puppet agents it is necessary to install unxutils tools and extract this on the c drive C:\unxutils<br>
For windows and JDK, you need copy the jdk to c:\oracle\ ( unpossible with the space in c:\program files folder).<br>

Also for registry support install this on the master, read this [registry blogpost](http://puppetlabs.com/blog/module-of-the-week-puppetlabs-registry-windows/) and install this forge module on the puppet master<br>
puppet module install puppetlabs/registry

For other agents like RedHat,CentOS ,Ubuntu, Debian or OracleLinux should work without any problems 

WLS WebLogic Features
---------------------------

- installs WebLogic 10g,11g,12c
- apply bsu patch ( WebLogic Patch )

- installs Oracle Service Bus 11g OSB with or without OEPE ( Oracle Eclipse )
- installs Oracle Soa Suite 11g 
- apply oracle patch ( OPatch for OSB and Soa Suite )

- installs Oracle JDeveloper 11g + soa suite plugin

- configures + starts nodemanager

- domain creation + domain pack
- domain OSB creation + domain pack
- domain OSB + SOA creation + domain pack

- can start the AdminServer for configuration 
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