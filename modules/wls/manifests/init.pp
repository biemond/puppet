# class wls

class wls( $version =  undef , $versionJdk = undef )
      inherits wls::params  {


    # check weblogic version like 12c
    if $version == undef {
      $wlsFile    =  $wls::params::wlsFileDefault 
      $wlsVersion =  $wls::params::wlsVersionDefault 
    }
    elsif $version == $wls::params::wls12cParameter  {
      $wlsFile    =  $wls::params::wlsFile12c 
      $wlsVersion =  $wls::params::wlsVersion12c 
    } 
    else {
      $wlsFile    =  $wls::params::wlsFileDefault 
      $wlsVersion =  $wls::params::wlsVersionDefault 
    } 

    if $versionJdk == undef {
      $jdkVersion = $wls::params::jdkVersionDefault
    } else {
      $jdkVersion = $versionJdk
    } 
     
    # is it a know jdk version like 7u7
    if $jdkVersion      == $wls::params::jdkVersion7u7 {
       $fullJDKName  =  $wls::params::fullJDKName7u7
    } elsif $jdkVersion == $wls::params::jdkVersion7u8 {
       $fullJDKName  =  $wls::params::fullJDKName7u8
    } else {
        fail("Unrecognized jdk version")        
    }


   # for linux , create a oracle user plus a dba group
   case $operatingsystem {
      centos, redhat, OracleLinux, ubuntu, debian: { 

        group { $wls::params::group : 
            ensure => present,
        }
        # http://raftaman.net/?p=1311 for generating password
        user { $user : 
            ensure     => present, 
            groups     => $wls::params::group,
            shell      => '/bin/bash',
            password   => '$1$IX3YD7fb$JndzPUOGNCRYp/FG0GM1y/',  
            home       => '/home/oracle',
            comment    => 'This user was created by Puppet',
            require    => Group[$wls::params::group],
            managehome => true, 
        }

     }
   }

   # set the environment related vars		
   case $operatingsystem {
      centos, redhat, OracleLinux, ubuntu, debian: { 
        $execPath  = "${$wls::params::check}${fullJDKName}${$wls::params::checkAfter}:${$wls::params::otherPath}"
        $mdwHome   = "${beaHome}${$wlsVersion}/"
     }
      windows: { 
        $execPath  = "${$wls::params::check}${fullJDKName}${$wls::params::checkAfter};${$wls::params::otherPath}"
        $mdwHome   = "${beaHome}${$wlsVersion}\\"
      }
      default: { 
        fail("Unrecognized operating system") 
      }
   }


   # check oracle install folder
   file { $wls::params::path:
     ensure  => 'directory',
     recurse => false, 
     owner   => $wls::params::user,
     group   => $wls::params::group,
     mode    => 0770,
   }
   
   # put weblogic generic jar
   file { 'wls.jar':
     path    => "${wls::params::path}${wlsFile}",
     ensure  => present,
     require => File[$wls::params::path],
     source  => "puppet:///modules/wls/${wlsFile}",
     owner   => $wls::params::user,
     group   => $wls::params::group,
     mode    => 0550,
   }


   file { $wls::params::oracleHome:
     ensure  => 'directory',
     recurse => false, 
     owner   => $wls::params::user,
     group   => $group,
     mode    => 0770,
   }

    
   file { $wls::params::beaHome:
     ensure  => 'directory',
     recurse => false, 
     owner   => $wls::params::user,
     group   => $wls::params::group,
     mode    => 0770,
     require => File[$wls::params::oracleHome],
   }

   # de xml used by the wls installer
   file { 'silent.xml':
     path    => "${wls::params::path}silent.xml",
     ensure  => present,
     replace => 'yes',
     owner   => $wls::params::user,
     group   => $wls::params::group,
     mode    => 0550,
     content => template("wls/silent.xml.erb"),
     require => File[$wls::params::path],
   }

   # install weblogic
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
    
        exec { 'installwls':
          command     => "${wls::params::javaCommand} ${wls::params::path}${wlsFile} -mode=silent -silent_xml=${wls::params::path}silent.xml",
          environment => "JAVA_HOME=${check}${fullJDKName}",
          path        => $execPath,
          logoutput   => true,
          require     => [File[$oracleHome],File['silent.xml'],File['wls.jar']],
          unless      => "${checkCommand} ${mdwHome}domain-registry.xml",
          user        => $user,
          group       => $group
        }    
     
     }
     windows: { 
        exec { 'installwls':
          command     => "${checkCommand} ${wls::params::javaCommand} ${wls::params::path}${wlsFile} -mode=silent -silent_xml=${wls::params::path}silent.xml",
          path        => $execPath,
          logoutput   => true,
          require     => [File[$wls::params::oracleHome],File['silent.xml'],File['wls.jar']],
          unless      => "${wls::params::checkCommand} dir ${mdwHome}",
        }    
     }
   }

      
}