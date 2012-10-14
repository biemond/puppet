# javaexec 

define javaexec ($version     = undef, 
                 $path        = undef, 
                 $fullversion = undef, 
                 $jdkfile     = undef,
                 $user        = undef,
                 $group       = undef,) {

   notify {"install7.pp params ${title} ${path} ${fullversion} ${jdkfile}":}


   # install jdk
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        Exec { path        => $execPath,
               creates     => "/usr/java/${fullversion}/bin/java",
               logoutput   => true,
             }

        # for java version 6 we need to accept the license
        if $version in ['6u36','6u35', '6u34', '6u33'] {

           # download answer file for the installer to the client
           if ! defined(File["${path}answer_file${version}.txt"]) {
            file {"${path}answer_file${version}.txt":
              ensure => present,
              source => "puppet:///modules/jdk7/answer_file.txt",
              mode   => 0770,
            } 
           } 
            exec {"jdk_install${version} ${title}": 
              command     => "${path}${jdkfile} < ${path}answer_file${version}.txt",
              require     => File["answerfile${version}"],
            }      
        } else { 
            # java 7 supports RPM
            exec {"jdk_install${version} ${title}": 
              command     =>  "/bin/rpm -Uvh --replacepkgs ${path}${jdkfile}",
            }      
        }
     }
     windows: { 

        # we use unxutils http://sourceforge.net/projects/unxutils/files/latest/download
        # unzip and put it on c:\
        $execPath         = "C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"

        Exec {  path       => $execPath,
#               logoutput  => true,
             }


        # install jdk on default place
        if ! defined(File["jdk_install${version}"]) {
        exec {"jdk_install${version}": 
           command    => "${path}${jdkfile} /s ADDLOCAL=\"ToolsFeature\"",
           unless     => "C:\\Windows\\System32\\cmd.exe /c dir \"C:/Program Files/Java/${fullversion}\"",
#           creates    => "\"C:\\Program Files\\Java\\${fullversion}\"",
        }
        }      

        # add oracle folder
        if ! defined(File["c:/oracle"]) {
          file { "c:/oracle":
            ensure  => directory,
            recurse => false, 
            owner   => $user,
            group   => $group,
            mode    => 0770,
            replace => false,
            require => Exec ["jdk_install${version}"],
          }
        }

        # move jdk to oracle folder because of space in path name
        exec {"copy jdk_install${version}": 
           command    => "C:\\Windows\\System32\\cmd.exe /c xcopy \"C:\\Program Files\\Java\\${fullversion}\" c:\\oracle\\${fullversion} /E /I /H",
#          unless     => "C:\\Windows\\System32\\cmd.exe /c  test -e c:\\oracle\\${fullversion}",
           creates    => "c:\\oracle\\${fullversion}",
           require    => File ["c:/oracle"],
        }      
        exec {"icacls jdk_install${version}": 
           command    => "C:\\Windows\\System32\\cmd.exe /c icacls C:\\oracle\\${fullversion}\\* /T /C /grant Administrator:F Administrators:F",
           require    => Exec ["copy jdk_install${version}"],
        }      


    }
   }
   
}
