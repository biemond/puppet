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

example usage
-------------

    include jdk7

    jdk7::install7{ 'jdk1.7.0_17':
      version     =>  "7u17" , 
      fullVersion =>  "jdk1.7.0_17", 
      x64         =>  "true",
      downloadDir =>  "/data/install/",
    }
 
