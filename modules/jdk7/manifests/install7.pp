# jdk7::instal7

define jdk7::install7( $version =  undef , $x64 = "true" ) {

    notify {"install7.pp ${version}":}

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

        if $version in ['6u36','6u35', '6u34', '6u33'] {
          $installExtension = "-rpm.bin"
       
        } else { 
          $installExtension = ".rpm"
        }
         
        $path             = "/root/"

        $user             = "root"
        $group            = "root"
      }
      windows: { 
        $installVersion   = "windows"
        $installExtension = ".exe"

        $path             = "C:\\temp\\"

        $user             = "Administrator"
        $group            = "Administrators"
      }
      default: { 
        fail("Unrecognized operating system") 
      }
    }
     
    # determine full jdk name 
    if $jdkVersion      == "7u7" {
       $jdkfile         =  "jdk-7u7-${installVersion}-${type}${installExtension}"
       $fullVersion     =  "jdk1.7.0_07"
    } elsif $jdkVersion == "7u8" {
       $jdkfile         =  "jdk-7u8-${installVersion}-${type}${installExtension}"
       $fullVersion     =  "jdk1.7.0_08"
    } elsif $jdkVersion == "6u35" {
       $jdkfile         =  "jdk-6u35-${installVersion}-${type}${installExtension}"
       $fullVersion     =  "jdk1.6.0_35"
    } else {
        fail("Unrecognized jdk version")        
    }

    # download jdk to client
    file {"jdk_file${version}":
        path   => "${path}${jdkfile}",
        ensure => present,
        source => "puppet:///modules/jdk7/${jdkfile}",
        owner  => "${user}",
        group  => "${group}",
        mode   => 0770,
    } 

    # install on client 
    javaexec {"jdkexec${version}": 
        version     => $version,
        path        => $path, 
        fullversion => $fullVersion,
        jdkfile     => $jdkfile,
        require     => File["jdk_file${version}"],
    }

}