# class wls

class wls( $version =  undef , $versionJdk = undef ) {


    if $version == undef {
      $wlsFile    = "wls1211_generic.jar" 
      $wlsVersion = "wls12c" 
    }
    elsif $version == "12c"  {
      $wlsFile = "wls1211_generic.jar" 
      $wlsVersion = "wls12c" 
    } 
    else {
      $wlsFile = "wls1211_generic.jar" 
      $wlsVersion = "wls12c" 
    } 


    if $versionJdk == undef {
      $jdkVersion = "7u7"
    } else {
      $jdkVersion = $versionJdk
    } 
     

    if $jdkVersion      == "7u7" {
       $fullJDKName     =  "jdk1.7.0_07"
    } elsif $jdkVersion == "7u8" {
       $fullJDKName     =  "jdk1.7.0_08"
    } else {
        fail("Unrecognized jdk version")        
    }


   case $operatingsystem {
      centos, redhat, OracleLinux, ubuntu, debian: { 
        $path             = "/install/"

        $oracleHome       = "/opt/oracle/"
        $beaHome          = "${oracleHome}wls/"
        $mdwHome          = "${beaHome}${$wlsVersion}/"

        $user             = "oracle"
        $group            = "dba"

        $check            = '/usr/java/'
        $checkAfter       = '/bin'
        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $checkCommand     = '/bin/ls -l'
        $execPath         = "${check}${fullJDKName}${checkAfter}:${otherPath}"

        group { $group : 
            ensure => present,
        }

        # http://raftaman.net/?p=1311 for generating password
        user { $user : 
            ensure => present, 
            groups => $group,
            shell  => '/bin/bash',
            password => '$1$IX3YD7fb$JndzPUOGNCRYp/FG0GM1y/',  
            home   => '/home/oracle',
            comment => 'This user was created by Puppet',
            require => Group[$group],
            managehome => true, 
        }

     }
      windows: { 
        $path             = "C:\\temp\\"

        $oracleHome       = "C:\\oracle\\"
        $beaHome          = "${oracleHome}wls\\"
        $mdwHome          = "${beaHome}${$wlsVersion}\\"

        $user             = "Administrator"
        $group            = "Administrators"

        $check            = "\"C:\\Program Files\\Java\\"
        $checkAfter       = "\\bin\""
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c dir" 

        $otherPath        = "C:\\Windows\\system32;C:\\Windows"
        $execPath         = "${check}${fullJDKName}${checkAfter};${otherPath}"

      }
      default: { 
        fail("Unrecognized operating system") 
      }
   }



   # check oracle install folder
   file { $path:
     ensure  => 'directory',
     recurse => false, 
     owner   => $user,
     group   => $group,
     mode    => 0770,
   }
   
   # put weblogic generic jar
   file { 'wls.jar':
     path    => "${path}${wlsFile}",
     ensure  => present,
     require => File[$path],
     source  => "puppet:///modules/wls/${wlsFile}",
     owner   => $user,
     group   => $group,
     mode    => 0550,
   }


   file { $oracleHome:
     ensure  => 'directory',
     recurse => false, 
     owner   => $user,
     group   => $group,
     mode    => 0770,
   }

    
   file { $beaHome:
     ensure  => 'directory',
     recurse => false, 
     owner   => $user,
     group   => $group,
     mode    => 0770,
     require => File[$oracleHome],
   }


   file { 'silent.xml':
     path    => "${path}silent.xml",
     ensure  => present,
     replace => 'yes',
     owner   => $user,
     group   => $group,
     mode    => 0550,
     content => template("wls/silent.xml.erb"),
     require => File[$path],
   }


   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
    
        exec { 'installwls':
          command     => "java -Xmx1024m -jar ${path}${wlsFile} -mode=silent -silent_xml=${path}silent.xml",
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
          command     => "java -Xmx1024m -jar ${path}${wlsFile} -mode=silent -silent_xml=${path}silent.xml",
          environment => "JAVA_HOME=${check}${fullJDKName}\"",
          path        => $execPath,
          logoutput   => true,
          require     => [File[$oracleHome],File['silent.xml'],File['wls.jar']],
          unless      => "${checkCommand} ${mdwHome}",
        }    
     }
   }
   notify {"exec java -Xmx1024m -jar ${path}${wlsFile} -mode=silent -silent_xml=${path}silent.xml":}
   notify {"path ${execPath}":}
     
 }