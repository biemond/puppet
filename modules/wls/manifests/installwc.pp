# == Define: wls::installwc
#
# installs Oracle Webcenter
#
# === Examples
#
#    $jdkWls11gJDK = 'jdk1.7.0_09'
#    $wls11gVersion = "1036"
#
#       $osMdwHome    = "/opt/wls/Middleware11gR1"
#       $osWlHome     = "/opt/wls/Middleware11gR1/wlserver_10.3"
#       $oracleHome   = "/opt/wls/"
#       $user         = "oracle"
#       $group        = "dba"
#
#
#  Wls::Installwc {
#    mdwHome      => $osMdwHome,
#    wlHome       => $osWlHome,
#    fullJDKName  => $jdkWls11gJDK,
#    user         => $user,
#    group        => $group,
#  }
#
#
#  wls::installwc{'wcPS6':
#    wcFile      => 'ofm_wc_generic_11.1.1.7.0_disk1_1of1.zip',
#  }
#
##


define wls::installwc( $mdwHome         = undef,
                       $wlHome          = undef,
                       $oracleHome      = undef,
                       $fullJDKName     = undef,
                       $wcFile          = undef,
                       $user            = 'oracle',
                       $group           = 'dba',
                       $downloadDir     = '/install',
                       $puppetDownloadMntPoint  = undef,
                    ) {

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $execPath        = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir
        $wcOracleHome    = "${mdwHome}/Oracle_WC1"
        $oraInventory    = "${oracleHome}/oraInventory"

        $wcInstallDir    = "linux64"
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
        $wcOracleHome    = "${mdwHome}/Oracle_WC1"
        $oraInventory    = "${oracleHome}/oraInventory"

        $wcInstallDir    = "intelsolaris"
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
        $wcOracleHome     = "${mdwHome}/Oracle_WC1"

        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0555,
               backup  => false,
             }
     }
   }

     # check if the wc already exists
     $found = oracle_exists( $wcOracleHome )
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         $continue = false
       } else {
         notify {"wls::installwc ${title} ${$wcOracleHome} does not exists":}
         $continue = true
       }
     }


if ( $continue ) {

   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/wls/"
   } else {
     $mountPoint =  $puppetDownloadMntPoint
   }

   wls::utils::orainst{'create wc oraInst':
            oraInventory    => $oraInventory,
            group           => $group,
   }

   $wcTemplate =  "wls/silent_wc.xml.erb"

#   if ! defined(File["${path}/${title}silent_wc.xml"]) {
     file { "${path}/${title}silent_wc.xml":
       ensure  => present,
       content => template($wcTemplate),
       require => Wls::Utils::Orainst ['create wc oraInst'],
     }
#   }

   # weblogic generic installer zip
   if ! defined(File["${path}/${wcFile}"]) {
    file { "${path}/${wcFile}":
     source  => "${mountPoint}/${wcFile}",
     require => File ["${path}/${title}silent_wc.xml"],
    }
   }


   $command  = "-silent -response ${path}/${title}silent_wc.xml -waitforcompletion "

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        if ! defined(Exec["extract ${wcFile}"]) {
         exec { "extract ${wcFile}":
          command => "unzip ${path}/${wcFile} -d ${path}/wc",
          require => [File ["${path}/${wcFile}"],File ["${path}/${title}silent_wc.xml"]],
          creates => "${path}/wc",
         }
        }

        exec { "install wc ${title}":
          command     => "${path}/wc/Disk1/install/${wcInstallDir}/runInstaller ${command} -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
          require     => [File ["${path}/${title}silent_wc.xml"],Exec["extract ${wcFile}"]],
          creates     => $wcOracleHome,
          timeout     => 0,
        }

     }
     Solaris: {

        if ! defined(Exec["extract ${wcFile}"]) {
         exec { "extract ${wcFile}":
          command => "unzip ${path}/${wcFile} -d ${path}/wc",
          require => [File ["${path}/${wcFile}"],File ["${path}/${title}silent_wc.xml"]],
          creates => "${path}/wc",
         }
        }

        exec { "add -d64 oraparam.ini wc":
          command => "sed -e's/JRE_MEMORY_OPTIONS=\" -Xverify:none\"/JRE_MEMORY_OPTIONS=\"-d64 -Xverify:none\"/g' ${path}/wc/Disk1/install/${wcInstallDir}/oraparam.ini > /tmp/wc.tmp && mv /tmp/wc.tmp ${path}/wc/Disk1/install/${wcInstallDir}/oraparam.ini",
          require => Exec["extract ${wcFile}"],
        }

        exec { "install wc ${title}":
          command     => "${path}/wc/Disk1/install/${wcInstallDir}/runInstaller ${command} -invPtrLoc /var/opt/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
          require     => [File ["${path}/${title}silent_wc.xml"],Exec["extract ${wcFile}"],Exec["add -d64 oraparam.ini wc"]],
          creates     => $wcOracleHome,
          timeout     => 0,
        }


     }

     windows: {

        if ! defined(Exec["extract ${wcFile}"]) {
         exec { "extract ${wcFile}":
          command => "${checkCommand} unzip ${path}/${wcFile} -d ${path}/wc",
          require => File ["${path}/${wcFile}"],
          creates => "${path}/wc/Disk1",
          cwd     => $path,
         }
        }

        exec {"icacls wc disk ${title}":
           command    => "${checkCommand} icacls ${path}\\wc\\* /T /C /grant Administrator:F Administrators:F",
           logoutput  => false,
           require    => Exec["extract ${wcFile}"],
        }

        exec { "install wc ${title}":
          command     => "${path}\\wc\\Disk1\\setup.exe ${command} -ignoreSysPrereqs -jreLoc C:\\oracle\\${fullJDKName}",
          logoutput   => true,
          require     => [Exec["icacls wc disk ${title}"],File ["${path}/${title}silent_wc.xml"],Exec["extract ${wcFile}"]],
          creates     => $wcOracleHome,
          timeout     => 0,
        }

     }
   }
}
}
