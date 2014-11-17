# Oracle WebLogic orautils puppet module
[![Build Status](https://travis-ci.org/biemond/biemond-orautils.png)](https://travis-ci.org/biemond/biemond-orautils)

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
        oraGroupParam          => "dba",
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
    orautils::oraGroupParam:          "dba"

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
      version     => '1212',
      wlHome      => '/opt/oracle/middleware12c/wlserver',
      user        => 'oracle',
      domain      => 'Wls1212',
      domainPath  => '/opt/oracle/middleware12c/user_projects/domains/Wls1212'
    }

only for WebLogic 10 or 11g

    orautils::nodemanagerautostart{"autostart weblogic 11g":
      version     => "1111",
      wlHome      => "/opt/oracle/middleware11g/wlserver_10.3",
      user        => 'wls',
    }

or with JSSE and custom trust

    orautils::nodemanagerautostart{"autostart weblogic 11g":
      version                 => "1111",
      wlHome                  => "/opt/oracle/middleware11g/wlserver_10.3",
      user                    => 'oracle',
      jsseEnabled             => true,
      customTrust             => true,
      trustKeystoreFile       => '/vagrant/truststore.jks',
      trustKeystorePassphrase => 'XXX',
    }

## Add WebLogic scripts to /opt/scripts/wls

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
