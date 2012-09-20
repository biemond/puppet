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
     
     }
     windows: { 

        $otherPath        = "C:\\Windows\\system32;C:\\Windows"
        $execPath         = "\"C:\\Program Files\\Java\\${fullJDKName}\\bin\";${otherPath}"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 
        $path             = "c:\\temp\\" 
        $JAVA_HOME        = "\"C:\\Program Files\\Java\\${fullJDKName}\""
     }
   }

   $javaCommand  = "java -client -Xms32m -Xmx200m -XX:PermSize=128m -XX:MaxPermSize=256m -Djava.security.egd=file:/dev/../dev/urandom -DListenPort=${listenPort} -Dbea.home=${wlHome} -Dweblogic.nodemanager.JavaHome=${JAVA_HOME} -Djava.security.policy=${wlHome}/server/lib/weblogic.policy -Xverify:none weblogic.NodeManager -v"


    
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
        
        exec { "execwlst ux domain":
          command     => "/usr/bin/nohup ${javaCommand} &",
          cwd         => "${wlHome}/common/nodemanager",
          path        => $execPath,
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${wlHome}/server/native/linux/x86_64"],
          logoutput   => true,
          user        => $user,
          group       => $group,
          unless      => "${checkCommand}",
        }    

        exec { "execwlst ux StopScriptEnabled":
          command     => "/bin/sed 's/StopScriptEnabled=false/StopScriptEnabled=true/g' nodemanager.properties",
          cwd         => "${wlHome}/common/nodemanager",
          path        => $execPath,
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${wlHome}/server/native/linux/x86_64"],
          logoutput   => true,
          user        => $user,
          group       => $group,
          unless      => "/usr/bin/test -f ${wlHome}/common/nodemanager/nodemanager.properties",
          require     => Exec ["execwlst ux domain"],
          tries       => 3,
          try_sleep   => 5,
        }    

        exec { "execwlst ux StartScriptEnabled":
          command     => "/bin/sed 's/StartScriptEnabled=false/StartScriptEnabled=true/g' nodemanager.properties",
          cwd         => "${wlHome}/common/nodemanager",
          path        => $execPath,
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${wlHome}/server/native/linux/x86_64"],
          logoutput   => true,
          user        => $user,
          group       => $group,
          unless      => "/usr/bin/test -f ${wlHome}/common/nodemanager/nodemanager.properties",
          require     => Exec ["execwlst ux domain"],
          tries       => 3,
          try_sleep   => 5,
        } 

     
     }
     windows: { 

        exec { "execwlst win domain":
          command     => "${checkCommand} ${javaCommand}",
          cwd         => "${wlHome}/common/nodemanager",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          path        => $execPath,
          logoutput   => true,
#          unless      => "${checkCommand} dir ${domainPath}\\${domain}",
        }    
     }
   }
}
