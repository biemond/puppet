# == Define: orautils::nodemanagerautostart
#
#  autostart of the nodemanager for linux
#
define orautils::nodemanagerautostart(
  $version                 = '1111',
  $wlHome                  = undef,
  $user                    = 'oracle',
  $domain                  = undef,
  $domainPath              = undef,
  $logDir                  = undef,
  $jsseEnabled             = false,
  $customTrust             = false,
  $trustKeystoreFile       = undef,
  $trustKeystorePassphrase = undef,
){
  if ( $version in ['1111','1211','1036']) {
    $nodeMgrPath    = "${wlHome}/common/nodemanager"
    $nodeMgrBinPath = "${wlHome}/server/bin"

    $scriptName = "nodemanager_${$version}"

    if $logDir == undef {
      $nodeMgrLckFile = "${nodeMgrPath}/nodemanager.log.lck"
    } else {
      $nodeMgrLckFile = "${logDir}/nodemanager.log.lck"
    }
  } elsif ( $version in ['1212','1213']){
    $nodeMgrPath    = "${domainPath}/nodemanager"
    $nodeMgrBinPath = "${domainPath}/bin"
    $scriptName = "nodemanager_${domain}"

    if $logDir == undef {
      $nodeMgrLckFile = "${nodeMgrPath}/nodemanager_${domain}.log.lck"
    } else {
      $nodeMgrLckFile = "${logDir}/nodemanager_${domain}.log.lck"
    }
  } else {
    $nodeMgrPath    = "${wlHome}/common/nodemanager"
    $nodeMgrBinPath = "${wlHome}/server/bin"

    if $logDir == undef {
      $nodeMgrLckFile = "${nodeMgrPath}/nodemanager.log.lck"
    } else {
      $nodeMgrLckFile = "${logDir}/nodemanager.log.lck"
    }
  }

  case $::operatingsystem {
    'CentOS', 'RedHat', 'OracleLinux', 'Ubuntu', 'Debian', 'SLES': {
      $execPath = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'
    }
    default: {
      fail('Unrecognized operating system')
    }
  }

  if $customTrust == true {
    $trust_env = "-Dweblogic.security.TrustKeyStore=CustomTrust -Dweblogic.security.CustomTrustKeyStoreFileName=${trustKeystoreFile} -Dweblogic.security.CustomTrustKeystorePassPhrase=${trustKeystorePassphrase}"
  } else {
    $trust_env = ''
  }

  file { "/etc/init.d/${scriptName}" :
    ensure  => present,
    mode    => '0755',
    # content => template('orautils/nodemanager.erb'),
    content => regsubst(template('orautils/nodemanager.erb'), '\r\n', "\n", 'EMG'),
  }

  exec { "chkconfig ${scriptName}":
    command   => "chkconfig --add ${scriptName}",
    require   => File["/etc/init.d/${scriptName}"],
    user      => 'root',
    unless    => "chkconfig | /bin/grep '${scriptName}'",
    path      => $execPath,
    logoutput => true,
  }
}
