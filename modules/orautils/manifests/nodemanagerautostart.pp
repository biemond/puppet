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

  if $customTrust == true {
    $trust_env = "-Dweblogic.security.TrustKeyStore=CustomTrust -Dweblogic.security.CustomTrustKeyStoreFileName=${trustKeystoreFile} -Dweblogic.security.CustomTrustKeystorePassPhrase=${trustKeystorePassphrase}"
  } else {
    $trust_env = ''
  }

  if ($::operatingsystem in ['CentOS','RedHat','OracleLinux'] and $::operatingsystemmajrelease == '7') {
    $location = "/home/${user}/${scriptName}"
  } else {
    $location = "/etc/init.d/${scriptName}"
  }

  file { $location :
    ensure  => present,
    mode    => '0755',
    content => regsubst(template('orautils/nodemanager.erb'), '\r\n', "\n", 'EMG'),
  }

  $execPath = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'

  case $::operatingsystem {
    'CentOS', 'RedHat', 'OracleLinux': {
      if ( $::operatingsystemmajrelease == '7') {
        file { "/lib/systemd/system/${scriptName}.service" :
          ensure  => present,
          mode    => '0755',
          content => regsubst(template('orautils/systemd.erb'), '\r\n', "\n", 'EMG'),
          require => File[$location],
        }
        exec { "systemctl daemon-reload ${title}":
          command     => 'systemctl daemon-reload',
          subscribe   => File["/lib/systemd/system/${scriptName}.service"],
          refreshonly => true,
          user        => 'root',
          path        => $execPath,
          logoutput   => true,
        }
        exec { "systemctl enable ${title}":
          command   => "systemctl enable ${scriptName}.service",
          require   => [Exec["systemctl daemon-reload ${title}"],
                        File["/lib/systemd/system/${scriptName}.service"],],
          user      => 'root',
          unless    => "systemctl list-units --type service --all | /bin/grep '${scriptName}.service'",
          path      => $execPath,
          logoutput => true,
        }
      }
      else {
        exec { "chkconfig ${scriptName}":
          command   => "chkconfig --add ${scriptName}",
          require   => File[$location],
          user      => 'root',
          unless    => "chkconfig | /bin/grep '${scriptName}'",
          path      => $execPath,
          logoutput => true,
        }
      }
    }
    'Ubuntu', 'Debian', 'SLES':{
      exec { "update-rc.d ${scriptName}":
        command   => "update-rc.d ${scriptName} defaults",
        require   => File[$location],
        user      => 'root',
        unless    => "ls /etc/rc3.d/*${scriptName} | /bin/grep '${scriptName}'",
        path      => $execPath,
        logoutput => true,
      }
    }
    default: {
      fail('Unrecognized operating system')
    }
  }
}
