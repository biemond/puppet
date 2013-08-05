# jdk7::instal7
define jdk7::install7( $version     =  "7u25" , 
                       $fullVersion =  "jdk1.7.0_25",
											 $x64         =  true,
											 $downloadDir =  '/install', ) {

    notify {"install7.pp ${title} ${version}":}

    if $x64 == true {
      $type = 'x64'
    } else {
      $type = 'i586'
    }

    case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: { 
        $installVersion   = "linux"
        $installExtension = ".tar.gz"
        $path             = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'

        $user             = "root"
        $group            = "root"
      }
      default: { 
        fail("Unrecognized operating system") 
      }
    }
     
    $jdkfile =  "jdk-${version}-${installVersion}-${type}${installExtension}"

    File { 
      replace => false,
    }

    exec { "create ${$downloadDir} directory":
             command => "mkdir -p ${$downloadDir}",
             unless  => "test -d ${$downloadDir}",
             user    => 'root',
             path    => $path,
    }


    # check install folder
    if ! defined(File[$downloadDir]) {
      file { $downloadDir :
        mode    => 0777,
        path    => $downloadDir,
        ensure  => directory,
        require => Exec["create ${$downloadDir} directory"],
      }
    }
    
    # download jdk to client
    if ! defined(File["${downloadDir}/${jdkfile}"]) {
     file {"${downloadDir}/${jdkfile}":
        path    => "${downloadDir}/${jdkfile}",
        ensure  => present,
        source  => "puppet:///modules/jdk7/${jdkfile}",
        require => [File[$downloadDir], Exec["create ${$downloadDir} directory"]],
     } 
    }
    # install on client 
    javaexec {"jdkexec ${title} ${version}": 
          path        => $downloadDir, 
          fullversion => $fullVersion,
          jdkfile     => $jdkfile,
          user        => $user,
          group       => $group,
          require     => File["${downloadDir}/${jdkfile}"],
    }
}