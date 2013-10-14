class orautils::params {

  $osOracleHome = $::hostname ? {
                                    devagent1    => "/opt/oracle/wls",
                                    devagent10   => "/opt/oracle/wls",
                                    devagent30   => "/opt/oracle/wls",
                                    devagent31   => "/opt/oracle",
                                    devagent40   => "/opt/oracle/wls",
                                    devagent41   => "/opt/oracle/wls",
                                    wls12        => "/oracle/product",
                                    soabeta2     => "/opt/oracle/wls",
                                    'vagrantoel64.example.com'    => "/oracle/product",
                                    'vagrantcentos64.example.com' => "/oracle/product",
                                    default      => "/opt/wls",
                                }

  $oraInventory = $::hostname ? {
                                    devagent1    => "/opt/oracle/oraInventory",
                                    devagent10   => "/opt/oracle/oraInventory",
                                    devagent30   => "/opt/oracle/oraInventory",
                                    devagent31   => "/opt/oracle/oraInventory",
                                    devagent40   => "/opt/oracle/oraInventory",
                                    devagent41   => "/opt/oracle/oraInventory",
                                    soabeta2     => "/home/oracle/soabetainv",
                                    wls12        => "/oracle/oraInventory",
                                    'vagrantoel64.example.com'    => "/oracle/oraInventory",
                                    'vagrantcentos64.example.com' => "/oracle/oraInventory",
                                    default      => "/opt/wls/oraInventory",
                                }



  $osDomainType = $::hostname ? {
                                    devagent30   => "soa",
                                    devagent31   => "admin",
                                    wls12        => "admin",
                                    devagent40   => "admin",
                                    devagent41   => "admin",
                                    soabeta2     => "soa",
                                    "vagrantoel64.example.com"    => "admin",
                                    "vagrantcentos64.example.com" => "admin",
                                    default      => "web",
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

  $osMdwHome     = $::hostname ?  { wls12                         => "${osOracleHome}/Middleware12c",
                                    "vagrantoel64.example.com"    => "${osOracleHome}/Middleware12c",
                                    "vagrantcentos64.example.com" => "${osOracleHome}/Middleware12c",
                                    devagent31   => "${osOracleHome}/Middleware12c",
                                    soabeta2     => "${osOracleHome}/Middleware12c",
                                    default      => "${osOracleHome}/Middleware11gR1",
                                  }

  $osWlHome     = $::hostname ?  { wls12                         => "${osOracleHome}/Middleware12c/wlserver",
                                   "vagrantoel64.example.com"    => "${osOracleHome}/Middleware12c/wlserver",
                                   "vagrantcentos64.example.com" => "${osOracleHome}/Middleware12c/wlserver",
                                   devagent31   => "${osOracleHome}/Middleware12c/wlserver",
                                   soabeta2     => "${osOracleHome}/Middleware12c/wlserver",
                                   default      => "${osOracleHome}/Middleware11gR1/wlserver_10.3",
                                 }

  $oraUser      = $::hostname ? { default => "oracle", }

  $userHome     = $::operatingsystem ? { Solaris => "/export/home",
  															         default => "/home",
  															       }
  $oraInstHome  = $::operatingsystem ? { Solaris => "/var/opt",
  															         default => "/etc",
  															       }

  $osDomain     = $::hostname ? {   wls12        => "Wls12c",
                                    "vagrantoel64.example.com"    => "Wls12c",
                                    "vagrantcentos64.example.com" => "Wls12c",
                                    soabeta2     => "soabeta2",
                                    devagent31   => "Wls12c",
                                    devagent40   => "WlsDomain",
                                    devagent41   => "WlsDomain",
                                    default      => "osbSoaDomain",
                                }

  $osDomainPath = $::hostname ? {
                                    default    => "${osMdwHome}/user_projects/domains/${osDomain}",
                                }

  $nodeMgrPath = $::hostname ? {
                                    wls12                         => "${osMdwHome}/user_projects/domains/${osDomain}/bin",
                                    "vagrantoel64.example.com"    => "${osMdwHome}/user_projects/domains/${osDomain}/bin",
                                    "vagrantcentos64.example.com" => "${osMdwHome}/user_projects/domains/${osDomain}/bin",
                                    devagent31   => "${osMdwHome}/user_projects/domains/${osDomain}/bin",
                                    soabeta2     => "${osMdwHome}/user_projects/domains/${osDomain}/bin",
                                    default      => "${osWlHome}/server/bin",
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
