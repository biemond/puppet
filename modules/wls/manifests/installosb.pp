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
#     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 
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
                       $downloadDir     = '/install/',
                    ) {

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        $execPath        = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir
        $osbOracleHome   = "${mdwHome}/Oracle_OSB1"
        $oraInstPath     = "/etc/"
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
             }        
     }
     windows: { 

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 
        $path             = $downloadDir 
        $osbOracleHome    = "${mdwHome}/Oracle_OSB1"
        $oraInventory     = "C:\\Program Files\\Oracle\\Inventory"
        
        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0555,
             }   
     }
   }

     # check if the osb already exists
     $found = oracle_exists( $osbOracleHome )
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         notify {"wls::installosb ${title} ${osbOracleHome} already exists":}
         $continue = false
       } else {
         notify {"wls::installosb ${title} ${osbOracleHome} does not exists":}
         $continue = true 
       }
     }


if ( $continue ) {

   if $oepeHome == undef {
      $osbTemplate =  "wls/silent_osb.xml.erb"
   } else {
      $osbTemplate =  "wls/silent_osb_oepe.xml.erb"
   }

#   if ! defined(File["${path}${title}silent_osb.xml"]) {
     file { "${path}${title}silent_osb.xml":
       ensure  => present,
       content => template($osbTemplate),
     }
#   }

   # weblogic generic installer zip
   if ! defined(File["${path}${osbFile}"]) {
    file { "${path}${osbFile}":
     source  => "puppet:///modules/wls/${osbFile}",
     require => File ["${path}${title}silent_osb.xml"],
    }
   }

   
   $command  = "-silent -response ${path}${title}silent_osb.xml "
    
   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        if ! defined(Exec["extract ${osbFile}"]) {
         exec { "extract ${osbFile}":
          command => "unzip ${path}${osbFile} -d ${path}/osb",
          require => [File ["${path}${osbFile}"],File ["${path}${title}silent_osb.xml"]],
          creates => "${path}/osb",
         }
        }

        if ! defined(File["${oraInstPath}/oraInst.loc"]) {
         file { "${oraInstPath}/oraInst.loc":
           ensure  => present,
           content => template("wls/oraInst.loc.erb"),
#           require => [Exec["extract ${osbFile}"],File ["${path}${osbFile}"]],
         }
        }
        
        exec { "install osb ${title}":
          command     => "${path}osb/Disk1/install/linux64/runInstaller ${command} -invPtrLoc ${oraInstPath}/oraInst.loc -ignoreSysPrereqs -jreLoc /usr/java/${fullJDKName}",
          require     => [File ["${oraInstPath}/oraInst.loc"],File ["${path}${title}silent_osb.xml"],Exec["extract ${osbFile}"]],
          creates     => $osbOracleHome,
          environment => ["CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
        }    

        exec { "sleep 3 min for osb install ${title}":
          command     => "/bin/sleep 180",
          require     => Exec ["install osb ${title}"],
        }    

             
     }
     windows: { 

        if ! defined(Registry_Key["HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle"]) { 
          registry_key { "HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle":
            ensure  => present,
#            require => File ["${path}${osbFile}"],
          }
        }

        if ! defined(Registry_Value ["HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle\\inst_loc"]) {
          registry_value { "HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle\\inst_loc":
            type    => string,
            data    => $oraInventory,
            require => Registry_Key["HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle"],
          }
        }

        if ! defined(Exec["extract ${osbFile}"]) {
         exec { "extract ${osbFile}":
          command => "jar xf ${path}${osbFile}",
          require => File ["${path}${osbFile}"],
          creates => "${path}Disk1", 
          cwd     => $path,
         }
        }

        exec {"icacls osb disk ${title}": 
           command    => "${checkCommand} icacls ${path}* /T /C /grant Administrator:F Administrators:F",
           logoutput  => false,
           require    => Exec["extract ${osbFile}"],
        } 

        exec { "install osb ${title}":
          command     => "${path}Disk1\\setup.exe ${command} -ignoreSysPrereqs -jreLoc C:\\oracle\\${fullJDKName}",
          logoutput   => true,
          require     => [Exec["icacls osb disk ${title}"],File ["${path}${title}silent_osb.xml"],Exec["extract ${osbFile}"]],
          creates     => $osbOracleHome, 
        }    

        exec { "sleep 3 min for osb install ${title}":
          command     => "${checkCommand} sleep 180",
          require     => Exec ["install osb ${title}"],
        }    


     }
   }
}
}
