class orautils::params {

  $osOracleHome = $::hostname ? { 
                                    xxxxxx     => "/data/wls",
                                    devagent1  => "/opt/oracle/wls",
                                    devagent10 => "/opt/oracle/wls",
                                    devagent30 => "/opt/oracle/wls",
                                    default    => "/opt/wls", 
                                }

  $osDomainType = $::hostname ? {
                                    devagent30 => "web",
                                    devagent31 => "soa",
                                    default    => "web", 
                                }


  $osDownloadFolder = $::hostname ? {
  	                                  devagent1  => "/data/install/oracle", 
                                      default    => "/data/install", 
                                     }

	$shell        = $::operatingsystem ? { Solaris => "!/usr/bin/ksh",
  															         default => "!/bin/sh",
  															       }   


  $osMdwHome    = "${osOracleHome}/Middleware11gR1"
  $osWlHome     = "${osOracleHome}/Middleware11gR1/wlserver_10.3" 

  $oraUser      = $::hostname ? { default => "oracle", }

  $userHome     = $::operatingsystem ? { Solaris => "/export/home",
  															         default => "/home", 
  															       }
  $oraInstHome  = $::operatingsystem ? { Solaris => "/var/opt",
  															         default => "/etc", 
  															       }

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