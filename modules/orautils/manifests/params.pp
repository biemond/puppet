class orautils::params {

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