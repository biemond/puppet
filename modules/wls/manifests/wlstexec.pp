# wlstexec.pp 

define wls::wlstexec ($wlHome = undef, $fullJDKName = undef, $user = 'oracle', $group = 'dba' ) {

   $javaCommand    = "java weblogic.WLST"
    
    
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $execPath         = "/usr/java/${fullJDKName}$/bin:${otherPath}"
        $checkCommand     = '/bin/ls -l'
        
        exec { "execwlst ux":
          command     => "${javaCommand} ",
          path        => $execPath,
          environment => "CLASSPATH=${wlHome}/server/lib/weblogic.jar",
          logoutput   => true,
          user        => $user,
          group       => $group,
        }    
     
     }
     windows: { 

        $otherPath        = "C:\\Windows\\system32;C:\\Windows"
        $execPath         = "\"C:\\Program Files\\Java\\${fullJDKName}\\bin\";${otherPath}"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 

        exec { "execwlst ux":
          command     => "${checkCommand} ${javaCommand} ",
          environment => "CLASSPATH=${wlHome}/server/lib/weblogic.jar",
          path        => $execPath,
          logoutput   => true,
        }    
     }
   }
}
