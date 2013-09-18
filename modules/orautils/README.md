Oracle WebLogic orautils puppet module
=======================================================

changes

- 0.1.8 updated license to Apache 2.0
- 0.1.7 BugFixes for nodemanager startup & showStatus       
- 0.1.6 Autostart of the Nodemanager ( chkconfig )     
- 0.1.5 WebLogic 12.1.2 support for NodeManager  
- 0.1.4 added Suse SLES as Operating System  
- 0.1.3 bug fixes  
- 0.1.1 support for Solaris  

Generates WLS Scripts in /opt/scripts/wls
-----------------------------------------

install auto start script for the nodemanager of WebLogic ( 10.3, 11g, 12.1.1 ) or 12.1.2  

	   orautils::nodemanagerautostart{"autostart ${wlsDomainName}":
	      version     => "1212",
	      wlHome      => $osWlHome, 
	      user        => $user,
	      domain      => $wlsDomainName,
	      logDir      => $logDir,
	   }

	   orautils::nodemanagerautostart{"autostart weblogic 11g":
	      version     => "1111",
	      wlHome      => $osWlHome, 
	      user        => $user,
	   }


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
		                                    devagent1  => "/opt/oracle/wls",
		                                    devagent10 => "/opt/oracle/wls",
		                                    devagent30 => "/opt/oracle/wls",
		                                    wls12      => "/oracle/product",
		                                    default    => "/opt/wls", 
		                                }
		
		  $osDomainType = $::hostname ? {
		                                    devagent30 => "web",
		                                    devagent31 => "soa",
		                                    wls12      => "admin",
		                                    default    => "web", 
		                                }
		
		
		  $osDownloadFolder = $::hostname ? {
		  	                                  devagent1  => "/data/install/oracle", 
		                                      default    => "/data/install", 
		                                     }
		
			$shell        = $::operatingsystem ? { Solaris => "!/usr/bin/ksh",
		  															         default => "!/bin/sh",
		  															       }   
		
		  $osMdwHome     = $::hostname ?  { wls12    => "${osOracleHome}/Middleware12c",
		                                    default  => "${osOracleHome}/Middleware11gR1",
		                                  }   
		
		  $osWlHome     = $::hostname ?  { wls12    => "${osOracleHome}/Middleware12c/wlserver",
		                                   default  => "${osOracleHome}/Middleware11gR1/wlserver_10.3",
		                                 }   
		
		  $oraUser      = $::hostname ? { default => "oracle", }
		
		  $userHome     = $::operatingsystem ? { Solaris => "/export/home",
		  															         default => "/home", 
		  															       }
		  $oraInstHome  = $::operatingsystem ? { Solaris => "/var/opt",
		  															         default => "/etc", 
		  															       }
		
		  $osDomain     = $::hostname ? {   wls12      => "Wls12c",
		                                    default    => "osbSoaDomain", 
		                                }
		                                
		  $osDomainPath = $::hostname ? { 
		                                    default    => "${osMdwHome}/user_projects/domains/${osDomain}", 
		                                }
		
		  $nodeMgrPath = $::hostname ? { 
		                                    wls12      => "${osMdwHome}/user_projects/domains/${osDomain}/bin", 
		                                    default    => "${osMdwHome}/server/bin", 
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