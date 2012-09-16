# jdk7::instal7

define jdk7::install7( $version =  undef , $x64 = "true" ) {

    notify {"install7.pp":}

    if $x64 == "true" {
      $type = 'x64'
    } else {
      $type = 'i586'
    }

    if $version == undef {
      $jdkVersion = "7u7"
    } else {
      $jdkVersion = $version
    } 

    case $operatingsystem {
      centos, redhat, OracleLinux, ubuntu, debian: { 
        $installVersion   = "linux"
        $installExtension = "rpm"

        $path             = "/root/"

        $user             = "root"
        $group            = "root"
      }
      windows: { 
        $installVersion   = "windows"
        $installExtension = "exe"

        $path             = "C:\\temp\\"

        $user             = "Administrator"
        $group            = "Administrators"
      }
      default: { 
        fail("Unrecognized operating system") 
      }
    }
     
    if $jdkVersion      == "7u7" {
       $jdkfile         =  "jdk-7u7-${installVersion}-${type}.${installExtension}"
       $fullVersion     =  "jdk1.7.0_07"
    } elsif $jdkVersion == "7u8" {
       $jdkfile         =  "jdk-7u8-${installVersion}-${type}.${installExtension}"
       $fullVersion     =  "jdk1.7.0_08"
    } else {
        fail("Unrecognized jdk version")        
    }

    file {"jdk_file":
        path   => "${path}${jdkfile}",
        ensure => present,
        source => "puppet:///modules/jdk7/${jdkfile}",
        owner  => "${user}",
        group  => "${group}",
        mode   => 0770,
    } 

    javaexec {'jdkInstall': 
        path        => $path, 
        fullversion => $fullVersion,
        jdkfile     => $jdkfile,
        require     => File["jdk_file"],
    }

}