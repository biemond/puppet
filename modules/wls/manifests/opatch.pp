# == Define: wls::opatch
#
# installs oracle patches for Oracle products
#
define wls::opatch(  
  $ensure                  = 'present',  #present|absent
  $oracleProductHome       = undef,
  $fullJDKName             = undef,
  $patchId                 = undef,
  $patchFile               = undef,
  $user                    = 'oracle',
  $group                   = 'dba',
  $downloadDir             = '/install',
  $puppetDownloadMntPoint  = undef,
  $remoteFile              = true,
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


  if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/wls/"
  } else {
     $mountPoint =  $puppetDownloadMntPoint
  }

  if $ensure == "present" {
    # the patch used by the opatch
    if $remoteFile == true {
      file { "${path}/${patchFile}":
       source  => "${mountPoint}/${patchFile}",
      }
    }
  }

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

      if $ensure == "present" {
        if $remoteFile == true {
          exec { "extract opatch ${patchFile} ${title}":
            command => "unzip -n ${path}/${patchFile} -d ${path}",
            require => File ["${path}/${patchFile}"],
            creates => "${path}/${patchId}",
            before  => Opatch[$patchId],
          }
        } else {
          exec { "extract opatch ${patchFile} ${title}":
            command => "unzip -n ${puppetDownloadMntPoint}/${patchFile} -d ${path}",
            creates => "${path}/${patchId}",
            before  => Opatch[$patchId],
          }
        }
      }

      case $::kernel {
        'Linux': {
          $oraInstPath        = "/etc"
        }
        'SunOS': {
          $oraInstPath        = "/var/opt"
        }
        default: {
            fail("Unrecognized operating system ${::kernel}, please use it on a Linux host")
        }
      }

      opatch{ $patchId:
        ensure                  => $ensure,
        os_user                 => $user,
        oracle_product_home_dir => $oracleProductHome,
        orainst_dir             => $oraInstPath,
        jdk_home_dir            => $JAVA_HOME,
        extracted_patch_dir     => "${path}/${patchId}",
      }

     }
     windows: {

      # opatch apply -silent -jdk %JDK_HOME% -jre %JDK_HOME%\jre  -oh C:\oracle\MiddlewarePS5\Oracle_OSB1 C:\temp\14389126
      $oPatchCommand  = "opatch apply -silent -jre"

      if $remoteFile == true {
        exec { "extract opatch ${patchFile} ${title}":
          command => "jar.exe xf ${path}/${patchFile}",
          creates => "${path}/${patchId}",
          cwd     => $path,
          require => File ["${path}/${patchFile}"],
        }
      } else {
        exec { "extract opatch ${patchFile} ${title}":
          command => "jar.exe xf ${puppetDownloadMntPoint}/${patchFile}",
          creates => "${path}/${patchId}",
          cwd     => $path,
        }
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
