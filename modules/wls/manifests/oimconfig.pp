# == Define: wls::oimconfig
#
# does all the Oracle Identity Management configuration
#
define wls::oimconfig ($oimHome                 = undef,
                       $fullJDKName             = undef,
                       $serverConfig            = false,
                       $oimDatabaseUrl          = undef,
                       $oimSchemaPrefix         = undef,
                       $oimSchemaPassword       = undef,
                       $wlsUser                 = undef,
                       $password                = undef,
                       $oimPassword             = undef,
                       $remoteConfig            = false,
                       $keystorePassword        = undef,
                       $designConfig            = false,
                       $oimServerHostname       = undef,
                       $oimServerPort           = 14000,
                       $user                    = 'oracle',
                       $group                   = 'dba',
                       $downloadDir             = '/install',
                    ) {

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $execPath        = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir

        $oimInstallDir   = "linux64"
        $jreLocDir       = "/usr/java/${fullJDKName}"

        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
        File {
               ensure  => present,
               mode    => 0775,
               owner   => $user,
               group   => $group,
             }
     }
     Solaris: {

        $execPath        = "/usr/jdk/${fullJDKName}/bin/amd64:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir

        $oimInstallDir   = "intelsolaris"
        $jreLocDir       = "/usr/jdk/${fullJDKName}"

        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
        File {
               ensure  => present,
               mode    => 0775,
               owner   => $user,
               group   => $group,
             }
     }
   }
 
   if ( $serverConfig ) {

        file { "${path}/${title}config_oim_server.rsp":
          ensure  => present,
          content => template("wls/oim/oim_server.rsp.erb"),
        }
        exec { "config oim server ${title}":
          command     => "${oimHome}/bin/config.sh -silent -response ${path}/${title}config_oim_server.rsp",
          timeout     => 0,
          require => File["${path}/${title}config_oim_server.rsp"],
        }  

   }
   if ( $remoteConfig ) {

        file { "${path}/${title}config_oim_remote.rsp":
          ensure  => present,
          content => template("wls/oim/oim_remote.rsp.erb"),
        }
        exec { "config oim remote ${title}":
          command     => "${oimHome}/bin/config.sh -silent -response ${path}/${title}config_oim_remote.rsp",
          timeout     => 0,
          require => File["${path}/${title}config_oim_remote.rsp"],
        }  
 
   }
   if ( $designConfig ) {

        file { "${path}/${title}config_oim_design.rsp":
          ensure  => present,
          content => template("wls/oim/oim_design.rsp.erb"),
        }
        exec { "config oim design ${title}":
          command     => "${oimHome}/bin/config.sh -silent -response ${path}/${title}config_oim_design.rsp",
          timeout     => 0,
          require => File["${path}/${title}config_oim_design.rsp"],
        }  

   }
}  


