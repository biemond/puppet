class orautils::params {

  $osOracleHome = $::hostname ? {
                                    wls12           => "/oracle/product",
                                    soabeta2        => "/opt/oracle/wls",
                                    oimapp          => "/opt/oracle",
                                    default         => "/opt/wls",
                                }

  $oraInventory = $::hostname ? {
                                    soabeta2        => "/home/oracle/soabetainv",
                                    wls12           => "/oracle/oraInventory",
                                    oimapp          => "/opt/oracle/oraInventory",
                                    default         => "/opt/wls/oraInventory",
                                }

  $osDomainType = $::hostname ? {
                                    devagent31      => "soa",
                                    wls12           => "admin",
                                    oimapp          => "oim",
                                    default         => "web",
                                }

  $osLogFolder = $::hostname ? { default    => "/data/logs", }


  $osDownloadFolder = $::hostname ? { default    => "/data/install",}

	$shell        = $::operatingsystem ? { Solaris => "!/usr/bin/ksh",
  															         default => "!/bin/sh",
  															       }

  $osMdwHome     = $::hostname ?  { wls12           => "${osOracleHome}/Middleware12c",
                                    default         => "${osOracleHome}/Middleware11gR1",
                                  }

  $osWlHome     = $::hostname ?  { wls12           => "${osOracleHome}/Middleware12c/wlserver",
                                   default         => "${osOracleHome}/Middleware11gR1/wlserver_10.3",
                                 }

  $oraUser      = $::hostname ? { default => "oracle", }

  $userHome     = $::operatingsystem ? { Solaris => "/export/home",
  															         default => "/home",
  															       }

  $oraInstHome  = $::operatingsystem ? { Solaris => "/var/opt",
  															         default => "/etc",
  															       }

  $osDomain     = $::hostname ? {   wls12           => "Wls12c",
                                    oimapp          => "oimDomain",
                                    default         => "osbSoaDomain",
                                }

  $osDomainPath = $::hostname ? {
                                    default    => "${osMdwHome}/user_projects/domains/${osDomain}",
                                }

  $nodeMgrPath = $::hostname ?  {
                                    wls12           => "${osMdwHome}/user_projects/domains/${osDomain}/bin",
                                    default         => "${osWlHome}/server/bin",
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
