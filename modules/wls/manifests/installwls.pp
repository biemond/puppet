# == Define: wls::installwls
#
# Downloads from file folder and install weblogic with a silent install on linux and windows servers 
#
# === Examples
#
#
#    $jdkWls12cJDK = 'jdk1.7.0_09'
#    $wls12cVersion = "1211"
#  
#  case $operatingsystem {
#     centos, redhat, OracleLinux, ubuntu, debian: { 
#       $osWlHome     = "/opt/oracle/wls/wls12c/wlserver_12.1"
#       $user         = "oracle"
#       $group        = "dba"
#     }
#     windows: { 
#       $osWlHome     = "c:/oracle/wls/wls12c/wlserver_12.1"
#       $user         = "Administrator"
#       $group        = "Administrators"
#     }
#  }
#
#  # set the defaults
#  Wls::Installwls {
#    version      => $wls12cVersion,
#    versionJdk   => $jdkWls12cVersion,
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

define wls::installwls( $version    = undef, 
                        $versionJdk = undef,
                        $user       = 'oracle',
                        $group      = 'dba',
                      ) {

   notify {"wls::installwls ${version}":}

   $wls1211Parameter     = "1211"
   $wlsFile1211          = "wls1211_generic.jar" 
   $wlsVersion1211       = "wls12c" 

   $wls1036Parameter     = "1036"
   $wlsFile1036          = "wls1036_generic.jar" 
   $wlsVersion1036       = "wls11g" 

   $wlsFileDefault      = $wlsFile1211 
   $wlsVersionDefault   = $wlsVersion1211 


   $jdkVersion7u7    = "7u7" 
   $fullJDKName7u7   = "jdk1.7.0_07"

   $jdkVersion7u8    = "7u8" 
   $fullJDKName7u8   = "jdk1.7.0_08"

   $jdkVersion7u9    = "7u9" 
   $fullJDKName7u9   = "jdk1.7.0_09"

   $jdkVersion6u35   = "6u35" 
   $fullJDKName6u35  = "jdk1.6.0_35"


   $jdkVersionDefault   = $jdkVersion7u7 

   case $operatingsystem {
      centos, redhat, OracleLinux, ubuntu, debian: { 
        $path             = "/install/"

        $oracleHome       = "/opt/oracle/"
        $beaHome          = "${oracleHome}wls/"

     }
      windows: { 
        $path             = "C:/temp/"

        $oracleHome       = "C:\\oracle\\"
        $beaHome          = "${oracleHome}wls\\"
      }
      default: { 
        fail("Unrecognized operating system") 
      }
   }



    # check weblogic version like 12c

    if $version == undef {
      $wlsFile    =  $wlsFileDefault 
      $wlsVersion =  $wlsVersionDefault 
    }

    elsif $version == $wls12cParameter  {
      $wlsFile    =  $wlsFile1211 
      $wlsVersion =  $wlsVersion1211 
    } 

    elsif $version == $wls1036Parameter  {
      $wlsFile    =  $wlsFile1036 
      $wlsVersion =  $wlsVersion1036 
    } 

    else {
      $wlsFile    =  $wlsFileDefault 
      $wlsVersion =  $wlsVersionDefault 
    } 

    if $versionJdk == undef {
      $jdkVersion = $jdkVersionDefault
    } else {
      $jdkVersion = $versionJdk
    } 
     
    # is it a know jdk version like 7u7

    if $jdkVersion      == $jdkVersion7u7 {
       $fullJDKName  =  $fullJDKName7u7

    } elsif $jdkVersion == $jdkVersion7u8 {
       $fullJDKName  =  $fullJDKName7u8

    } elsif $jdkVersion == $jdkVersion7u9 {
       $fullJDKName  =  $fullJDKName7u9

    } elsif $jdkVersion == $jdkVersion6u35 {
       $fullJDKName  =  $fullJDKName6u35

    } else {
        fail("Unrecognized jdk version")        
    }

   # for linux , create a oracle user plus a dba group
   case $operatingsystem {
      centos, redhat, OracleLinux, ubuntu, debian: { 
        if ! defined(Group[$group]) {
          group { $group : 
                  ensure => present,
          }
        }
        if ! defined(User[$user]) {
          # http://raftaman.net/?p=1311 for generating password
          user { $user : 
              ensure     => present, 
              groups     => $group,
              shell      => '/bin/bash',
              password   => '$1$IX3YD7fb$JndzPUOGNCRYp/FG0GM1y/',  
              home       => '/home/oracle',
              comment    => 'This user was created by Puppet',
              require    => Group[$group],
              managehome => true, 
          }
        }
     }
   }

   # set the environment related vars		
   case $operatingsystem {
      centos, redhat, OracleLinux, ubuntu, debian: { 
        $mdwHome     = "${beaHome}${$wlsVersion}"
        $checkPath   = "/opt/oracle/wls/${$wlsVersion}"

     }
      windows: { 
        $mdwHome     = "${beaHome}${$wlsVersion}"
        $checkPath   = "c:\\oracle\\wls\\${$wlsVersion}"

      }
      default: { 
        fail("Unrecognized operating system") 
      }
   }


     # check if the wls already exists 
     $found = wls_exists($mdwHome)
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         notify {"wls::installwls ${title} ${mdwHome} already exists":}
         $continue = false
       } else {
         notify {"wls::installwls ${title} ${mdwHome} does not exists":}
         $continue = true 
       }
     }


if ( $continue ) {


   File{
        owner   => $user,
        group   => $group,
        mode    => 0770,
   }

   if ! defined(File[$path]) {
      # check oracle install folder
      file { $path :
        path    => $path,
        ensure  => directory,
        recurse => false, 
        replace => false,
      }
   }

   
   # put weblogic generic jar
   file { "wls.jar ${version}":
     path    => "${path}${wlsFile}",
     ensure  => file,
     source  => "puppet:///modules/wls/${wlsFile}",
     require => File[$path],
     replace => false,
     backup  => false,
   }

   if ! defined(File[$oracleHome]) {
     file { $oracleHome:
       path    => $oracleHome,
       ensure  => directory,
       recurse => false, 
       replace => false,
     }
   }

   if ! defined(File[$beaHome]) {
     file { $beaHome:
       path    => $beahome,
       ensure  => directory,
       recurse => false, 
       require => File[$oracleHome],
       replace => false,
     }
   }

   # de xml used by the wls installer
   file { "silent.xml ${version}":
     path    => "${path}silent${version}.xml",
     ensure  => present,
     replace => 'yes',
     content => template("wls/silent.xml.erb"),
     require => File[$path],
   }

   # install weblogic
   wls::wlsexec{ "installer ${version}":
      mdwHome     => $mdwHome,
      checkPath   => $checkPath,
      fullJDKName => $fullJDKName,
      wlsfile     => "${path}${wlsFile}",
      silentfile  => "${path}silent${version}.xml",
      user        => $user,
      group       => $group,
      require     => [File[$oracleHome],File[$beaHome],File["silent.xml ${version}"],File["wls.jar ${version}"]],
   }

}
}   