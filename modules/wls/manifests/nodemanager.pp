# nodemanager.pp 

define wls::nodemanager($wlHome          = undef, 
                        $fullJDKName     = undef,
                        $listenPort      = 5556,
                        $user            = 'oracle',
                        $group           = 'dba',
                       ) {


   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $execPath         = "/usr/java/${fullJDKName}$/bin:${otherPath}"
        $checkCommand     = "/bin/ps -ef | grep -v grep | /bin/grep 'weblogic.NodeManager'"
        $path             = '/install/'
        $JAVA_HOME        = "/usr/java/${fullJDKName}"
        
        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
               cwd       => "${wlHome}/common/nodemanager",
             }
     
     }
     windows: { 

        $otherPath        = "C:\\Windows\\system32;C:\\Windows"
        $execPath         = "\"C:\\Program Files\\Java\\${fullJDKName}\\bin\";${otherPath}"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 
        $path             = "c:\\temp\\" 
        $JAVA_HOME        = "\"C:\\Program Files\\Java\\${fullJDKName}\""

        Exec { path      => $execPath,
               logoutput => true,
               cwd       => "${wlHome}\\common\\nodemanager",
             }
     }
   }

   $javaCommand  = "java -client -Xms32m -Xmx200m -XX:PermSize=128m -XX:MaxPermSize=256m -Djava.security.egd=file:/dev/../dev/urandom -DListenPort=${listenPort} -Dbea.home=${wlHome} -Dweblogic.nodemanager.JavaHome=${JAVA_HOME} -Djava.security.policy=${wlHome}/server/lib/weblogic.policy -Xverify:none weblogic.NodeManager -v"


    
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
        
        exec { "execwlst ux nodemanager":
          command     => "/usr/bin/nohup ${javaCommand} &",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${wlHome}/server/native/linux/x86_64"],
          unless      => "${checkCommand}",
        }    

        exec { "execwlst ux StopScriptEnabled":
          command     => "/bin/sed 's/StopScriptEnabled=false/StopScriptEnabled=true/g' nodemanager.properties",
          unless      => "/usr/bin/test -f ${wlHome}/common/nodemanager/nodemanager.properties",
          require     => Exec ["execwlst ux nodemanager"],
          tries       => 3,
          try_sleep   => 5,
        }    

        exec { "execwlst ux StartScriptEnabled":
          command     => "/bin/sed 's/StartScriptEnabled=false/StartScriptEnabled=true/g' nodemanager.properties",
          unless      => "/usr/bin/test -f ${wlHome}/common/nodemanager/nodemanager.properties",
          require     => Exec ["execwlst ux nodemanager"],
          tries       => 3,
          try_sleep   => 5,
        } 

     
     }
     windows: { 

        exec { "execwlst win domain":
          command     => "${checkCommand} ${javaCommand}",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
        }    
     }
   }
}
