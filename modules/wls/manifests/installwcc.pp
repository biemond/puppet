# == Define: wls::installwcc
#
# installs Oracle Webcenter content addon
#
# === Examples
#
#    $jdkWls11gJDK = 'jdk1.7.0_09'
#    $wls11gVersion = "1036"
#
#  case $operatingsystem {
#     CentOS, RedHat, OracleLinux, Ubuntu, Debian: {
#       $osMdwHome    = "/opt/wls/Middleware11gR1"
#       $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
#       $oracleHome   = "/opt/wls/"
#       $user         = "oracle"
#       $group        = "dba"
#     }
#     windows: {
#       $osMdwHome    = "c:/oracle/wls11g"
#       $osWlHome     = "c:/oracle/wls11g/wlserver_10.3"
#       $user         = "Administrator"
#       $group        = "Administrators"
#     }
#  }
#
#
#  Wls::Installwcc {
#    mdwHome      => $osMdwHome,
#    wlHome       => $osWlHome,
#    fullJDKName  => $jdkWls11gJDK,
#    user         => $user,
#    group        => $group,
#  }
#
#
#  wls::installwcc{'wccPS6':
#    wccFile1      => 'ofm_wcc_generic_11.1.1.7.0_disk1_1of2.zip',
#    wccFile2      => 'ofm_wcc_generic_11.1.1.6.0_disk1_2of2.zip',
#  }
#
##
define wls::installwcc($mdwHome         = undef,
                       $wlHome          = undef,
                       $oracleHome      = undef,
                       $fullJDKName     = undef,
                       $wccFile1        = undef,
                       $wccFile2        = undef,
                       $user            = 'oracle',
                       $group           = 'dba',
                       $downloadDir     = '/install',
                       $remoteFile      = true,
                       $puppetDownloadMntPoint  = undef,
                    ) {

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $execPath        = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir
        $wccOracleHome   = "${mdwHome}/Oracle_WCC1"
        $oraInventory    = "${oracleHome}/oraInventory"

        $wccInstallDir   = "linux64"
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
        $wccOracleHome   = "${mdwHome}/Oracle_WCC1"
        $oraInventory    = "${oracleHome}/oraInventory"

        $wccInstallDir   = "intelsolaris"
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
     windows: {

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c"
        $path             = $downloadDir
        $wccOracleHome    = "${mdwHome}/Oracle_WCC1"

        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0777,
               backup  => false,
             }
     }
   }

     # check if the wcc already exists
     $found = oracle_exists( $wccOracleHome )
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         $continue = false
       } else {
         notify {"wls::installwcc ${title} ${wccOracleHome} does not exists":}
         $continue = true
       }
     }

if ( $continue ) {

   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/wls/"
   } else {
     $mountPoint =  $puppetDownloadMntPoint
   }

   wls::utils::orainst{'create wcc oraInst':
            oraInventory    => $oraInventory,
            group           => $group,
   }

   $wccTemplate =  "wls/silent_wcc.xml.erb"

#   if ! defined(File["${path}/${title}silent_wcc.xml"]) {
     file { "${path}/${title}silent_wcc.xml":
       ensure  => present,
       content => template($wccTemplate),
       require => Wls::Utils::Orainst ['create wcc oraInst'],
     }
#   }

   # wcc file 1 installer zip
  if $remoteFile == true {
    file { "${path}/${wccFile1}":
     source  => "${mountPoint}/${wccFile1}",
     require => File ["${path}/${title}silent_wcc.xml"],
    }
    file { "${path}/${wccFile2}":
     source  => "${mountPoint}/${wccFile2}",
     require => [File ["${path}/${title}silent_wcc.xml"],File["${path}/${wccFile1}"]],
    }
   }

   $command  = "-silent -response ${path}/${title}silent_wcc.xml -waitforcompletion "

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

      if $remoteFile == true {
         exec { "extract ${wccFile1}":
          command => "unzip -o ${path}/${wccFile1} -d ${path}/wcc",
          creates => "${path}/wcc/Disk1",
          require => [File ["${path}/${wccFile2}"],File ["${path}/${wccFile1}"]],
         }
         exec { "extract ${wccFile2}":
          command => "unzip -o ${path}/${wccFile2} -d ${path}/wcc",
          creates => "${path}/wcc/Disk2",
          require => [File ["${path}/${wccFile2}"],Exec["extract ${wccFile1}"]],
         }
      } else {
         exec { "extract ${wccFile1}":
          command => "unzip -o ${mountPoint}/${wccFile1} -d ${path}/wcc",
          creates => "${path}/wcc/Disk1",
         }
         exec { "extract ${wccFile2}":
          command => "unzip -o ${mountPoint}/${wccFile2} -d ${path}/wcc",
          creates => "${path}/wcc/Disk2",
          require => Exec["extract ${wccFile1}"],
         }

      }

        exec { "install wcc ${title}":
          command     => "${path}/wcc/Disk1/install/${wccInstallDir}/runInstaller ${command} -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
          require     => [File["${path}/${title}silent_wcc.xml"],Exec["extract ${wccFile1}"],Exec["extract ${wccFile2}"]],
          creates     => $wccOracleHome,
          timeout     => 0,
        }

     }
     Solaris: {

      if $remoteFile == true {
         exec { "extract ${wccFile1}":
          command => "unzip ${path}/${wccFile1} -d ${path}/wcc",
          creates => "${path}/wcc/Disk1",
          require => [File ["${path}/${wccFile2}"],File ["${path}/${wccFile1}"]],
         }
         exec { "extract ${wccFile2}":
          command => "unzip -o ${path}/${wccFile2} -d ${path}/wcc",
          creates => "${path}/wcc/Disk2",
          require => [File ["${path}/${wccFile2}"],Exec["extract ${wccFile1}"]],
         }
      } else {
         exec { "extract ${wccFile1}":
          command => "unzip ${mountPoint}/${wccFile1} -d ${path}/wcc",
          creates => "${path}/wcc/Disk1",
         }
         exec { "extract ${wccFile2}":
          command => "unzip -o ${mountPoint}/${wccFile2} -d ${path}/wcc",
          creates => "${path}/wcc/Disk2",
          require => Exec["extract ${wccFile1}"],
         }

      }

        exec { "add -d64 oraparam.ini wcc":
          command => "sed -e's/JRE_MEMORY_OPTIONS=\" -Xverify:none\"/JRE_MEMORY_OPTIONS=\"-d64 -Xverify:none\"/g' ${path}/wcc/Disk1/install/${wccInstallDir}/oraparam.ini > /tmp/wcc.tmp && mv /tmp/wcc.tmp ${path}/wcc/Disk1/install/${wccInstallDir}/oraparam.ini",
          require => [Exec["extract ${wccFile1}"],Exec["extract ${wccFile2}"]],
        }

        exec { "install wcc ${title}":
          command     => "${path}/wcc/Disk1/install/${wccInstallDir}/runInstaller ${command} -invPtrLoc /var/opt/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
          require     => [File["${path}/${title}silent_wcc.xml"],Exec["extract ${wccFile1}"],Exec["extract ${wccFile2}"],Exec["add -d64 oraparam.ini wcc"]],
          creates     => $wccOracleHome,
          timeout     => 0,
        }

     }

     windows: {

      if $remoteFile == true {
         exec { "extract ${wccFile1}":
          command => "${checkCommand} unzip ${path}/${wccFile1} -d ${path}/wcc",
          require => [Registry_Value ["HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle\\inst_loc"],File ["${path}/${wccFile1}"]],
          creates => "${path}/wcc/Disk1",
         }
         exec { "extract ${wccFile2}":
          command => "${checkCommand} unzip -o ${path}/${wccFile2} -d ${path}/wcc",
          require => [Exec["extract ${wccFile1}"],File ["${path}/${wccFile2}"]],
          creates => "${path}/wcc/Disk2",
         }
      } else {
         exec { "extract ${wccFile1}":
          command => "${checkCommand} unzip ${mountPoint}/${wccFile1} -d ${path}/wcc",
          require => Registry_Value ["HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle\\inst_loc"],
          creates => "${path}/wcc/Disk1",
         }
         exec { "extract ${wccFile2}":
          command => "${checkCommand} unzip -o ${mountPoint}/${wccFile2} -d ${path}/wcc",
          require => Exec["extract ${wccFile1}"],
          creates => "${path}/wcc/Disk2",
         }
       }


        exec {"icacls wcc disk ${title}":
           command    => "${checkCommand} icacls ${path}\\wcc\\* /T /C /grant Administrator:F Administrators:F",
           logoutput  => false,
           require    => [Exec["extract ${wccFile2}"],Exec["extract ${wccFile1}"]],
        }

        exec { "install wcc ${title}":
          command     => "${path}\\wcc\\Disk1\\setup.exe ${command} -ignoreSysPrereqs -jreLoc C:\\oracle\\${fullJDKName}",
          logoutput   => true,
          require     => [Exec["icacls wcc disk ${title}"],File["${path}/${title}silent_wcc.xml"],Exec["extract ${wccFile2}"],Exec["extract ${wccFile1}"]],
          creates     => $wccOracleHome,
          timeout     => 0,
        }

     }
   }
}
}
