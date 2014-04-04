# jdk7::javaexec
#
# unpack the java tar.gz
# set the default java links
# set this java as default
#
define jdk7::javaexec (
  $path                      = undef,
  $fullVersion               = undef,
  $javaHomes                 = undef,
  $jdkfile                   = undef,
  $cryptographyExtensionFile = undef,
  $alternativesPriority      = undef,
  $user                      = undef,
  $group                     = undef,
) {

  # set the Exec defaults
  Exec {
    path      => "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:",
    logoutput => true,
    user      => $user,
    group     => $group,
  }

  # set the defaults for File
  File {
    replace => false,
    owner   => $user,
    group   => $group,
    mode    => 0755,
  }

  # check java install folder
  if ! defined(File['/usr/java']) {
    file { '/usr/java' :
      ensure  => directory,
    }
  }

  # check java install folder
  if ! defined(File[$javaHomes]) {
    file { $javaHomes :
      ensure  => directory,
    }
  }

  # extract gz file in /usr/java
  exec { "extract java ${fullVersion}":
    cwd     => $javaHomes,
    command => "tar -xzf ${path}/${jdkfile}",
    creates => "${javaHomes}/${fullVersion}",
    require => File[$javaHomes],
  }

  # extract gz file in /usr/java
  if ( $cryptographyExtensionFile != undef ) {
    exec { "extract jce ${fullVersion}":
      cwd     => "${javaHomes}/${fullVersion}/jre/lib/security",
      command => "tar -xzf ${path}/${cryptographyExtensionFile}",
      creates => "${javaHomes}/${fullVersion}/jre/lib/security/US_export_policy.jar",
      require => [File[$javaHomes],Exec["extract java ${fullVersion}"]],
      before  => Exec["chown -R root:root ${javaHomes}/${fullVersion}"],  
    }
  }

  # set permissions
  exec { "chown -R root:root ${javaHomes}/${fullVersion}":
    unless  => "ls -al ${javaHomes}/${fullVersion}/bin/java | awk ' { print \$3 }' |  grep  root",
    require => Exec["extract java ${fullVersion}"],
  }

  # java link to latest
  file { '/usr/java/latest':
    ensure  => link,
    target  => "${javaHomes}/${fullVersion}",
    require => Exec["extract java ${fullVersion}"],
  }

  # java link to default
  file { '/usr/java/default':
    ensure  => link,
    target  => "/usr/java/latest",
    require => File['/usr/java/latest'],
  }

  case $osfamily {
    'RedHat': {
      # set the java default
      exec { "default java alternatives ${fullVersion}":
        command => "alternatives --install /usr/bin/java java ${javaHomes}/${fullVersion}/bin/java ${alternativesPriority}",
        require => File['/usr/java/default'],
        unless  => "alternatives --display java | /bin/grep ${fullVersion}",
      }
    }
    'Debian', 'Suse':{
      # set the java default
      exec { "default java alternatives ${fullVersion}":
        command => "update-alternatives --install /usr/bin/java java ${javaHomes}/${fullVersion}/bin/java ${alternativesPriority}",
        require => File['/usr/java/default'],
        unless  => "update-alternatives --list java | /bin/grep ${fullVersion}",
      }
    }
    default: {
      fail("Unrecognized osfamily ${::osfamily}, please use it on a Linux host")
    }
  }
}
