# == Define: wls::installwls
#
# Downloads from file folder and install weblogic with a silent install on linux and windows servers 
#
# === Parameters
#
# [*version*]
#   the weblogic version to be installed 1211 or 1036
#
# [*versionJdk*]
#   jdk version 6u35 or 7u7 this maps to /usr/java/.. or c:\program files\
#
# [*user*]
#   the user which owns the software on unix = oracle on windows = administrator
#
# [*group*]
#   the group which owns the software on unix = dba on windows = administrators
#
# === Variables
#
# [*path*]
#   path for downloading softwate on unix = /install on windows = c:\temp
#
# [*oracleHome*]
#   oracle home path on unix /opt/oracle on windows = c:\oracle
#
# [*beaHome*]
#   middleware home  = oracle + wls
#
# === Examples
#
#   wls::installwls{'11gPS5':
#    version    => '1036',
#    versionJdk => '6u35',
#    user       => $user,
#    group      => $group,    
#  }
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
        $path             = "C:\\temp\\"

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
        $mdwHome   = "${beaHome}${$wlsVersion}/"
     }
      windows: { 
        $mdwHome   = "${beaHome}${$wlsVersion}\\"
      }
      default: { 
        fail("Unrecognized operating system") 
      }
   }

   if ! defined(File[$path]) {
      # check oracle install folder
      file { $path :
        path    => $path,
        ensure  => directory,
        recurse => false, 
        owner   => $user,
        group   => $group,
        mode    => 0770,
        replace => false,
      }
   }

   
   # put weblogic generic jar
   file { "wls.jar ${version}":
     path    => "${path}${wlsFile}",
     ensure  => present,
     source  => "puppet:///modules/wls/${wlsFile}",
     owner   => $user,
     group   => $group,
     mode    => 0550,
     require => File[$path],
     replace => false,
   }

   if ! defined(File[$oracleHome]) {
     file { $oracleHome:
       path    => $oracleHome,
       ensure  => directory,
       recurse => false, 
       owner   => $user,
       group   => $group,
       mode    => 0770,
       replace => false,
     }
   }

   if ! defined(File[$beaHome]) {
     file { $beaHome:
       path    => $beahome,
       ensure  => directory,
       recurse => false, 
       owner   => $user,
       group   => $group,
       mode    => 0770,
       require => File[$oracleHome],
       replace => false,
     }
   }

   # de xml used by the wls installer
   file { "silent.xml ${version}":
     path    => "${path}silent${version}.xml",
     ensure  => present,
     replace => 'yes',
     owner   => $user,
     group   => $group,
     mode    => 0550,
     content => template("wls/silent.xml.erb"),
     require => File[$path],
   }

   # install weblogic
   wls::wlstexec{ "installer ${version}":
      mdwHome     => $mdwHome,
      fullJDKName => $fullJDKName,
      wlsfile     => "${path}${wlsFile}",
      silentfile  => "${path}silent${version}.xml",
      require     => [File[$oracleHome],File[$beaHome],File["silent.xml ${version}"],File["wls.jar ${version}"]],
   }

}   