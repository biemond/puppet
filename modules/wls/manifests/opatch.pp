# == Define: wls::opatch
#
# installs oracle patches for Oracle products
#
#
# === Examples
#
#    $jdkWls11gJDK = 'jdk1.7.0_09'
#
#  case $operatingsystem {
#     CentOS, RedHat, OracleLinux, Ubuntu, Debian: {
#       $oracleHome   = "/opt/oracle/wls/wls11g/Oracle_OSB1"
#       $user         = "oracle"
#       $group        = "dba"
#     }
#     windows: {
#       $oracleHome   = "c:/oracle/wls/wls11g/Oracle_OSB1"
#       $user         = "Administrator"
#       $group        = "Administrators"
#     }
#  }
#
#  wls::opatch{'14389126_osb_patch':
#    oracleProductHome => $oracleHome ,
#    fullJDKName       => $defaultFullJDK,
#    patchId           => '14389126',
#    patchFile         => 'p14389126_111160_Generic.zip',
#    user              => $user,
#    group             => $group,
#  }
##
define wls::opatch(  $oracleProductHome = undef,
                     $fullJDKName       = undef,
                     $patchId           = undef,
                     $patchFile         = undef,
                     $user              = 'oracle',
                     $group             = 'dba',
                     $downloadDir       = '/install',
                     $puppetDownloadMntPoint  = undef,
                    ) {

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $execPath         = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $path             = $downloadDir
        $JAVA_HOME        = "/usr/java/${fullJDKName}"


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

        $execPath         = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $path             = $downloadDir
        $JAVA_HOME        = "/usr/jdk/${fullJDKName}"


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
        $JAVA_HOME        = "c:\\oracle\\${fullJDKName}"
        $oracleHomeWin    = slash_replace($oracleProductHome)

        Exec { path      => $execPath,
        	     logoutput => true,
             }
        File { ensure  => present,
               mode    => 0555,
               backup  => false,
             }
     }
   }


     # check if the opatch already is installed
     $found = opatch_exists($oracleProductHome,$patchId)
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         $continue = false
       } else {
         notify {"wls::opatch ${title} ${oracleProductHome} does not exists":}
         $continue = true
       }
     }

if ( $continue ) {

   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/wls/"
   } else {
     $mountPoint =	$puppetDownloadMntPoint
   }


   # the patch used by the opatch
   if ! defined(File["${path}/${patchFile}"]) {
    file { "${path}/${patchFile}":
     source  => "${mountPoint}/${patchFile}",
    }
   }


   # opatch apply -silent -jdk %JDK_HOME% -jre %JDK_HOME%\jre  -oh C:\oracle\MiddlewarePS5\Oracle_OSB1 C:\temp\14389126
   $oPatchCommand  = "opatch apply -silent -jre"

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

        exec { "extract opatch ${patchFile} ${title}":
          command => "unzip -n ${path}/${patchFile} -d ${path}",
          require => File ["${path}/${patchFile}"],
          creates => "${path}/${patchId}",
        }

        exec { "exec opatch ux ${title}":
          command     => "${oracleProductHome}/OPatch/${oPatchCommand} ${JAVA_HOME}/jre -oh ${oracleProductHome} ${path}/${patchId}",
          require     => Exec["extract opatch ${patchFile} ${title}"],
        }

     }
     windows: {

        exec { "extract opatch ${patchFile} ${title}":
          command => "jar.exe xf ${path}/${patchFile}",
          creates => "${path}/${patchId}",
          cwd     => $path,
          require => File ["${path}/${patchFile}"],
        }
        #notify {"wls::opatch win exec ${title} ${checkCommand} ${oracleProductHome}/OPatch/${oPatchCommand} ${JAVA_HOME}\\jre -oh ${oracleHomeWin} ${path}/${patchId}":}
        exec { "exec opatch win ${title}":
          command     => "${checkCommand} ${oracleProductHome}/OPatch/${oPatchCommand} ${JAVA_HOME}\\jre -oh ${oracleHomeWin} ${path}/${patchId}",
          logoutput   => true,
          require     => Exec["extract opatch ${patchFile} ${title}"],
        }

     }
   }
}
}
