# javaexec 

define javaexec ($version     = undef, 
                 $path        = undef, 
                 $fullversion = undef, 
                 $jdkfile     = undef,
                 $user        = undef,
                 $group       = undef,) {

   notify {"install7.pp params ${path} ${fullversion} ${jdkfile}":}


   # install jdk
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        # for java version 6 we need to accept the license
        if $version in ['6u36','6u35', '6u34', '6u33'] {

           # download answer file for the installer to the client
            file {"answerfile${version}":
              path   => "${path}answer_file${version}.txt",
              ensure => present,
              source => "puppet:///modules/jdk7/answer_file.txt",
              mode   => 0770,
            } 

            exec {"jdk_install${version}": 
              command =>  "${path}${jdkfile} < ${path}answer_file${version}.txt",
              unless  =>  "/bin/ls -l /usr/java/${fullversion}/bin",
              logoutput   => true,
              require     => File["answerfile${version}"],
            }      
        } else { 
            # java 7 supports RPM
            exec {"jdk_install${version}": 
              command =>  "/bin/rpm -Uvh --replacepkgs ${path}${jdkfile}",
              unless  =>  "/bin/ls -l /usr/java/${fullversion}/bin",
              logoutput   => true,
            }      
        }
     }
     windows: { 
        # install jdk on default place
        exec {"jdk_install${version}": 
           command    =>  "${path}${jdkfile} /s ADDLOCAL=\"ToolsFeature\"",
           unless     =>  "C:\\Windows\\System32\\cmd.exe /c dir \"C:\\Program Files\\Java\\${fullversion}\\bin\"",
           logoutput  => true,
        }      
        # add oracle folder
        if ! defined(File["c:/oracle"]) {
          file { "c:/oracle":
            path    => "c:/oracle",
            ensure  => directory,
            recurse => false, 
            mode    => 0770,
            replace => false,
            owner   => $user,
            group   => $group,
            require => Exec ["jdk_install${version}"],
          }
        }
        # move jdk to oracle folder because of space in path name
        exec {"move jdk_install${version}": 
           command    =>  "C:\\Windows\\System32\\cmd.exe /c xcopy \"C:\\Program Files\\Java\\${fullversion}\" c:\\oracle\\${fullversion} /e /i /h",
           unless     =>  "C:\\Windows\\System32\\cmd.exe /c dir c:\\oracle\\${fullversion}",
           logoutput  => true,
           require    => File ["c:/oracle"],
        }      
        # set permissions on the jdk folder in the oracle folder
        if ! defined(File["c:/oracle/${fullversion}"]) {
          file { "c:/oracle/${fullversion}":
            path    => "c:/oracle/${fullversion}",
            ensure  => directory,
            recurse => true, 
            mode    => 0777,
            replace => false,
            owner   => $user,
            group   => $group,
            require => Exec ["move jdk_install${version}"],
          }
        }
    }
   }
   
}
