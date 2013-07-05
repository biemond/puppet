Oracle WebLogic orautils puppet module
=======================================================

changes  
0.1.3 bug fixes
0.1.1 support for Solaris


Generates WLS Scripts in /opt/scripts/wls
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

change the params.pp class so the defaults match with your environment or add extra changes based on the hostname  


     class utils::params {
     
       $osOracleHome = $::hostname ? { 
                                        xxxxxx     => "/data/wls",
                                        default    => "/opt/wls", 
                                    }
     
       $osDownloadFolder = $::hostname ? { 
                                        default    => "/data/install", 
                                    }
     
       $osMdwHome    = "${osOracleHome}/Middleware11gR1"
       $osWlHome     = "${osOracleHome}/Middleware11gR1/wlserver_10.3" 
     
       $oraUser      = $::hostname ? { default => "oracle", }
     
     
       $osDomain     = $::hostname ? { 
                                        default    => "osbSoaDomain", 
                                    }
                                    
       $osDomainPath = $::hostname ? { 
                                        default    => "${osMdwHome}/user_projects/domains/${osDomain}", 
                                    }
     
       $nodeMgrPort = $::hostname ?  { 
                                        default    => "5556", 
                                    }                                 
     
       $wlsUser     = $::hostname ?  { 
                                        default    => "weblogic", 
                                    }                                 
     
       $wlsPassword = $::hostname ?  { 
                                        default    => "weblogic1", 
                                    }       
     
       $wlsAdminServer = $::hostname ?  { 
                                        default    => "AdminServer", 
                                    }       
     
     }         