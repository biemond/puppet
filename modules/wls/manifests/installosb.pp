# == Define: wls::installosb
#
# installs Oracle Service Bus addon
#
# === Examples
#
#    $jdkWls11gJDK = 'jdk1.7.0_09'
#    $wls11gVersion = "1036"
#
#  case $operatingsystem {
#     CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: {
#       $osMdwHome    = "/opt/wls/Middleware11gR1"
#       $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
#       $oracleHome   = "/opt/wls/"
#       $user         = "oracle"
#       $group        = "dba"
#     }
#     windows: {
#       $osMdwHome    = "c:/oracle/wls/wls11g"
#       $osWlHome     = "c:/oracle/wls/wls11g/wlserver_10.3"
#       $user         = "Administrator"
#       $group        = "Administrators"
#     }
#  }
#
#
#  Wls::Installosb {
#    mdwHome      => $osMdwHome,
#    wlHome       => $osWlHome,
#    fullJDKName  => $jdkWls11gJDK,
#    user         => $user,
#    group        => $group,
#  }
#
#
#  wls::installosb{'osbPS5':
#    osbFile      => 'ofm_osb_generic_11.1.1.6.0_disk1_1of1.zip',
#  }
#
##


define wls::installosb($mdwHome         = undef,
                       $wlHome          = undef,
                       $oracleHome      = undef,
                       $fullJDKName     = undef,
                       $osbFile         = undef,
                       $oepeHome        = undef,
                       $user            = 'oracle',
                       $group           = 'dba',
                       $downloadDir     = '/install',
                       $puppetDownloadMntPoint  = undef,
                    ) {

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $execPath        = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir
        $osbOracleHome   = "${mdwHome}/Oracle_OSB1"
        $oraInventory    = "${oracleHome}/oraInventory"

        $osbInstallDir   = "linux64"
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
        $osbOracleHome   = "${mdwHome}/Oracle_OSB1"
        $oraInventory    = "${oracleHome}/oraInventory"

        $osbInstallDir   = "intelsolaris"
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
        $osbOracleHome    = "${mdwHome}/Oracle_OSB1"

        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0555,
               backup  => false,
             }
     }
   }

     # check if the osb already exists
     $found = oracle_exists( $osbOracleHome )
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         $continue = false
       } else {
         notify {"wls::installosb ${title} ${osbOracleHome} does not exists":}
         $continue = true
       }
     }


if ( $continue ) {

   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/wls/"
   } else {
     $mountPoint =	$puppetDownloadMntPoint
   }


   if $oepeHome == undef {
      $osbTemplate =  "wls/silent_osb.xml.erb"
   } else {
      $osbTemplate =  "wls/silent_osb_oepe.xml.erb"
   }


   wls::utils::orainst{'create osb oraInst':
            oraInventory    => $oraInventory,
            group           => $group,
   }

#   if ! defined(File["${path}/${title}silent_osb.xml"]) {
     file { "${path}/${title}silent_osb.xml":
       ensure  => present,
       content => template($osbTemplate),
       require => Wls::Utils::Orainst ['create osb oraInst'],
     }
#   }

   # weblogic generic installer zip
   if ! defined(File["${path}/${osbFile}"]) {
    file { "${path}/${osbFile}":
     source  => "${mountPoint}/${osbFile}",
     require => File ["${path}/${title}silent_osb.xml"],
    }
   }


   $command  = "-silent -response ${path}/${title}silent_osb.xml -waitforcompletion "

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        if ! defined(Exec["extract ${osbFile}"]) {
         exec { "extract ${osbFile}":
          command => "unzip ${path}/${osbFile} -d ${path}/osb",
          require => [File ["${path}/${osbFile}"],File ["${path}/${title}silent_osb.xml"]],
          creates => "${path}/osb",
         }
        }

        exec { "install osb ${title}":
          command     => "${path}/osb/Disk1/install/${osbInstallDir}/runInstaller ${command} -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
          require     => [File ["${path}/${title}silent_osb.xml"],Exec["extract ${osbFile}"]],
          creates     => $osbOracleHome,
          timeout     => 0,
        }
     }
     Solaris: {

        if ! defined(Exec["extract ${osbFile}"]) {
         exec { "extract ${osbFile}":
          command => "unzip ${path}/${osbFile} -d ${path}/osb",
          require => [File ["${path}/${osbFile}"],File ["${path}/${title}silent_osb.xml"]],
          creates => "${path}/osb",
         }
        }

        exec { "add -d64 oraparam.ini osb":
          command => "sed -e's/\\[Oracle\\]/\\[Oracle\\]\\nJRE_MEMORY_OPTIONS=\"-d64\"/g' ${path}/osb/Disk1/install/${osbInstallDir}/oraparam.ini > /tmp/osb.tmp && mv /tmp/osb.tmp ${path}/osb/Disk1/install/${osbInstallDir}/oraparam.ini",
        # command => "sed -e's/\[Oracle\]/\[Oracle\]\\\nJRE_MEMORY_OPTIONS=\"-d64\"/g'    ${path}/osb/Disk1/install/${osbInstallDir}/oraparam.ini > /tmp/osb.tmp && mv /tmp/osb.tmp ${path}/osb/Disk1/install/${osbInstallDir}/oraparam.ini",
          require => Exec["extract ${osbFile}"],
        }


        exec { "install osb ${title}":
          command     => "${path}/osb/Disk1/install/${osbInstallDir}/runInstaller ${command} -invPtrLoc /var/opt/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
          require     => [File ["${path}/${title}silent_osb.xml"],Exec["extract ${osbFile}"],Exec["add -d64 oraparam.ini osb"]],
          creates     => $osbOracleHome,
          timeout     => 0,
        }

        # fix opatch bug with d64 param on jdk x64
        exec { "chmod ${osbOracleHome}/OPatch/opatch first":
          command     => "chmod 775 ${osbOracleHome}/OPatch/opatch",
          require     => Exec ["install osb ${title}"],        }

        exec { "add quotes for d64 param in ${osbOracleHome}/OPatch/opatch":
          command     => "sed -e's/JRE_MEMORY_OPTIONS=\${MEM_ARGS} \${JVM_D64}/JRE_MEMORY_OPTIONS=\"\${MEM_ARGS} \${JVM_D64}\"/g' ${osbOracleHome}/OPatch/opatch > /tmp/osbpatch.tmp && mv /tmp/osbpatch.tmp ${osbOracleHome}/OPatch/opatch",
          require     => Exec ["chmod ${osbOracleHome}/OPatch/opatch first"],
        }

        exec { "chmod ${osbOracleHome}/OPatch/opatch after":
          command     => "chmod 775 ${osbOracleHome}/OPatch/opatch",
          require     => Exec ["add quotes for d64 param in ${osbOracleHome}/OPatch/opatch"],
        }
     }

     windows: {


        if ! defined(Exec["extract ${osbFile}"]) {
         exec { "extract ${osbFile}":
          command => "${checkCommand} unzip ${path}/${osbFile} -d ${path}/osb",
          require => File ["${path}/${osbFile}"],
          creates => "${path}/osb/Disk1",
          cwd     => $path,
         }
        }

        exec {"icacls osb disk ${title}":
           command    => "${checkCommand} icacls ${path}\\osb\\* /T /C /grant Administrator:F Administrators:F",
           logoutput  => false,
           require    => Exec["extract ${osbFile}"],
        }

        exec { "install osb ${title}":
          command     => "${path}\\osb\\Disk1\\setup.exe ${command} -ignoreSysPrereqs -jreLoc C:\\oracle\\${fullJDKName}",
          logoutput   => true,
          require     => [Exec["icacls osb disk ${title}"],File ["${path}/${title}silent_osb.xml"],Exec["extract ${osbFile}"]],
          creates     => $osbOracleHome,
          timeout     => 0,
        }
     }
   }
}
}
