#
# java alternatives for rhel, debian
#
define jdk7::config::alternatives(
  $java_home_dir  = undef,
  $full_version   = undef,
  $priority       = undef,
  $user           = undef,
  $group          = undef,
)
{
  case $::osfamily {
    'RedHat': {
      $install_command = 'alternatives --install'
      $retrieve_command = 'alternatives --display'
    }
    'Debian', 'Suse':{
      $install_command = 'update-alternatives --install'
      $retrieve_command = 'update-alternatives --list'
    }
    default: {
      fail("Unrecognized osfamily ${::osfamily}, please use it on a Linux host")
    }
  }

  exec { "java alternatives ${title}":
    command   => "${install_command} /usr/bin/${title} ${title} ${java_home_dir}/${full_version}/bin/${title} ${priority}",
    unless    => "${retrieve_command} ${title} | /bin/grep ${full_version}",
    path      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
    logoutput => true,
    user      => $user,
    group     => $group,
  }
}
