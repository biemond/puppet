# jdk7::instal7
define jdk7::install7( $version     =  "7u17" , 
                       $fullVersion =  "jdk1.7.0_17",
											 $x64         =  "true",
											 $downloadDir =  '/install/', ) {

    notify {"install7.pp ${title} ${version}":}

    if $x64 == "true" {
      $type = 'x64'
    } else {
      $type = 'i586'
    }

    case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 
        $installVersion   = "linux"
        $installExtension = ".tar.gz"

        $user             = "root"
        $group            = "root"
      }
      default: { 
        fail("Unrecognized operating system") 
      }
    }
     
    $jdkfile =  "jdk-$version-${installVersion}-${type}${installExtension}"

    File { 
      replace => false,
    }

    # check install folder
    if ! defined(File[$downloadDir]) {
      file { $downloadDir :
        mode    => 0777,
        path    => $downloadDir,
        ensure  => directory,
      }
    }
    
    # download jdk to client
    if ! defined(File["${downloadDir}${jdkfile}"]) {
     file {"${downloadDir}${jdkfile}":
        path    => "${downloadDir}${jdkfile}",
        ensure  => present,
        source  => "puppet:///modules/jdk7/${jdkfile}",
        require => File[$downloadDir],
     } 
    }
    # install on client 
    javaexec {"jdkexec ${title} ${version}": 
          path        => $downloadDir, 
          fullversion => $fullVersion,
          jdkfile     => $jdkfile,
          user        => $user,
          group       => $group,
          require     => File["${downloadDir}${jdkfile}"],
    }
}