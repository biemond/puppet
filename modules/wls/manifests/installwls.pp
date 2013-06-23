# == Define: wls::installwls
#
# Downloads from file folder and install weblogic with a silent install on linux and windows servers 
#
# === Examples
#
#
#  $jdkWls12cJDK  = 'jdk1.7.0_09'
#  $wls12cVersion = "1211"
#  
#  $user         = "oracle"
#  $group        = "dba"
#  $osOracleHome = "/opt/wls"
#  $osMdwHome    = "/opt/wls/Middleware11gR1"
#
#  # set the defaults
#  Wls::Installwls {
#    version      => $wls12cVersion,
#    fullJDKName  => $jdkWls12cJDK,
#    oracleHome   => $osOracleHome,
#    mdwHome      => $osMdwHome,
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

define wls::installwls( $version     = undef, 
                        $fullJDKName = undef,
                        $oracleHome  = undef,
                        $mdwHome     = undef,
                        $user        = 'oracle',
                        $group       = 'dba',
                        $downloadDir = '/install/',
                        $puppetDownloadMntPoint  = undef,  
                      ) {

   notify {"wls::installwls ${version}":}

   $wls1211Parameter     = "1211"
   $wlsFile1211          = "wls1211_generic.jar" 

   $wls1036Parameter     = "1036"
   $wlsFile1036          = "wls1036_generic.jar" 

   $wlsFileDefault       = $wlsFile1036 

   case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
        $path            = $downloadDir
     }
      windows: { 
        $path            = $downloadDir 
      }
      default: { 
        fail("Unrecognized operating system") 
      }
   }

    # check weblogic version like 12c
    if $version == undef {
      $wlsFile    =  $wlsFileDefault 
    }
    elsif $version == $wls1211Parameter  {
      $wlsFile    =  $wlsFile1211 
    } 
    elsif $version == $wls1036Parameter  {
      $wlsFile    =  $wlsFile1036 
    } 
    else {
      $wlsFile    =  $wlsFileDefault 
    } 


   # for linux , create a oracle user plus a dba group
   case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 
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
              password   => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',  
              home       => "/home/${user}",
              comment    => 'This user ${user} was created by Puppet',
              require    => Group[$group],
              managehome => true, 
          }
        }
     }
      Solaris: { 
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
              password   => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',  
              home       => "/export/home/${user}",
              comment    => 'This user ${user} was created by Puppet',
              require    => Group[$group],
              managehome => true, 
          }
        }
     }
   }

   # set the environment related vars		
   case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: { 
        $beaHome     = $mdwHome

     }
      windows: { 
        $beaHome     = $mdwHome
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


   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/wls/"    	
   } else {
     $mountPoint =	$puppetDownloadMntPoint
   }

   # set file defaults
   File{
        owner   => $user,
        group   => $group,
        mode    => 0770,
   }

   # set exec defaults
   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $execPath         = "/usr/java/${fullJDKName}/bin:${otherPath}"
        
        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
  
     
     }
     Solaris: { 

        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $execPath         = "/usr/jdk/${fullJDKName}/bin/amd64:${otherPath}"
        
        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
     }
     windows: { 

        $execPath         = "C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 

        Exec { path      => $execPath,
             }
     }
   }



   # create all folders 
   case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: {    
          exec { 'create ${oracleHome} directory':
                  command => "mkdir -p ${oracleHome}",
                  unless  => "test -d ${oracleHome}",
                  user    => 'root',
          }
          exec { 'create ${downloadDir} home directory':
                  command => "mkdir -p ${downloadDir}",
                  unless  => "test -d ${downloadDir}",
                  user    => 'root',
          }


      }
      windows: {
      	  # make dir folder suitable for unxtools
      	  $oracleHomeWin  = slash_replace( $oracleHome )
      	  $downloadDirWin = slash_replace( $downloadDir )      	  
          exec { 'create ${oracleHome} directory':
                  command => "${checkCommand} mkdir ${oracleHomeWin}",
                  unless  => "${checkCommand} dir ${oracleHomeWin}",
          }
          exec { 'create ${downloadDir} home directory':
                  command => "${checkCommand} mkdir ${downloadDirWin}",
                  unless  => "${checkCommand} dir ${downloadDirWin}",
          }
       }
       default: { 
        fail("Unrecognized operating system") 
        }
     }		


   # also set permissions on downloadDir
   if ! defined(File[$path]) {
      # check oracle install folder
      file { $path :
        path    => $path,
        ensure  => directory,
        recurse => false, 
        replace => false,
        require => Exec['create ${downloadDir} home directory'],
      }
   }

   
   # put weblogic generic jar
   file { "wls.jar ${version}":
     path    => "${path}/${wlsFile}",
     ensure  => file,
     source  => "${mountPoint}/${wlsFile}",
     require => File[$path],
     replace => false,
     backup  => false,
   }

   # also set permissions on oracleHome
   if ! defined(File[$oracleHome]) {
     file { $oracleHome:
       path    => $oracleHome,
       ensure  => directory,
       recurse => true, 
       replace => false,
       require => Exec['create ${oracleHome} directory'],
     }
   }


   if ! defined(File[$beaHome]) {
     file { $beaHome:
       path    => $beaHome,
       ensure  => directory,
       recurse => true, 
       replace => false,
       require => File[$oracleHome],
     }
   }

   # de xml used by the wls installer
   file { "silent.xml ${version}":
     path    => "${path}/silent${version}.xml",
     ensure  => present,
     replace => 'yes',
     content => template("wls/silent.xml.erb"),
     require => File[$path],
   }

   # install weblogic
   wls::wlsexec{ "installer ${version}":
      mdwHome     => $beaHome,
      fullJDKName => $fullJDKName,
      wlsfile     => "${path}/${wlsFile}",
      silentfile  => "${path}/silent${version}.xml",
      user        => $user,
      group       => $group,
      require     => [File[$oracleHome],File[$beaHome],File["silent.xml ${version}"],File["wls.jar ${version}"]],
   }

 }
}   