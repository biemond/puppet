# == Define: wls::installjdev
#
# Downloads from file folder and install jdeveloper with a silent install on linux and windows servers
#
#
#

define wls::installjdev( $version                 = "1111",
                         $jdevFile                = undef,
                         $fullJDKName             = undef,
                         $oracleHome              = undef,
                         $mdwHome                 = undef,
                         $soaAddon                = false,
                         $soaAddonFile            = undef,
                         $createUser              = true,
                         $user                    = 'oracle',
                         $group                   = 'dba',
                         $downloadDir             = '/install',
                         $puppetDownloadMntPoint  = undef,
                      ) {

   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/wls/"
   } else {
     $mountPoint =	$puppetDownloadMntPoint
   }

   case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {
        $path            = $downloadDir
        $wlHome          = "${mdwHome}/wlserver_10.3"
        $execPath        = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $javaHome        = "/usr/java/${fullJDKName}"

        $oraInventory    = "${oracleHome}/oraInventory"

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
     default: {
        fail("Unrecognized operating system")
     }
   }

   wls::utils::defaultusersfolders{'create jdev home':
            oracleHome      => $mdwHome,
            oraInventory    => $oraInventory,
            createUser      => $createUser,
            user            => $user,
            group           => $group,
            downloadDir     => $path,
   }


   # put jdeveloper full jar
   file { "${jdevFile}":
     path    => "${path}/${jdevFile}",
     ensure  => file,
     source  => "${mountPoint}/${jdevFile}",
     replace => false,
     backup  => false,
     require =>  [ Wls::Utils::Defaultusersfolders['create jdev home']],
   }

   if $version == "1111" {

	   # de xml used by the wls installer
	   file { "silent_jdeveloper.xml ${title}":
	     path    => "${path}/silent_jdeveloper_${title}.xml",
	     ensure  => present,
	     replace => 'yes',
	     content => template("wls/silent_jdeveloper.xml.erb"),
	     require => [ Wls::Utils::Defaultusersfolders['create jdev home']],
	   }

	   # install jdeveloper 11g
	   exec { "installjdev ${jdevFile}":
	          command     => "java -jar ${path}/${jdevFile} -mode=silent -silent_xml=${path}/silent_jdeveloper_${title}.xml -log=${path}/installJdev_${title}.log",
	          environment => ["JAVA_HOME=/usr/java/${fullJDKName}"],
	          require     => [File["${jdevFile}"],File["silent_jdeveloper.xml ${title}"]],
	          creates     => "${mdwHome}/jdeveloper",
	   }
   } elsif $version == "1212" {

       wls::utils::orainst{'create jdev oraInst':
            oraInventory    => $oraInventory,
            group           => $group,
       }

       # de xml used by the wls installer
       file { "silent_jdeveloper.xml ${title}":
         path    => "${path}/silent${version}.xml",
         ensure  => present,
         replace => 'yes',
         content => template("wls/silent_jdeveloper_1212.xml.erb"),
         require => [ Wls::Utils::Orainst ['create jdev oraInst']],
       }

       $command  = "-silent -responseFile ${path}/silent${version}.xml "

       exec { "installjdev ${jdevFile}":
          command     => "java -jar ${path}/${jdevFile} ${command} -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs",
          require     => [ Wls::Utils::Defaultusersfolders['create jdev home'], File["${jdevFile}"],File["silent_jdeveloper.xml ${title}"]],
          timeout     => 0,
         }

   }

   if ( $soaAddon == true ) {
     # de xml used by the wls installer
     file { "jdeveloper soa addon ${title}":
       path    => "${path}/${soaAddonFile}",
       ensure  => present,
       replace => 'no',
       source  => "${mountPoint}/${soaAddonFile}",
       require => [Exec["installjdev ${jdevFile}"]],
     }
     exec { "extract soa addon ${title}":
       command => "unzip -o ${path}/${soaAddonFile}",
       cwd     => "${mdwHome}/jdeveloper",
       require => [Exec["installjdev ${jdevFile}"],File["jdeveloper soa addon ${title}"]],
       creates => "${mdwHome}/jdeveloper/jdev/extensions/oracle.sca.modeler.jar",
     }

     exec { "chmod soa jdev bin ${title}":
       command => "chmod -R 775 ${mdwHome}/jdeveloper/bin",
       require => [Exec["extract soa addon ${title}"],Exec["installjdev ${jdevFile}"]],
     }
   }

}

