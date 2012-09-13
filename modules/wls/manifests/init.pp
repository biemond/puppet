# class wls
# install weblogic on linux and windows systems
# create user and group + install folder
# uploads silent.xml ( set bea home )  and weblogic.jar
# exec the java installer for weblogic installation.


class wls( $version =  undef , $versionJdk = undef ) {

   case $operatingsystem {
      centos, redhat, OracleLinux, ubuntu, debian: { 
        $path             = "/install/"
        $oracleHome       = "/opt/oracle"
        $beaHome          = "${oracleHome}/wls"
        $user             = "oracle"
        $group            = "dba"
        $check            = '/usr/java/'
        $checkAfter       = '/bin'
        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'


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
        $path             = "c:\\temp\\"
        $beaHome          = "c:\\oracle\\wls\\"
        $user             = "Administrator"
        $group            = "Administrators"
      }
      default: { 
        fail("Unrecognized operating system") 
      }
   }

    if $version == undef {
      $wlsFile = "wls1211_generic.jar" 
    }
    elsif $version == "12c"  {
      $wlsFile = "wls1211_generic.jar" 
    } 
    else {
      $wlsFile = "wls1211_generic.jar" 
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

   $execPath = "${check}${fullJDKName}${checkAfter}:${otherPath}"

   # check oracle install folder
   file { $path:
     ensure  => 'directory',
     recurse => true, 
     owner   => $user,
     group   => $group,
     mode    => 0770,
   }
   
   # put weblogic generic jar
   file { 'wls.jar':
     path    => "${path}${wlsFile}",
     ensure  => file,
     require => [User[$user],File[$path]],
     source  => "puppet:///modules/wls/${wlsFile}",
     owner   => $user,
     group   => $group,
     mode    => 0550,
   }


   file { $oracleHome:
     ensure  => 'directory',
     recurse => true, 
     owner   => $user,
     group   => $group,
     mode    => 0770,
   }

    
   file { $beaHome:
     ensure  => 'directory',
     recurse => true, 
     owner   => $user,
     group   => $group,
     mode    => 0770,
     require => File[$oracleHome],
   }


   file { 'silent.xml':
     path    => "${path}silent.xml",
     ensure  => present,
     owner   => $user,
     group   => $group,
     mode    => 0550,
     content => template("wls/silent.xml.erb"),
     require => File[$path],
   }
    
   exec { 'installwls':
    command     => "java -Xmx1024m -jar ${path}${wlsFile} -mode=silent -silent_xml=${path}silent.xml",
    environment => "JAVA_HOME=${check}${fullJDKName}",
    path        => $execPath,
    logoutput   => true,
    require     => [File[$oracleHome],File['silent.xml'],File['wls.jar']],
    user        => $user
  }    
 
 
   
 }