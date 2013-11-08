# == Define: wls::installwebtier
#
# installs Oracle HTTP server and WebCache
#
#  wls::installwebtier{'webtierPS6':
#    version                => '1111',
#    mdwHome                => "/opt/oracle/Middleware11gR1",
#    wlHome                 => "/opt/oracle/Middleware11gR1/wlserver_10.3",
#    oracleHome             => "/opt/oracle",
#    fullJDKName            => 'jdk1.7.0_40',
#    user                   => "oracle",
#    group                  => "dba",
#    downloadDir            => "/data/install",
#    webtierFile            => 'ofm_webtier_linux_11.1.1.7.0_64_disk1_1of1.zip',
#    configureHTTP          => false,
#    associateWebtier       => false,
#    wlsAdminUrl            => "localhost",
#    wlsAdminPort           => 7001,
#    wlsUser                => "weblogic",
#    password               => "weblogic1",
#  }
#
#
##
define wls::installwebtier(
  $version                = '1111',
  $mdwHome                = undef,
  $wlHome                 = undef,
  $oracleHome             = undef,
  $fullJDKName            = undef,
  $webtierFile            = undef,
  $configureHTTP          = false,
  $associateWebtier       = false,
  $wlsAdminUrl            = "localhost",
  $wlsAdminPort           = 7001,
  $wlsUser                = "weblogic",
  $password               = undef,
  $user                   = 'oracle',
  $group                  = 'dba',
  $downloadDir            = '/install',
  $puppetDownloadMntPoint = undef,
) {

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $execPath            = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path                = $downloadDir
        $webtierOracleHome   = "${mdwHome}/Oracle_WT1"
        $oraInventory        = "${oracleHome}/oraInventory"

        $webtierInstallDir   = "linux64"
        $jreLocDir           = "/usr/java/${fullJDKName}"

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

        $execPath           = "/usr/jdk/${fullJDKName}/bin/amd64:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path               = $downloadDir
        $webtierOracleHome  = "${mdwHome}/Oracle_WT1"
        $oraInventory       = "${oracleHome}/oraInventory"

        $webtierInstallDir  = "intelsolaris"
        $jreLocDir          = "/usr/jdk/${fullJDKName}"

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

        $execPath          = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand      = "C:\\Windows\\System32\\cmd.exe /c"
        $path              = $downloadDir
        $webtierOracleHome = "${mdwHome}/Oracle_WT1"

        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0555,
               backup  => false,
             }
     }
   }

     # check if the webtier already exists
     $found = oracle_exists( $webtierOracleHome )
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         $continue = false
       } else {
         notify {"wls::installwebtier ${title} ${webtierOracleHome} does not exists":}
         $continue = true
       }
     }


if ( $continue ) {

   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/wls/"
   } else {
     $mountPoint =	$puppetDownloadMntPoint
   }

   wls::utils::orainst{'create webtier oraInst':
            oraInventory    => $oraInventory,
            group           => $group,
   }

   if ( $version == '1111') {
     $webtierTemplate = "wls/silent_webtier.xml.erb"
   } else {
     fail("Unrecognized webtier installation version")
   }

#   if ! defined(File["${path}/${title}silent_webtier.xml"]) {
     file { "${path}/${title}silent_webtier.xml":
       ensure  => present,
       content => template($webtierTemplate),
       require => Wls::Utils::Orainst ['create webtier oraInst'],
     }
#   }

   # weblogic generic installer zip
   if ! defined(File["${path}/${webtierFile}"]) {
    file { "${path}/${webtierFile}":
     source  => "${mountPoint}/${webtierFile}",
     require => File ["${path}/${title}silent_webtier.xml"],
    }
   }


   $command  = "-silent -response ${path}/${title}silent_webtier.xml -waitforcompletion "

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        if ! defined(Exec["extract ${webtierFile}"]) {
         exec { "extract ${webtierFile}":
          command => "unzip ${path}/${webtierFile} -d ${path}/webtier",
          require => [File ["${path}/${webtierFile}"],File ["${path}/${title}silent_webtier.xml"]],
          creates => "${path}/webtier",
         }
        }

        exec { "install webtier ${title}":
          command     => "${path}/webtier/Disk1/install/${webtierInstallDir}/runInstaller ${command} -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
          require     => [File ["${path}/${title}silent_webtier.xml"],Exec["extract ${webtierFile}"]],
          creates     => $webtierOracleHome,
          timeout     => 0,
        }
     }
     Solaris: {

        if ! defined(Exec["extract ${webtierFile}"]) {
         exec { "extract ${webtierFile}":
          command => "unzip ${path}/${webtierFile} -d ${path}/webtier",
          require => [File ["${path}/${webtierFile}"],File ["${path}/${title}silent_webtier.xml"]],
          creates => "${path}/webtier",
         }
        }

        exec { "add -d64 oraparam.ini webtier":
          command => "sed -e's/\\[Oracle\\]/\\[Oracle\\]\\nJRE_MEMORY_OPTIONS=\"-d64\"/g' ${path}/webtier/Disk1/install/${webtierInstallDir}/oraparam.ini > /tmp/webtier.tmp && mv /tmp/webtier.tmp ${path}/webtier/Disk1/install/${webtierInstallDir}/oraparam.ini",
        # command => "sed -e's/\[Oracle\]/\[Oracle\]\\\nJRE_MEMORY_OPTIONS=\"-d64\"/g'    ${path}/webtier/Disk1/install/${webtierInstallDir}/oraparam.ini > /tmp/webtier.tmp && mv /tmp/webtier.tmp ${path}/webtier/Disk1/install/${webtierInstallDir}/oraparam.ini",
          require => Exec["extract ${webtierFile}"],
        }

        exec { "install webtier ${title}":
          command     => "${path}/webtier/Disk1/install/${webtierInstallDir}/runInstaller ${command} -invPtrLoc /var/opt/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
          require     => [File ["${path}/${title}silent_webtier.xml"],Exec["extract ${webtierFile}"],Exec["add -d64 oraparam.ini webtier"]],
          creates     => $webtierOracleHome,
          timeout     => 0,
        }
     }

     windows: {


        if ! defined(Exec["extract ${webtierFile}"]) {
         exec { "extract ${webtierFile}":
          command => "${checkCommand} unzip ${path}/${webtierFile} -d ${path}/webtier",
          require => File ["${path}/${webtierFile}"],
          creates => "${path}/webtier/Disk1",
          cwd     => $path,
         }
        }

        exec {"icacls webtier disk ${title}":
           command    => "${checkCommand} icacls ${path}\\webtier\\* /T /C /grant Administrator:F Administrators:F",
           logoutput  => false,
           require    => Exec["extract ${webtierFile}"],
        }

        exec { "install webtier ${title}":
          command     => "${path}\\webtier\\Disk1\\setup.exe ${command} -ignoreSysPrereqs -jreLoc C:\\oracle\\${fullJDKName}",
          logoutput   => true,
          require     => [Exec["icacls webtier disk ${title}"],File ["${path}/${title}silent_webtier.xml"],Exec["extract ${webtierFile}"]],
          creates     => $webtierOracleHome,
          timeout     => 0,
        }
     }
   }
}
}
