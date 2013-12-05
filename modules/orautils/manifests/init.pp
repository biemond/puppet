class orautils(
  $osOracleHomeParam      = undef,
  $oraInventoryParam      = undef,
  $osDomainTypeParam      = undef,
  $osLogFolderParam       = undef,
  $osDownloadFolderParam  = undef,
  $osMdwHomeParam         = undef,
  $osWlHomeParam          = undef,
  $oraUserParam           = undef,
  $osDomainParam          = undef,
  $osDomainPathParam      = undef,
  $nodeMgrPathParam       = undef,
  $nodeMgrPortParam       = undef,
  $wlsUserParam           = undef,
  $wlsPasswordParam       = undef,
  $wlsAdminServerParam    = undef,
) {

  include orautils::params

  case $operatingsystem {
    CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

    # fixed

    if $oraUserParam != undef {
      $user           = $oraUserParam
    } else {
      $user           = "oracle"
    }
    $group            = "dba"
    $mode             = "0775"

    # ok
    $shell            = $orautils::params::shell
    $userHome         = $orautils::params::userHome
    $oraInstHome      = $orautils::params::oraInstHome


    if ( $osDomainTypeParam == undef ) {
      $osDomainType = $orautils::params::osDomainType
    } else {
      $osDomainType = $osDomainTypeParam
    }

    if ( $osOracleHomeParam == undef ) {
      $osOracleHome = $orautils::params::osOracleHome
    } else {
      $osOracleHome = $osOracleHomeParam
    }

    if ( $osDownloadFolderParam == undef ) {
      $osDownloadFolder = $orautils::params::osDownloadFolder
    } else {
      $osDownloadFolder = $osDownloadFolderParam
    }

    if ( $osMdwHomeParam == undef ) {
      $osMdwHome = $orautils::params::osMdwHome
    } else {
      $osMdwHome = $osMdwHomeParam
    }

    if ( $osWlHomeParam == undef ) {
      $osWlHome = $orautils::params::osWlHome
    } else {
      $osWlHome = $osWlHomeParam
    }

    if ( $oraUserParam == undef ) {
      $oraUser = $orautils::params::oraUser
    } else {
      $oraUser = $oraUserParam
    }

    if ( $osLogFolderParam == undef ) {
      $osLogFolder = $orautils::params::osLogFolder
    } else {
      $osLogFolder = $osLogFolderParam
    }

    if ( $oraInventoryParam == undef ) {
      $oraInventory  = $orautils::params::oraInventory
    } else {
      $oraInventory  = $oraInventoryParam
    }

    if ( $osDomainParam == undef ) {
      $osDomain         = $orautils::params::osDomain
    } else {
      $osDomain         = $osDomainParam
    }

    if ( $osDomainPathParam == undef ) {
      $osDomainPath     = $orautils::params::osDomainPath
    } else {
      $osDomainPath     = $osDomainPathParam
    }

    if ( $nodeMgrPortParam == undef ) {
      $nodeMgrPort      = $orautils::params::nodeMgrPort
    } else {
      $nodeMgrPort      = $nodeMgrPortParam
    }

    if ( $nodeMgrPathParam == undef ) {
      $nodeMgrPat  = $orautils::params::nodeMgrPath
    } else {
      $nodeMgrPath = $nodeMgrPathParam
    }

    if ( $wlsUserParam == undef ) {
      $wlsUser = $orautils::params::wlsUser
    } else {
      $wlsUser = $wlsUserParam
    }

    if ( $wlsPasswordParam == undef ) {
      $wlsPassword = $orautils::params::wlsPassword
    } else {
      $wlsPassword = $wlsPasswordParam
    }

    if ( $wlsAdminServerParam == undef ) {
      $wlsAdminServer = $orautils::params::wlsAdminServer
    } else {
      $wlsAdminServer = $wlsAdminServerParam
    }




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

    file { "cleanOracleEnvironment.sh":
      path    => "/opt/scripts/wls/cleanOracleEnvironment.sh",
      ensure  => present,
      content => template("orautils/cleanOracleEnvironment.sh.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0770',
      require => File['/opt/scripts/wls'],
    }


    file { "startNodeManager.sh":
      path    => "/opt/scripts/wls/startNodeManager.sh",
      ensure  => present,
      content => template("orautils/startNodeManager.sh.erb"),
      owner   => $user,
      group   => $group,
      mode    => $mode,
      require => File['/opt/scripts/wls'],
    }


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
