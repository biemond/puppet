# == Define: wls::nodemanager
#
# install and configures nodemanager  
#
# === Parameters
#
# [*wlHome*]
#   the weblogic home path /opt/oracle/wls/wls12c/wlserver_12.1
#
# [*fullJDKName*]
#   jdk path jdk1.7.0_07 this maps to /usr/java/.. or c:\program files\
#
# [*listenPort*]
#   port of the nodemanager , default 5556
#
# [*user*]
#   the user which runs the nodemanager on unix = oracle on windows = administrator
#
# [*group*]
#   the group which runs the nodemanager on unix = dba on windows = administrators
#
# === Variables
#
# === Examples
#
#  wls::nodemanager{'nodemanager':
#    wlHome       => '/opt/oracle/wls/wls12c/wlserver_12.1',
#    fullJDKName  => 'jdk1.7.0_07',	
#    user         => 'oracle',
#    group        => 'dba', 
#  }
# 


define wls::nodemanager($wlHome          = undef, 
                        $fullJDKName     = undef,
                        $listenPort      = 5556,
                        $user            = 'oracle',
                        $group           = 'dba',
                        $serviceName     = undef,
                       ) {


   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $execPath         = "/usr/java/${fullJDKName}/bin:${otherPath}"
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

        $execPath         = "C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 
        $path             = "c:\\temp\\" 
        $JAVA_HOME        = "C:\\oracle\\${fullJDKName}"

        Exec { path      => $execPath,
               cwd       => "${wlHome}/common/nodemanager",
             }
     }
   }

   $javaCommand  = "java -client -Xms32m -Xmx200m -XX:PermSize=128m -XX:MaxPermSize=256m -DListenPort=${listenPort} -Dbea.home=${wlHome} -Dweblogic.nodemanager.JavaHome=${JAVA_HOME} -Djava.security.policy=${wlHome}/server/lib/weblogic.policy -Xverify:none weblogic.NodeManager -v"


    
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
        
        exec { "execwlst ux nodemanager":
          command     => "/usr/bin/nohup ${javaCommand} &",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${wlHome}/server/native/linux/x86_64",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          unless      => "${checkCommand}",
        }    

        exec { "execwlst ux StopScriptEnabled":
          command     => "/bin/sed 's/StopScriptEnabled=false/StopScriptEnabled=true/g' nodemanager.properties",
          unless      => "/usr/bin/test -f ${wlHome}/common/nodemanager/nodemanager.properties  && echo 1 || echo 0",
          require     => Exec ["execwlst ux nodemanager"],
          tries       => 3,
          try_sleep   => 5,
        }    

        exec { "execwlst ux StartScriptEnabled":
          command     => "/bin/sed 's/StartScriptEnabled=false/StartScriptEnabled=true/g' nodemanager.properties",
          unless      => "/usr/bin/test -f ${wlHome}/common/nodemanager/nodemanager.properties  && echo 1 || echo 0",
          require     => Exec ["execwlst ux nodemanager"],
          tries       => 3,
          try_sleep   => 5,
        } 
        exec { "execwlst ux CrashRecoveryEnabled":
          command     => "/bin/sed 's/CrashRecoveryEnabled=false/CrashRecoveryEnabled=true/g' nodemanager.properties",
          unless      => "/usr/bin/test -f ${wlHome}/common/nodemanager/nodemanager.properties  && echo 1 || echo 0",
          require     => Exec ["execwlst ux nodemanager"],
          tries       => 3,
          try_sleep   => 5,
        } 
     
     }
     windows: { 

        exec {"icacls win nodemanager bin": 
           command    => "${checkCommand} icacls ${wlHome}\\server\\bin\\* /T /C /grant Administrator:F Administrators:F",
           unless     => "${checkCommand} test -e ${wlHome}/common/nodemanager/nodemanager.properties",
           logoutput  => true,
        } 

        exec {"icacls win nodemanager native": 
           command    => "${checkCommand} icacls ${wlHome}\\server\\native\\* /T /C /grant Administrator:F Administrators:F",
           unless     => "${checkCommand} test -e ${wlHome}/common/nodemanager/nodemanager.properties",
           logoutput  => true,
        } 

        exec { "execwlst win nodemanager":
          command     => "${wlHome}\\server\\bin\\installNodeMgrSvc.cmd",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          require     => [Exec ["icacls win nodemanager bin"],Exec ["icacls win nodemanager native"]],
          unless      => "${checkCommand} test -e ${wlHome}/common/nodemanager/nodemanager.properties",
          logoutput   => true,
        }    

        service { "Oracle WebLogic NodeManager (${serviceName})":
                enable     => true,
                ensure     => true,
                hasrestart => true,
                require    => Exec ["execwlst win nodemanager"],
        }

        exec { "execwlst win StopScriptEnabled":
          command     => "${checkCommand} sed \"s/StopScriptEnabled=false/StopScriptEnabled=true/g\" nodemanager.properties > nodemanager1.properties",
          unless      => "${checkCommand} dir ${wlHome}/common/nodemanager/nodemanager.properties",
          require     => Service ["Oracle WebLogic NodeManager (${serviceName})"],
          tries       => 6,
          try_sleep   => 5,
          logoutput   => true,
        }    

        exec { "execwlst win StartScriptEnabled":
          command     => "${checkCommand} sed \"s/StartScriptEnabled=false/StartScriptEnabled=true/g\" nodemanager1.properties > nodemanager2.properties",
          unless      => "${checkCommand} dir ${wlHome}/common/nodemanager/nodemanager.properties",
          require     => Exec[ "execwlst win StopScriptEnabled"],
          tries       => 6,
          try_sleep   => 5,
          logoutput   => true,
        } 
        exec { "execwlst win CrashRecoveryEnabled":
          command     => "${checkCommand} sed \"s/CrashRecoveryEnabled=false/CrashRecoveryEnabled=true/g\" nodemanager2.properties > nodemanager.properties",
          unless      => "${checkCommand} dir ${wlHome}/common/nodemanager/nodemanager.properties",
          require     => Exec[ "execwlst win StartScriptEnabled"],
          tries       => 6,
          try_sleep   => 5,
          logoutput   => true,
        } 

     }
   }
}
