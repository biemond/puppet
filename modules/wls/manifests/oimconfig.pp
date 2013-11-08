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
                       $wlHome                  = undef,
                       $mdwHome                 = undef,
                       $wlsDomain               = undef,
                       $adminServerName         = undef,
                       $soaServerName           = undef,
                       $oimServerName           = undef,
                       $adminServerAddress      = 'localhost',
                       $adminServerport         = 7001,
                       $nodemanagerPort         = 5556,
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
               backup  => false,
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
               backup  => false,
             }
     }
   }

   if ( $remoteConfig == true ) {
     file { "${path}/${title}config_oim_remote.rsp":
       ensure  => present,
       content => template("wls/oim/oim_remote.rsp.erb"),
     }

     exec { "config oim remote ${title}":
       command => "${oimHome}/bin/config.sh -silent -response ${path}/${title}config_oim_remote.rsp",
       timeout => 0,
       onlyif  => "${remoteConfig} == true",
       require => File["${path}/${title}config_oim_remote.rsp"],
     }
   }

   if ( $designConfig == true  ) {

     file { "${path}/${title}config_oim_design.rsp":
       ensure  => present,
       content => template("wls/oim/oim_design.rsp.erb"),
     }

     exec { "config oim design ${title}":
       command => "${oimHome}/bin/config.sh -silent -response ${path}/${title}config_oim_design.rsp",
       timeout => 0,
       require => File["${path}/${title}config_oim_design.rsp"],
     }
   }


   if ( $serverConfig ) {

     # if these params are empty always continue
     if $wlsDomain != undef  {
       # check if oim is already configured in this weblogic domain
       $oimValue = oim_configured( $wlsDomain , "1121" )
     } else {
       fail("wlsDomain parameter is empty ")
     }

	   if ( $oimValue == "false" ) {


	     file { "${path}/${title}config_oim_server.rsp":
	       ensure  => present,
	       content => template("wls/oim/oim_server.rsp.erb"),
	     }

	     exec { "config oim server ${title}":
	       command     => "${oimHome}/bin/config.sh -silent -response ${path}/${title}config_oim_server.rsp",
	       timeout     => 0,
	       require     => File["${path}/${title}config_oim_server.rsp"],
	       creates     => "${mdwHome}/user_projects/domains/${wlsDomain}/soa/autodeploy",
	     }

	     Wls::Wlscontrol{
	       wlsDomain     => $wlsDomain,
	       wlsDomainPath => "${mdwHome}/user_projects/domains/${wlsDomain}",
	       wlHome        => $wlHome,
	       fullJDKName   => $fullJDKName,
	       wlsUser       => $wlsUser,
	       password      => $password,
	       address       => $adminServerAddress,
	       user          => $user,
	       group         => $group,
	       downloadDir   => $downloadDir,
	       logOutput     => true,
	     }

	     # stop Oim server for configuration
	     wls::wlscontrol{'stopOIMOimServer1AfterConfig':
		     wlsServerType => 'managed',
		     wlsServer     => $oimServerName,
		     action        => 'stop',
	       port          => $adminServerport,
	       require       => Exec["config oim server ${title}"],
	     }
	     # stop Oim server for configuration
	     wls::wlscontrol{'stopOIMSoaServer1AfterConfig':
	       wlsServerType => 'managed',
	       wlsServer     => $soaServerName,
	       action        => 'stop',
	       port          => $adminServerport,
	       require       => [Wls::Wlscontrol['stopOIMOimServer1AfterConfig'],Exec["config oim server ${title}"]],
	     }
	     # stop AdminServer for configuration
	     wls::wlscontrol{'stopOIMAdminServerAfterConfig':
	       wlsServerType => 'admin',
	       wlsServer     => $adminServerName,
	       action        => 'stop',
	       port          => $nodemanagerPort,
	       require       => [Wls::Wlscontrol['stopOIMOimServer1AfterConfig'],Wls::Wlscontrol['stopOIMSoaServer1AfterConfig'],Exec["config oim server ${title}"]],
	     }
	     # start AdminServer for configuration
	     wls::wlscontrol{'startOIMAdminServerAfterConfig':
	       wlsServerType => 'admin',
	       wlsServer     => $adminServerName,
	       action        => 'start',
	       port          => $nodemanagerPort,
	       require       => [Wls::Wlscontrol['stopOIMOimServer1AfterConfig'],Wls::Wlscontrol['stopOIMAdminServerAfterConfig'],Wls::Wlscontrol['stopOIMSoaServer1AfterConfig'],Exec["config oim server ${title}"]],
	     }
	    }
  }
}


