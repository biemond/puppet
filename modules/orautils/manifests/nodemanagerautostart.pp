# == Define: orautils::nodemanagerautostart
#
#  autostart of the nodemanager for linux
#
define orautils::nodemanagerautostart(
                        $version         = "1111",
                        $wlHome          = undef,
                        $user            = 'oracle',
                        $domain          = undef,
                        $logDir          = undef,
                        $jsseEnabled     = false,
                       ) {
   if ( $version == "1111" or $version == "1211" or $version == "1036" ) {
     $nodeMgrPath    = "${wlHome}/common/nodemanager"
     $nodeMgrBinPath = "${wlHome}/server/bin"

     $scriptName = "nodemanager_${$version}"

     if $logDir == undef {
        $nodeMgrLckFile = "${nodeMgrPath}/nodemanager.log.lck"
     } else {
        $nodeMgrLckFile = "${logDir}/nodemanager.log.lck"
     }
   } elsif $version == "1212" {
     $nodeMgrPath    = "${wlHome}/../user_projects/domains/${domain}/nodemanager"
     $nodeMgrBinPath = "${wlHome}/../user_projects/domains/${domain}/bin"
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

   case $operatingsystem {
     'CentOS', 'RedHat', 'OracleLinux', 'Ubuntu', 'Debian', 'SLES': {

        $execPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'

        Exec { path      => $execPath,
               logoutput => true,
             }

     }
     default: {
        fail("Unrecognized operating system")
     }
   }

   file { "/etc/init.d/${scriptName}" :
      ensure  => present,
      mode    => "0755",
      content => template("orautils/nodemanager.erb"),
   }

   exec { "chkconfig ${scriptName}":
      command => "chkconfig --add ${scriptName}",
      require => File["/etc/init.d/${scriptName}"],
      user    => 'root',
      unless  => "chkconfig | /bin/grep '${scriptName}'",
   }

}
