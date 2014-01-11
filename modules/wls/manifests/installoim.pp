# == Define: wls::installoim
#
# installs Oracle Identity Management addon
#
# === Examples
#
#    $jdkWls11gJDK = 'jdk1.7.0_40'
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
#  Wls::Installoim {
#    mdwHome      => $osMdwHome,
#    wlHome       => $osWlHome,
#    fullJDKName  => $jdkWls11gJDK,
#    user         => $user,
#    group        => $group,
#  }
#
#
#  wls::installoim{'oim11.2':
#    oimFile1      => 'V37472-01_1of2.zip',
#    oimFile2      => 'V37472-01_2of2.zip',
#  }
#
#

define wls::installoim($mdwHome                 = undef,
                       $wlHome                  = undef,
                       $oracleHome              = undef,
                       $fullJDKName             = undef,
                       $oimFile1                = undef,
                       $oimFile2                = undef,
                       $user                    = 'oracle',
                       $group                   = 'dba',
                       $downloadDir             = '/install',
                       $puppetDownloadMntPoint  = undef,
                       $remoteFile              = true,
                    ) {

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $execPath        = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir
        $oimOracleHome   = "${mdwHome}/Oracle_IDM1"
        $oraInventory    = "${oracleHome}/oraInventory"

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
        $oimOracleHome   = "${mdwHome}/Oracle_IDM1"
        $oraInventory    = "${oracleHome}/oraInventory"

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
     windows: {

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c"
        $path             = $downloadDir
        $oimOracleHome    = "${mdwHome}/Oracle_IDM1"

        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0777,
               backup  => false,
             }
     }
   }

     # check if the oim already exists
     $found = oracle_exists( $oimOracleHome )
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         $continue = false
       } else {
         notify {"wls::installoim ${title} ${oimOracleHome} does not exists":}
         $continue = true
       }
     }

if ( $continue ) {

   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/wls/"
   } else {
     $mountPoint =  $puppetDownloadMntPoint
   }

   wls::utils::orainst{'create oim oraInst':
            oraInventory    => $oraInventory,
            group           => $group,
   }

   $oimTemplate =  "wls/silent_oim.xml.erb"

   file { "${path}/${title}silent_oim.xml":
       ensure  => present,
       content => template($oimTemplate),
       require => Wls::Utils::Orainst ['create oim oraInst'],
   }

  if $remoteFile == true {
   # oim file 1 installer zip
    file { "${path}/${oimFile1}":
     source  => "${mountPoint}/${oimFile1}",
     require => File ["${path}/${title}silent_oim.xml"],
    }

   # oim file 2 installer zip
    file { "${path}/${oimFile2}":
     source  => "${mountPoint}/${oimFile2}",
     require => [File ["${path}/${title}silent_oim.xml"],File["${path}/${oimFile1}"]],
    }
  }

  $command  = "-silent -response ${path}/${title}silent_oim.xml -waitforcompletion "

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

      if $remoteFile == true {
         exec { "extract ${oimFile1}":
          command => "unzip -o ${path}/${oimFile1} -d ${path}/oim",
          creates => "${path}/oim/Disk1",
          require => [File ["${path}/${oimFile2}"],File ["${path}/${oimFile1}"]],
         }
         exec { "extract ${oimFile2}":
          command => "unzip -o ${path}/${oimFile2} -d ${path}/oim",
          creates => "${path}/oim/Disk3",
          require => [File ["${path}/${oimFile2}"],Exec["extract ${oimFile1}"]],
         }
      } else {
         exec { "extract ${oimFile1}":
          command => "unzip -o ${puppetDownloadMntPoint}/${oimFile1} -d ${path}/oim",
          creates => "${path}/oim/Disk1",
         }
         exec { "extract ${oimFile2}":
          command => "unzip -o ${puppetDownloadMntPoint}/${oimFile2} -d ${path}/oim",
          creates => "${path}/oim/Disk3",
          require => Exec["extract ${oimFile1}"],
         }
      }
      exec { "install oim ${title}":
          command     => "${path}/oim/Disk1/install/${oimInstallDir}/runInstaller ${command} -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
          require     => [File["${path}/${title}silent_oim.xml"],Exec["extract ${oimFile1}"],Exec["extract ${oimFile2}"]],
          creates     => $oimOracleHome,
          timeout     => 0,
      }
     }
     Solaris: {

      if $remoteFile == true {
         exec { "extract ${oimFile1}":
          command => "unzip ${path}/${oimFile1} -d ${path}/oim",
          creates => "${path}/oim/Disk1",
          require => [File ["${path}/${oimFile2}"],File ["${path}/${oimFile1}"]],
         }
         exec { "extract ${oimFile2}":
          command => "unzip ${path}/${oimFile2} -d ${path}/oim",
          creates => "${path}/oim/Disk3",
          require => [File ["${path}/${oimFile2}"],Exec["extract ${oimFile1}"]],
         }
      } else {
         exec { "extract ${oimFile1}":
          command => "unzip ${puppetDownloadMntPoint}/${oimFile1} -d ${path}/oim",
          creates => "${path}/oim/Disk1",
         }
         exec { "extract ${oimFile2}":
          command => "unzip ${puppetDownloadMntPoint}/${oimFile2} -d ${path}/oim",
          creates => "${path}/oim/Disk3",
          require => Exec["extract ${oimFile1}"],
         }
      }
     
      exec { "add -d64 oraparam.ini oim":
          command => "sed -e's/JRE_MEMORY_OPTIONS=\" -Xverify:none\"/JRE_MEMORY_OPTIONS=\"-d64 -Xverify:none\"/g' ${path}/oim/Disk1/install/${oimInstallDir}/oraparam.ini > /tmp/oim.tmp && mv /tmp/oim.tmp ${path}/oim/Disk1/install/${oimInstallDir}/oraparam.ini",
          require => [Exec["extract ${oimFile1}"],Exec["extract ${oimFile2}"]],
      }

      exec { "install oim ${title}":
          command     => "${path}/oim/Disk1/install/${oimInstallDir}/runInstaller ${command} -invPtrLoc /var/opt/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
          require     => [File["${path}/${title}silent_oim.xml"],Exec["extract ${oimFile1}"],Exec["extract ${oimFile2}"],Exec["add -d64 oraparam.ini oim"]],
          creates     => $oimOracleHome,
          timeout     => 0,
      }
     }

     windows: {

      if $remoteFile == true {
         exec { "extract ${oimFile1}":
          command => "${checkCommand} unzip ${path}/${oimFile1} -d ${path}/oim",
          require => [Registry_Value ["HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle\\inst_loc"],File ["${path}/${oimFile1}"]],
          creates => "${path}/oim/Disk1",
         }
         exec { "extract ${oimFile2}":
          command => "${checkCommand} unzip ${path}/${oimFile2} -d ${path}/oim",
          require => [Exec["extract ${oimFile1}"],File ["${path}/${oimFile2}"]],
          creates => "${path}/oim/Disk3",
         }
      } else {
         exec { "extract ${oimFile1}":
          command => "${checkCommand} unzip ${puppetDownloadMntPoint}/${oimFile1} -d ${path}/oim",
          require => [Registry_Value ["HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle\\inst_loc"]],
          creates => "${path}/oim/Disk1",
         }
         exec { "extract ${oimFile2}":
          command => "${checkCommand} unzip ${puppetDownloadMntPoint}/${oimFile2} -d ${path}/oim",
          require => [Exec["extract ${oimFile1}"]],
          creates => "${path}/oim/Disk3",
         }
      }

      exec {"icacls oim disk ${title}":
           command    => "${checkCommand} icacls ${path}\\oim\\* /T /C /grant Administrator:F Administrators:F",
           logoutput  => false,
           require    => [Exec["extract ${oimFile2}"],Exec["extract ${oimFile1}"]],
      }

      exec { "install oim ${title}":
          command     => "${path}\\oim\\Disk1\\setup.exe ${command} -ignoreSysPrereqs -jreLoc C:\\oracle\\${fullJDKName}",
          logoutput   => true,
          require     => [Exec["icacls oim disk ${title}"],File["${path}/${title}silent_oim.xml"],Exec["extract ${oimFile2}"],Exec["extract ${oimFile1}"]],
          creates     => $oimOracleHome,
          timeout     => 0,
      }

     }
   }
}
}
