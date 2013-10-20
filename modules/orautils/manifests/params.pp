class orautils::params {

  $osOracleHome = $::hostname ? {
                                    devagent1       => "/opt/oracle/wls",
                                    devagent10      => "/opt/oracle/wls",
                                    devagent30      => "/opt/oracle/wls",
                                    devagent31      => "/opt/oracle",
                                    devagent40      => "/opt/oracle/wls",
                                    devagent41      => "/opt/oracle/wls",
                                    wls12           => "/oracle/product",
                                    soabeta2        => "/opt/oracle/wls",
                                    vagrantoel64    => "/oracle/product",
                                    vagrantcentos64 => "/oracle/product",
                                    oimapp          => "/opt/oracle",
                                    default         => "/opt/wls",
                                }

  $oraInventory = $::hostname ? {
                                    devagent1       => "/opt/oracle/oraInventory",
                                    devagent10      => "/opt/oracle/oraInventory",
                                    devagent30      => "/opt/oracle/oraInventory",
                                    devagent31      => "/opt/oracle/oraInventory",
                                    devagent40      => "/opt/oracle/oraInventory",
                                    devagent41      => "/opt/oracle/oraInventory",
                                    soabeta2        => "/home/oracle/soabetainv",
                                    wls12           => "/oracle/oraInventory",
                                    vagrantoel64    => "/oracle/oraInventory",
                                    vagrantcentos64 => "/oracle/oraInventory",
                                    oimapp          => "/opt/oracle/oraInventory",
                                    default         => "/opt/wls/oraInventory",
                                }



  $osDomainType = $::hostname ? {
                                    devagent30      => "soa",
                                    devagent31      => "admin",
                                    wls12           => "admin",
                                    devagent40      => "admin",
                                    devagent41      => "admin",
                                    soabeta2        => "soa",
                                    vagrantoel64    => "admin",
                                    vagrantcentos64 => "admin",
                                    oimapp          => "oim",
                                    default         => "web",
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

  $osMdwHome     = $::hostname ?  { wls12           => "${osOracleHome}/Middleware12c",
                                    vagrantoel64    => "${osOracleHome}/Middleware12c",
                                    vagrantcentos64 => "${osOracleHome}/Middleware12c",
                                    devagent31      => "${osOracleHome}/Middleware12c",
                                    soabeta2        => "${osOracleHome}/Middleware12c",
                                    default         => "${osOracleHome}/Middleware11gR1",
                                  }

  $osWlHome     = $::hostname ?  { wls12           => "${osOracleHome}/Middleware12c/wlserver",
                                   vagrantoel64    => "${osOracleHome}/Middleware12c/wlserver",
                                   vagrantcentos64 => "${osOracleHome}/Middleware12c/wlserver",
                                   devagent31      => "${osOracleHome}/Middleware12c/wlserver",
                                   soabeta2        => "${osOracleHome}/Middleware12c/wlserver",
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
                                    vagrantoel64    => "Wls12c",
                                    vagrantcentos64 => "Wls12c",
                                    soabeta2        => "soabeta2",
                                    devagent31      => "Wls12c",
                                    devagent40      => "WlsDomain",
                                    devagent41      => "WlsDomain",
                                    oimapp          => "oimDomain",
                                    default         => "osbSoaDomain",
                                }

  $osDomainPath = $::hostname ? {
                                    default    => "${osMdwHome}/user_projects/domains/${osDomain}",
                                }

  $nodeMgrPath = $::hostname ? {
                                    wls12           => "${osMdwHome}/user_projects/domains/${osDomain}/bin",
                                    vagrantoel64    => "${osMdwHome}/user_projects/domains/${osDomain}/bin",
                                    vagrantcentos64 => "${osMdwHome}/user_projects/domains/${osDomain}/bin",
                                    devagent31      => "${osMdwHome}/user_projects/domains/${osDomain}/bin",
                                    soabeta2        => "${osMdwHome}/user_projects/domains/${osDomain}/bin",
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
