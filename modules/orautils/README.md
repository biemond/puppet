Oracle WebLogic orautils puppet module
=======================================================
[![Build Status](https://travis-ci.org/biemond/biemond-orautils.png)](https://travis-ci.org/biemond/biemond-orautils)


changes

- 0.2.5 Custom Identity and Trust store support in all the scripts 
- 0.2.4 JSSE option, stopWebLogicAdmin localhost bugfix and nodemanager service script fix 
- 0.2.2 nodemanager address param for the startWebLogicAdmin script ( instead of localhost)  
- 0.2.0 new way to overide the params , use params.pp or use the variables  
- 0.1.8 updated license to Apache 2.0
- 0.1.7 BugFixes for nodemanager startup & showStatus       
- 0.1.6 Autostart of the Nodemanager ( chkconfig )     
- 0.1.5 WebLogic 12.1.2 support for NodeManager  
- 0.1.4 added Suse SLES as Operating System  
- 0.1.3 bug fixes  
- 0.1.1 support for Solaris  


usage:

change the params.pp class so the defaults match with your environment or add extra values based on the hostname

use:


    include orautils

or override the defaults which does not match with your environment and call the class orautils with the necessary parameters

osDomainTypeParam => soa|admin|web|oim

use:


    class{'orautils':
        osOracleHomeParam      => "/opt/oracle",
        oraInventoryParam      => "/opt/oracle/oraInventory",
        osDomainTypeParam      => "soa",
        osLogFolderParam       => "/data/logs",
        osDownloadFolderParam  => "/data/install",
        osMdwHomeParam         => "/opt/oracle/wls/Middleware11gR1",
        osWlHomeParam          => "/opt/oracle/wls/Middleware11gR1/wlserver_10.3",
        oraUserParam           => "oracle",
        osDomainParam          => "osbSoaDomain",
        osDomainPathParam      => "/opt/oracle/wls/Middleware11gR1/user_projects/domains/osbSoaDomain",
        nodeMgrPathParam       => "/opt/oracle/wls/Middleware11gR1/wlserver_10.3/server/bin",
        nodeMgrPortParam       => 5556,
        nodeMgrAddressParam    => 'localhost',
        wlsUserParam           => "weblogic",
        wlsPasswordParam       => "weblogic1",
        wlsAdminServerParam    => "AdminServer",
        jsseEnabledParam       => false,
    } 

or with hiera  ( include orautils )

    orautils::osOracleHomeParam:      "/opt/oracle"
    orautils::oraInventoryParam:      "/opt/oracle/oraInventory"
    orautils::osDomainTypeParam:      "admin"
    orautils::osLogFolderParam:       "/data/logs"
    orautils::osDownloadFolderParam:  "/data/install"
    orautils::osMdwHomeParam:         "/opt/oracle/wls/Middleware11gR1"
    orautils::osWlHomeParam:          "/opt/oracle/wls/Middleware11gR1/wlserver_10.3"
    orautils::oraUserParam:           "oracle"
    
    orautils::osDomainParam:          "Wls1036"
    orautils::osDomainPathParam:      "/opt/oracle/wlsdomains/domains/Wls1036"
    orautils::nodeMgrPathParam:       "/opt/oracle/middleware11g/wlserver_10.3/server/bin"
    
    orautils::nodeMgrPortParam:       5556
    orautils::nodeMgrAddressParam:    'localhost'
    orautils::wlsUserParam:           "weblogic"
    orautils::wlsPasswordParam:       "weblogic1"
    orautils::wlsAdminServerParam:    "AdminServer"
    orautils::jsseEnabledParam:       true


install auto start script for the nodemanager of WebLogic ( 10.3, 11g, 12.1.1 ) or 12.1.2  

only for WebLogic 12.1.2 and higher


     orautils::nodemanagerautostart{"autostart ${wlsDomainName}":
        version     => "1212",
        wlHome      => $osWlHome, 
        user        => $user,
        domain      => $wlsDomainName,
        logDir      => $logDir,
        jsseEnabled => false,
     }


only for WebLogic 10 or 11g


     orautils::nodemanagerautostart{"autostart weblogic 11g":
        version     => "1111",
        wlHome      => $osWlHome, 
        user        => $user,
        jsseEnabled => false,
     }


Generates WebLogic scripts in /opt/scripts/wls
-----------------------------------------


**cleanOracleEnvironment.sh**  
Remove all Oracle WebLogic existence so you can deploy again  
Actions  
1. Remove domain pack files, ${osDownloadFolder}/domain_*.*  
2. Remove mdwhome, $osOracleHome  
3. Remove beahome list of user $oraUser  
4. Remove /etc/oraInst.loc  
5. Remove ${osDownloadFolder}/osb  
6. Remove ${osDownloadFolder}/soa  
7  Remove ${osDownloadFolder}/*.xml  

**showStatus.sh**  
1. Shows if the AdminServer, Soa and OSB server is running plus the PIDs  
2. Shows if the NodeManager is running plus the PID  

**startNodeManager.sh**  
Starts the nodemanager

**stopNodeManager.sh**  
Stops the nodemanager

**startWeblogicAdmin.sh**  
1. Checks first if the nodemanager is running  
2. Check if the AdminServer is already started  
3. Start the WebLogic Adminserver from the nodemanager   

**stopWeblogicAdmin.sh**  
1. Checks first if the nodemanager is running  
2. Check if the AdminServer is running  
3. Stops the WebLogic Adminserver from the nodemanager  
     