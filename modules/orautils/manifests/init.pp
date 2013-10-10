class orautils {

  include orautils::params

  case $operatingsystem {
    CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

    $user         = "oracle"
    $group        = "dba"
    $mode         = "0775"
	  $shell        = $orautils::params::shell

    if ! defined(File['/opt/scripts']) {
     file { '/opt/scripts':
       ensure  => directory,
       recurse => false,
       replace => false,
       owner   => $user,
       group   => $group,
       mode    => $mode,
      }
    }

    if ! defined(File['/opt/scripts/wls']) {
     file { '/opt/scripts/wls':
       ensure  => directory,
       recurse => false,
       replace => false,
       owner   => $user,
       group   => $group,
       mode    => $mode,
       require => File['/opt/scripts'],
      }
    }

    $osDomainType     = $orautils::params::osDomainType

    file { "showStatus.sh":
      path    => "/opt/scripts/wls/showStatus.sh",
      ensure  => present,
      content => template("orautils/wls/showStatus.sh.erb"),
      owner   => $user,
      group   => $group,
      mode    => $mode,
      require => File['/opt/scripts/wls'],
    }

    file { "stopNodeManager.sh":
      path    => "/opt/scripts/wls/stopNodeManager.sh",
      ensure  => present,
      content => template("orautils/wls/stopNodeManager.sh.erb"),
      owner   => $user,
      group   => $group,
      mode    => $mode,
      require => File['/opt/scripts/wls'],
    }

    $osOracleHome     = $orautils::params::osOracleHome
    $osDownloadFolder = $orautils::params::osDownloadFolder
    $osMdwHome        = $orautils::params::osMdwHome
    $osWlHome         = $orautils::params::osWlHome
	  $oraUser          = $orautils::params::oraUser
	  $userHome         = $orautils::params::userHome
	  $oraInstHome      = $orautils::params::oraInstHome
    $osLogFolder      = $orautils::params::osLogFolder
    $oraInventory     = $orautils::params::oraInventory

    file { "cleanOracleEnvironment.sh":
      path    => "/opt/scripts/wls/cleanOracleEnvironment.sh",
      ensure  => present,
      content => template("orautils/cleanOracleEnvironment.sh.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0770',
      require => File['/opt/scripts/wls'],
    }

    $nodeMgrPath    = $orautils::params::nodeMgrPath

    file { "startNodeManager.sh":
      path    => "/opt/scripts/wls/startNodeManager.sh",
      ensure  => present,
      content => template("orautils/startNodeManager.sh.erb"),
      owner   => $user,
      group   => $group,
      mode    => $mode,
      require => File['/opt/scripts/wls'],
    }

    $osDomain       = $orautils::params::osDomain
    $osDomainPath   = $orautils::params::osDomainPath
    $nodeMgrPort    = $orautils::params::nodeMgrPort
    $wlsUser        = $orautils::params::wlsUser
    $wlsPassword    = $orautils::params::wlsPassword
    $wlsAdminServer = $orautils::params::wlsAdminServer

    file { "startWeblogicAdmin.sh":
      path    => "/opt/scripts/wls/startWeblogicAdmin.sh",
      ensure  => present,
      content => template("orautils/startWeblogicAdmin.sh.erb"),
      owner   => $user,
      group   => $group,
      mode    => $mode,
      require => File['/opt/scripts/wls'],
    }

    file { "stopWeblogicAdmin.sh":
      path    => "/opt/scripts/wls/stopWeblogicAdmin.sh",
      ensure  => present,
      content => template("orautils/stopWeblogicAdmin.sh.erb"),
      owner   => $user,
      group   => $group,
      mode    => $mode,
      require => File['/opt/scripts/wls'],
    }

    }
    default: {
      notify{"Operating System not supported":}
    }
  }
}
