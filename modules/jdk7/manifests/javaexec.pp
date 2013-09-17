# jdk7::javaexec
#
# unpack the java tar.gz
# set the default java links
# set this java as default
#
define javaexec (
  $path                 = undef,
  $fullVersion          = undef,
  $jdkfile              = undef,
  $alternativesPriority = undef,
  $user                 = undef,
  $group                = undef,
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
  if ! defined(File["/usr/java"]) {
    file { "/usr/java" :
      ensure  => directory,
    }
  }

  # extract gz file in /usr/java
  exec { "extract java ${fullVersion}":
    cwd     => "/usr/java",
    command => "tar -xzf ${path}/${jdkfile}",
    creates => "/usr/java/${fullVersion}",
    require => File["/usr/java"],
  }

  # set permissions
  file { "/usr/java/${fullVersion}":
    ensure  => directory,
    recurse => true,
    require => Exec["extract java ${fullVersion}"],
  }

	# java link to latest
  file { '/usr/java/latest':
    ensure  => link,
    target  => "/usr/java/${fullVersion}",
    require => Exec["extract java ${fullVersion}"],
  }

	# java link to default
  file { '/usr/java/default':
    ensure  => link,
    target  => "/usr/java/latest",
    require => File['/usr/java/latest'],
  }

  case $osfamily {
    RedHat: {
			# set the java default
      exec { "default java alternatives ${fullVersion}":
        command => "alternatives --install /usr/bin/java java /usr/java/${fullVersion}/bin/java ${alternativesPriority}",
        require => File['/usr/java/default'],
        unless  => "alternatives --display java | /bin/grep ${fullVersion}",
      }
    }
    Debian, Suse:{
			# set the java default
      exec { "default java alternatives ${fullVersion}":
        command => "update-alternatives --install /usr/bin/java java /usr/java/${fullVersion}/bin/java ${alternativesPriority}",
        require => File['/usr/java/default'],
        unless  => "update-alternatives --list java | /bin/grep ${fullVersion}",
      }
    }
  }
}
