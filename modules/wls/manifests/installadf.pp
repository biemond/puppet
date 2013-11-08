# == Define: wls::installadf
#
# installs Oracle ADF addon ( oracle_home )
# ADF 12.1.2 is a full install, 11g is a add-on, with 11g you need to install weblogic first
#
# === Examples
#
#    $jdkWls11gJDK = 'jdk1.7.0_25'
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
#  Wls::Installadf {
#    mdwHome      => $osMdwHome,
#    wlHome       => $osWlHome,
#    fullJDKName  => $jdkWls11gJDK,
#    user         => $user,
#    group        => $group,
#  }
#
#
#  wls::installadf{'adfPS6':
#    adfFile      => 'fmw_infra_121200.jar',
#  }
#
##
define wls::installadf($mdwHome         = undef,
                       $wlHome          = undef,
                       $oracleHome      = undef,
                       $fullJDKName     = undef,
                       $adfFile         = undef,
                       $createUser      = true,
                       $user            = 'oracle',
                       $group           = 'dba',
                       $downloadDir     = '/install',
                       $puppetDownloadMntPoint  = undef,
                    ) {

   # 12.1.2 is a full install , 11g is a add-on
   if $adfFile == 'fmw_infra_121200.jar' {
      $commonOracleHome = $mdwHome
   } else {
      $commonOracleHome = "${mdwHome}/oracle_common"
   }

     # check if the adf already exists
     $found = oracle_exists( $commonOracleHome )
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         $continue = false
       } else {
         notify {"wls::installadf ${title} ${commonOracleHome} does not exists":}
         $continue = true
       }
     }


   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $execPath           = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path               = $downloadDir
        $oraInventory       = "${oracleHome}/oraInventory"

        $adfInstallDir   = "linux64"
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

        $execPath           = "/usr/jdk/${fullJDKName}/bin/amd64:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path               = $downloadDir
        $oraInventory       = "${oracleHome}/oraInventory"

        $adfInstallDir   = "intelsolaris"
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
        $oraInventory     = "C:\\Program Files\\Oracle\\Inventory"

        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0555,
               backup  => false,
             }
     }
   }

   # 12.1.2 is a full install , 11g is a add-on
   if $adfFile == 'fmw_infra_121200.jar' {

      $version          = "1212"
      $adfTemplate      =  "wls/silent_1212_adf.xml.erb"

      if ( $continue ) {
          wls::utils::defaultusersfolders{'create adf home':
            oracleHome      => $commonOracleHome,
            oraInventory    => $oraInventory,
            createUser      => $createUser,
            user            => $user,
            group           => $group,
            downloadDir     => $path,
          }
      }
   } else {
      $version          = "1111"
      $adfTemplate      =  "wls/silent_adf.xml.erb"
   }


if ( $continue ) {

   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/wls/"
   } else {
     $mountPoint =	$puppetDownloadMntPoint
   }

   wls::utils::orainst{'create adf oraInst':
            oraInventory    => $oraInventory,
            group           => $group,
   }

   # adf generic installer zip
   if ! defined(File["${path}/${adfFile}"]) {
    file { "${path}/${adfFile}":
     source  => "${mountPoint}/${adfFile}",
     require => Wls::Utils::Orainst ['create adf oraInst'],
    }
   }


   $command  = "-silent -response ${path}/${title}silent_adf.xml -waitforcompletion "

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        if ($version != "1212" ) {
          if ! defined(Exec["extract ${adfFile}"]) {
           exec { "extract ${adfFile}":
             command => "unzip ${path}/${adfFile} -d ${path}/adf",
             require => File ["${path}/${adfFile}"],
             creates => "${path}/adf",
           }
          }
        }

        file { "${path}/${title}silent_adf.xml":
          ensure  => present,
          content => template($adfTemplate),
        }


        if ($version == "1212" ) {

          exec { "install adf ${title}":
            command     => "java -jar ${path}/${adfFile} ${command} -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs",
            require     => [Wls::Utils::Defaultusersfolders['create adf home'],File ["${path}/${title}silent_adf.xml"],File["${path}/${adfFile}"]],
            timeout     => 0,
          }

       } else {
			     file { "${path}/${title}silent_adf.xml":
			       ensure  => present,
			       content => template($adfTemplate),
			     }

          exec { "install adf ${title}":
            command     => "${path}/adf/Disk1/install/${adfInstallDir}/runInstaller ${command} -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
            require     => [File ["${path}/${title}silent_adf.xml"],Exec["extract ${adfFile}"]],
            creates     => $commonOracleHome,
          }

       }

     }
     Solaris: {

        if ($version != "1212" ) {
          if ! defined(Exec["extract ${adfFile}"]) {
           exec { "extract ${adfFile}":
             command => "unzip ${path}/${adfFile} -d ${path}/adf",
             require => File ["${path}/${adfFile}"],
             creates => "${path}/adf",
           }
          }
        }

        if ($version == "1212" ) {

          exec { "install adf ${title}":
            command     => "java -jar ${path}/${adfFile} ${command} -invPtrLoc /var/opt/oraInst.loc -ignoreSysPrereqs",
            require     => [Wls::Utils::Defaultusersfolders['create adf home'],File ["${path}/${title}silent_adf.xml"],File["${path}/${adfFile}"]],
            timeout     => 0,
          }

        } else {

		        exec { "add -d64 oraparam.ini osb":
              command => "sed -e's/\\[Oracle\\]/\\[Oracle\\]\\nJRE_MEMORY_OPTIONS=\"-d64\"/g' ${path}/adf/Disk1/install/${adfInstallDir}/oraparam.ini > /tmp/adf.tmp && mv /tmp/adf.tmp ${path}/adf/Disk1/install/${adfInstallDir}/oraparam.ini",
#		          command => "sed -e's/\[Oracle\]/\[Oracle\]\\\nJRE_MEMORY_OPTIONS=\"-d64\"/g' ${path}/adf/Disk1/install/${adfInstallDir}/oraparam.ini > /tmp/adf.tmp && mv /tmp/adf.tmp ${path}/adf/Disk1/install/${adfInstallDir}/oraparam.ini",
		          require => Exec["extract ${adfFile}"],
		        }


		        exec { "install adf ${title}":
		          command     => "${path}/adf/Disk1/install/${adfInstallDir}/runInstaller ${command} -invPtrLoc /var/opt/oraInst.loc -ignoreSysPrereqs -jreLoc ${jreLocDir}",
		          require     => [File ["${path}/${title}silent_adf.xml"],Exec["extract ${adfFile}"],Exec["add -d64 oraparam.ini osb"]],
		          creates     => $commonOracleHome,
		        }


		        # fix opatch bug with d64 param on jdk x64
		        exec { "chmod ${commonOracleHome}/OPatch/opatch first":
		          command     => "chmod 775 ${commonOracleHome}/OPatch/opatch",
		          require     => Exec ["install adf ${title}"],        }

		        exec { "add quotes for d64 param in ${commonOracleHome}/OPatch/opatch":
		          command     => "sed -e's/JRE_MEMORY_OPTIONS=\${MEM_ARGS} \${JVM_D64}/JRE_MEMORY_OPTIONS=\"\${MEM_ARGS} \${JVM_D64}\"/g' ${commonOracleHome}/OPatch/opatch > /tmp/osbpatch.tmp && mv /tmp/osbpatch.tmp ${commonOracleHome}/OPatch/opatch",
		          require     => Exec ["chmod ${commonOracleHome}/OPatch/opatch first"],
		        }

		        exec { "chmod ${commonOracleHome}/OPatch/opatch after":
		          command     => "chmod 775 ${commonOracleHome}/OPatch/opatch",
		          require     => Exec ["add quotes for d64 param in ${commonOracleHome}/OPatch/opatch"],
		        }

        }

     }

     windows: {

        if ($version == "1212" ) {
          exec {"icacls adf disk ${title}":
            command    => "${checkCommand} icacls ${path}\\${adfFile} /T /C /grant Administrator:F Administrators:F",
            logoutput  => false,
            require    => Exec["extract ${adfFile}"],
          }

          exec { "install adf ${title}":
            command     => "${checkCommand} java -jar ${path}/${adfFile} ${command} -ignoreSysPrereqs",
            require     => [Exec["icacls adf disk ${title}"],File ["${path}/${title}silent_adf.xml"],File["${path}/${adfFile}"]],
            timeout     => 0,
          }
        } else {

            if ! defined(Exec["extract ${adfFile}"]) {
              exec { "extract ${adfFile}":
                command => "${checkCommand} unzip ${path}/${adfFile} -d ${path}/adf",
                require => File ["${path}/${adfFile}"],
                creates => "${path}/adf/Disk1",
                cwd     => $path,
              }
            }
            exec {"icacls adf disk ${title}":
              command    => "${checkCommand} icacls ${path}\\adf\\* /T /C /grant Administrator:F Administrators:F",
              logoutput  => false,
              require    => Exec["extract ${adfFile}"],
            }
		        exec { "install adf ${title}":
		          command     => "${path}\\adf\\Disk1\\setup.exe ${command} -ignoreSysPrereqs -jreLoc C:\\oracle\\${fullJDKName}",
		          logoutput   => true,
		          require     => [Wls::Utils::Defaultusersfolders['create adf home'],Exec["icacls adf disk ${title}"],File ["${path}/${title}silent_adf.xml"],Exec["extract ${adfFile}"]],
		          creates     => $commonOracleHome,
		        }
        }
     }
   }
}
}
