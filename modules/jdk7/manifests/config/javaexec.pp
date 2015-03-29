# jdk7::config::javaexec
#
# unpack the java tar.gz
# set the default java links
# set this java as default
#
define jdk7::config::javaexec (
  $download_dir                = undef,
  $full_version                = undef,
  $java_homes_dir              = undef,
  $jdk_file                    = undef,
  $cryptography_extension_file = undef,
  $alternatives_priority       = undef,
  $user                        = undef,
  $group                       = undef,
) {

  # check java install folder
  if ! defined(File['/usr/java']) {
    file { '/usr/java' :
      ensure  => directory,
      replace => false,
      owner   => $user,
      group   => $group,
      mode    => '0755',
    }
  }

  # check java install folder
  if ! defined(File[$java_homes_dir]) {
    file { $java_homes_dir :
      ensure  => directory,
      replace => false,
      owner   => $user,
      group   => $group,
      mode    => '0755',
    }
  }

  # extract gz file in /usr/java
  exec { "extract java ${full_version}":
    cwd       => $java_homes_dir,
    command   => "tar -xzf ${download_dir}/${jdk_file}",
    creates   => "${java_homes_dir}/${full_version}",
    require   => File[$java_homes_dir],
    path      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:',
    logoutput => true,
    user      => $user,
    group     => $group,
  }

  # extract gz file in /usr/java
  if ( $cryptography_extension_file != undef ) {
    exec { "extract jce ${full_version}":
      cwd       => "${java_homes_dir}/${full_version}/jre/lib/security",
      command   => "tar -xzf ${download_dir}/${cryptography_extension_file}",
      creates   => "${java_homes_dir}/${full_version}/jre/lib/security/US_export_policy.jar",
      require   => [File[$java_homes_dir],Exec["extract java ${full_version}"]],
      before    => Exec["chown -R root:root ${java_homes_dir}/${full_version}"],
      path      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:',
      logoutput => true,
      user      => $user,
      group     => $group,
    }
  }

  # set permissions
  exec { "chown -R root:root ${java_homes_dir}/${full_version}":
    unless    => "ls -al ${java_homes_dir}/${full_version}/bin/java | awk ' { print \$3 }' |  grep  root",
    path      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:',
    logoutput => true,
    user      => $user,
    group     => $group,
    require   => Exec["extract java ${full_version}"],
  }

  # java link to latest
  file { '/usr/java/latest':
    ensure  => link,
    target  => "${java_homes_dir}/${full_version}",
    require => Exec["extract java ${full_version}"],
    replace => false,
    owner   => $user,
    group   => $group,
    mode    => '0755',
  }

  # java link to default
  file { '/usr/java/default':
    ensure  => link,
    target  => '/usr/java/latest',
    require => File['/usr/java/latest'],
    replace => false,
    owner   => $user,
    group   => $group,
    mode    => '0755',
  }

  $alternatives = [ 'java', 'javac', 'keytool']

  jdk7::config::alternatives{ $alternatives:
    java_home_dir => $java_homes_dir,
    full_version  => $full_version,
    priority      => $alternatives_priority,
    user          => $user,
    group         => $group,
  }

}
