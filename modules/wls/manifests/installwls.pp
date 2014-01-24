# == Define: wls::installwls
#
# Downloads from file folder and install weblogic with a silent install on linux and windows servers
#
# === Examples
#
#
#  $jdkWls12cJDK  = 'jdk1.7.0_25'
#  $wls12cVersion = "1212"
#
#  $user         = "oracle"
#  $group        = "dba"
#  $osOracleHome = "/opt/wls"
#  $osMdwHome    = "/opt/wls/Middleware11gR1"
#
#  # set the defaults
#  Wls::Installwls {
#    version      => $wls12cVersion,
#    fullJDKName  => $jdkWls12cJDK,
#    oracleHome   => $osOracleHome,
#    mdwHome      => $osMdwHome,
#    user         => $user,
#    group        => $group,
#  }
#
#
#  # install
#  wls::installwls{'wls12c':
#  }
#
#

define wls::installwls( $version                 = undef,
                        $fullJDKName             = undef,
                        $oracleHome              = undef,
                        $mdwHome                 = undef,
                        $createUser              = true,
                        $user                    = 'oracle',
                        $group                   = 'dba',
                        $downloadDir             = '/install',
                        $remoteFile              = true,
                        $javaParameters          = '', # '-Dspace.detection=false'
                        $puppetDownloadMntPoint  = undef,
                      ) {

   $wls1212Parameter     = "1212"
   $wlsFile1212          = "wls_121200.jar"

   $wls1211Parameter     = "1211"
   $wlsFile1211          = "wls1211_generic.jar"

   $wls1036Parameter     = "1036"
   $wlsFile1036          = "wls1036_generic.jar"


   $wlsFileDefault       = $wlsFile1036

   case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {
        $execPath        = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir
        $beaHome         = $mdwHome

        $oraInventory    = "${oracleHome}/oraInventory"
        $oraInstPath     = "/etc"
        $java_statement  = "java ${javaParameters}"

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
        $beaHome         = $mdwHome

        $oraInventory    = "${oracleHome}/oraInventory"
        $oraInstPath     = "/var/opt"
        $java_statement  = "java -d64 ${javaParameters}"

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
      windows: {
        $path            = $downloadDir
        $beaHome         = $mdwHome

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c"

        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0555,
               backup  => false,
             }
      }
      default: {
        fail("Unrecognized operating system")
      }
   }



    # check weblogic version like 12c
    if $version == undef {
      $wlsFile    =  $wlsFileDefault
    }
    elsif $version == $wls1211Parameter  {
      $wlsFile    =  $wlsFile1211
    }
    elsif $version == $wls1212Parameter  {
      $wlsFile    =  $wlsFile1212
    }
    elsif $version == $wls1036Parameter  {
      $wlsFile    =  $wlsFile1036
    }
    else {
      $wlsFile    =  $wlsFileDefault
    }

     # check if the wls already exists
     $found = wls_exists($mdwHome)
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         $continue = false
       } else {
         notify {"wls::installwls ${title} ${mdwHome} does not exists":}
         $continue = true
       }
     }

if ( $continue ) {

  if $puppetDownloadMntPoint == undef {
    $mountPoint =  "puppet:///modules/wls/"
  } else {
    $mountPoint = $puppetDownloadMntPoint
  }

  wls::utils::defaultusersfolders{'create wls home':
    oracleHome      => $oracleHome,
    oraInventory    => $oraInventory,
    createUser      => $createUser,
    user            => $user,
    group           => $group,
    downloadDir     => $path,
  }

  # for performance reasons, download and install or just install it
  if $remoteFile == true {
    file { "wls.jar ${version}":
       path    => "${path}/${wlsFile}",
       ensure  => file,
       source  => "${mountPoint}/${wlsFile}",
       require => Wls::Utils::Defaultusersfolders['create wls home'],
       replace => false,
       backup  => false,
    }
  }

  if $version == $wls1212Parameter  {

       wls::utils::orainst{'create wls oraInst':
            oraInventory    => $oraInventory,
            group           => $group,
       }

       # de xml used by the wls installer
       file { "silent.xml ${version}":
         path    => "${path}/silent${version}.xml",
         ensure  => present,
         replace => 'yes',
         content => template("wls/silent_${wls1212Parameter}.xml.erb"),
         require => [ Wls::Utils::Orainst ['create wls oraInst']],
       }

       $command  = "-silent -responseFile ${path}/silent${version}.xml "

       case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {
            if $remoteFile == true {
              exec { "install wls ${title}":
                command     => "${java_statement} -Xmx1024m -jar ${path}/${wlsFile} ${command} -invPtrLoc ${oraInstPath}/oraInst.loc -ignoreSysPrereqs",
                require     => [Wls::Utils::Defaultusersfolders['create wls home'],
                                File["silent.xml ${version}"],
                                File["wls.jar ${version}"],
                               ],
                timeout     => 0,
              }
            } else {
              exec { "install wls ${title}":
                command     => "${java_statement} -Xmx1024m -jar ${puppetDownloadMntPoint}/${wlsFile} ${command} -invPtrLoc ${oraInstPath}/oraInst.loc -ignoreSysPrereqs",
                require     => [Wls::Utils::Defaultusersfolders['create wls home'],
                                File ["silent.xml ${version}"],
                               ],
                timeout     => 0,
              }
            }
         }

         windows: {

            exec {"icacls wls disk ${title}":
              command    => "${checkCommand} icacls ${path}\\${wlsFile} /T /C /grant Administrator:F Administrators:F",
              timeout     => 0,
              logoutput  => false,
              require    => File["wls.jar ${version}"],
            }

            exec { "install wls ${title}":
              command     => "${checkCommand} java -jar ${path}/${wlsFile}  ${command} -ignoreSysPrereqs",
              logoutput   => true,
              require     => [Wls::Utils::Defaultusersfolders['create wls home'],
                              Exec["icacls wls disk ${title}"],
                              File ["silent.xml ${version}"]
                             ],
              timeout     => 0,
            }

         }
       }

    }
    else {

       # de xml used by the wls installer
       file { "silent.xml ${version}":
         path    => "${path}/silent${version}.xml",
         ensure  => present,
         replace => 'yes',
         content => template("wls/silent.xml.erb"),
         require => Wls::Utils::Defaultusersfolders['create wls home'],
       }

       # install weblogic
       case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {
            if $remoteFile == true {
              exec { "install wls ${title}":
                command     => "${java_statement} -Xmx1024m -jar ${path}/${wlsFile} -mode=silent -silent_xml=${path}/silent${version}.xml",
                logoutput   => true,
                timeout     => 0,
                require     => [Wls::Utils::Defaultusersfolders['create wls home'],
                                File ["wls.jar ${version}"],
                                File ["silent.xml ${version}"],
                               ],
              }
            } else {
              exec { "install wls ${title}":
                command     => "${java_statement} -Xmx1024m -jar ${puppetDownloadMntPoint}/${wlsFile} -mode=silent -silent_xml=${path}/silent${version}.xml",
                logoutput   => true,
                timeout     => 0,
                require     => [Wls::Utils::Defaultusersfolders['create wls home'],
                                File ["silent.xml ${version}"],
                               ],
              }
            }

         }
         windows: {
            exec { "install wls ${title}":
              command     => "${checkCommand} /c java -Xmx1024m -jar ${path}/${wlsFile} -mode=silent -silent_xml=${path}/silent${version}.xml",
              timeout     => 0,
              environment => ["JAVA_VENDOR=Sun",
                              "JAVA_HOME=C:\\oracle\\${fullJDKName}"],
              require     => [Wls::Utils::Defaultusersfolders['create wls home'],File ["wls.jar ${version}"],File ["silent.xml ${version}"]],
            }
         }
       }

    }

 }
}
