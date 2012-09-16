# javaexec 

define javaexec ($version = undef, $path = undef, $fullversion = undef, $jdkfile = undef  ) {

   notify {"install7.pp params ${path} ${fullversion} ${jdkfile}":}


   # install jdk
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        # for java version 6 we need to accept the license
        if $version in ['6u36','6u35', '6u34', '6u33'] {

           # download answer file for the installer to the client
            file {"answerfile${version}":
              path   => "${path}answer_file.txt",
              ensure => present,
              source => "puppet:///modules/jdk7/answer_file.txt",
              owner  => "${user}",
              group  => "${group}",
              mode   => 0770,
            } 

            exec {"jdk_install${version}": 
              command =>  "${path}${jdkfile} < ${path}answer_file.txt",
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

        exec {"jdk_install${version}": 
           command =>  "${path}${jdkfile} /s ADDLOCAL=\"ToolsFeature\"",
           unless  =>  "C:\\Windows\\System32\\cmd.exe /c dir \"C:\\Program Files\\Java\\${fullversion}\\bin\"",
           logoutput   => true,
        }      
     }
   }
   
}
