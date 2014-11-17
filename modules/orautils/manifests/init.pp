#
#
#
class orautils(
  $osOracleHomeParam       = $orautils::params::osOracleHome,
  $oraInventoryParam       = $orautils::params::oraInventory,
  $osDomainTypeParam       = $orautils::params::osDomainType,
  $osLogFolderParam        = $orautils::params::osLogFolder,
  $osDownloadFolderParam   = $orautils::params::osDownloadFolder,
  $osMdwHomeParam          = $orautils::params::osMdwHome,
  $osWlHomeParam           = $orautils::params::osWlHome,
  $oraUserParam            = $orautils::params::oraUser,
  $oraGroupParam           = $orautils::params::oraGroup,
  $osDomainParam           = $orautils::params::osDomain,
  $osDomainPathParam       = $orautils::params::osDomainPath,
  $nodeMgrPathParam        = $orautils::params::nodeMgrPath,
  $nodeMgrPortParam        = $orautils::params::nodeMgrPort,
  $nodeMgrAddressParam     = $orautils::params::nodeMgrAddress,
  $wlsUserParam            = $orautils::params::wlsUser,
  $wlsPasswordParam        = $orautils::params::wlsPassword,
  $wlsAdminServerParam     = $orautils::params::wlsAdminServer,
  $jsseEnabledParam        = $orautils::params::jsseEnabled,
  $customTrust             = false,
  $trustKeystoreFile       = undef,
  $trustKeystorePassphrase = undef,
) inherits orautils::params
{

  case $::kernel {
    'Linux', 'SunOS': {

    $mode             = '0775'

    $shell            = $orautils::params::shell
    $userHome         = $orautils::params::userHome
    $oraInstHome      = $orautils::params::oraInstHome

    if $customTrust == true {
      $trust_env = "-Dweblogic.security.TrustKeyStore=CustomTrust -Dweblogic.security.CustomTrustKeyStoreFileName=${trustKeystoreFile} -Dweblogic.security.CustomTrustKeystorePassPhrase=${trustKeystorePassphrase}"
    } else {
      $trust_env = ''
    }

    if ! defined(File['/opt/scripts']) {
      file { '/opt/scripts':
        ensure  => directory,
        recurse => false,
        replace => false,
        owner   => $oraUserParam,
        group   => $oraGroupParam,
        mode    => $mode,
      }
    }

    if ! defined(File['/opt/scripts/wls']) {
      file { '/opt/scripts/wls':
        ensure  => directory,
        recurse => false,
        replace => false,
        owner   => $oraUserParam,
        group   => $oraGroupParam,
        mode    => $mode,
        require => File['/opt/scripts'],
      }
    }

    file { 'showStatus.sh':
      ensure  => present,
      path    => '/opt/scripts/wls/showStatus.sh',
      content => regsubst(template('orautils/wls/showStatus.sh.erb'), '\r\n', "\n", 'EMG'),
      # content => template('orautils/wls/showStatus.sh.erb'),
      owner   => $oraUserParam,
      group   => $oraGroupParam,
      mode    => $mode,
      require => File['/opt/scripts/wls'],
    }

    file { 'stopNodeManager.sh':
      ensure  => present,
      path    => '/opt/scripts/wls/stopNodeManager.sh',
      content => regsubst(template('orautils/wls/stopNodeManager.sh.erb'), '\r\n', "\n", 'EMG'),
      # content => template('orautils/wls/stopNodeManager.sh.erb'),
      owner   => $oraUserParam,
      group   => $oraGroupParam,
      mode    => $mode,
      require => File['/opt/scripts/wls'],
    }

    file { 'cleanOracleEnvironment.sh':
      ensure  => present,
      path    => '/opt/scripts/wls/cleanOracleEnvironment.sh',
      content => regsubst(template('orautils/cleanOracleEnvironment.sh.erb'), '\r\n', "\n", 'EMG'),
      # content => template('orautils/cleanOracleEnvironment.sh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0770',
      require => File['/opt/scripts/wls'],
    }

    file { 'startNodeManager.sh':
      ensure  => present,
      path    => '/opt/scripts/wls/startNodeManager.sh',
      content => regsubst(template('orautils/startNodeManager.sh.erb'), '\r\n', "\n", 'EMG'),
      # content => template('orautils/startNodeManager.sh.erb'),
      owner   => $oraUserParam,
      group   => $oraGroupParam,
      mode    => $mode,
      require => File['/opt/scripts/wls'],
    }

    file { 'startWeblogicAdmin.sh':
      ensure  => present,
      path    => '/opt/scripts/wls/startWeblogicAdmin.sh',
      content => regsubst(template('orautils/startWeblogicAdmin.sh.erb'), '\r\n', "\n", 'EMG'),
      # content => template('orautils/startWeblogicAdmin.sh.erb'),
      owner   => $oraUserParam,
      group   => $oraGroupParam,
      mode    => $mode,
      require => File['/opt/scripts/wls'],
    }

    file { 'stopWeblogicAdmin.sh':
      ensure  => present,
      path    => '/opt/scripts/wls/stopWeblogicAdmin.sh',
      content => regsubst(template('orautils/stopWeblogicAdmin.sh.erb'), '\r\n', "\n", 'EMG'),
      # content => template('orautils/stopWeblogicAdmin.sh.erb'),
      owner   => $oraUserParam,
      group   => $oraGroupParam,
      mode    => $mode,
      require => File['/opt/scripts/wls'],
    }

    }
    default: {
      notify{'This operating system is not supported':}
    }
  }
}
