# javaexec 

define javaexec ($path = undef, $fullversion = undef, $jdkfile = undef  ) {

    notify {"install7.pp params ${path} ${fullversion} ${jdkfile}":}


   # install jdk
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        exec {"jdk_install": 
           cwd     =>  $path,
           command =>  "/bin/rpm -Uvh --replacepkgs ${path}${jdkfile}",
           unless  =>  "/bin/ls -l /usr/java/${fullversion}/bin",
        }      
     }
     windows: { 

        exec {"jdk_install": 
           cwd     =>  $path,
           command =>  "${path}${jdkfile} /s ADDLOCAL=\"ToolsFeature\"",
           unless  =>  "C:\\Windows\\System32\\cmd.exe /c dir \"C:\\Program Files\\Java\\${fullversion}\\bin\"",
        }      
     }
   }
   
}
