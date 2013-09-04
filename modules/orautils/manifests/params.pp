class orautils::params {

  $osOracleHome = $::hostname ? { 
                                    devagent1  => "/opt/oracle/wls",
                                    devagent10 => "/opt/oracle/wls",
                                    devagent30 => "/opt/oracle/wls",
                                    wls12      => "/oracle/product",
                                    default    => "/opt/wls", 
                                }

  $oraInventory = $::hostname ? { 
                                    devagent1  => "/opt/oracle/oraInventory",
                                    devagent10 => "/opt/oracle/oraInventory",
                                    devagent30 => "/opt/oracle/oraInventory",
                                    wls12      => "/oracle/oraInventory",
                                    default    => "/opt/wls/oraInventory", 
                                }



  $osDomainType = $::hostname ? {
                                    devagent30 => "soa",
                                    devagent31 => "soa",
                                    wls12      => "admin",
                                    default    => "web", 
                                }

  $osLogFolder = $::hostname ? {
                                      default    => "/data/logs", 
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
                                    default    => "${osWlHome}/server/bin", 
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