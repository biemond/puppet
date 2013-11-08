# == Define: wls::nodemanager
#
# install and configures nodemanager
#
#
# === Examples
#
#  $jdkWls12cJDK = 'jdk1.7.0_09'
#  $wls12cVersion = "1211"
#
#
#  case $operatingsystem {
#     centos, redhat, OracleLinux, ubuntu, debian: {
#       $osWlHome     = "/opt/oracle/wls/wls12c/wlserver_12.1"
#       $user         = "oracle"
#       $group        = "dba"
#     }
#     windows: {
#       $osWlHome     = "c:/oracle/wls/wls12c/wlserver_12.1"
#       $user         = "Administrator"
#       $group        = "Administrators"
#       $serviceName  = "C_oracle_wls_wls12c_wlserver_12.1"
#     }
#  }
#
#
#  Wls::Nodemanager {
#    wlHome       => $osWlHome,
#    fullJDKName  => $jdkWls12cJDK,
#    user         => $user,
#    group        => $group,
#    serviceName  => $serviceName,
#  }
#
#  #nodemanager configuration and starting
#  wls::nodemanager{'nodemanager':
#    listenPort   => '5556',
#  }
#
define wls::nodemanager($version         = "1111",
                        $wlHome          = undef,
                        $fullJDKName     = undef,
                        $listenPort      = 5556,
                        $user            = 'oracle',
                        $group           = 'dba',
                        $serviceName     = undef,
                        $logDir          = undef,
                        $downloadDir     = '/install',
                        $domain          = undef,
                       ) {

   if $version == "1111" {
     $nodeMgrHome = "${wlHome}/common/nodemanager"

   } elsif $version == "1212" {
     $nodeMgrHome = "${wlHome}/../user_projects/domains/${domain}/nodemanager"

   } else {
     $nodeMgrHome = "${wlHome}/common/nodemanager"
   }

   if $logDir == undef {
      $nodeLogDir = "${nodeMgrHome}/nodemanager.log"
   } else {
      $nodeLogDir = "${logDir}/nodemanager.log"
   }

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $execPath         = "/usr/java/${fullJDKName}/bin:${otherPath}"
        $checkCommand     = "/bin/ps -ef | grep -v grep | /bin/grep 'weblogic.NodeManager'"
        $JAVA_HOME        = "/usr/java/${fullJDKName}"
        $nativeLib        = "linux/x86_64"

        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
               cwd       => $nodeMgrHome,
             }

        File{
            owner   => $user,
            group   => $group,
            backup  => false,
#            mode    => 0775,
        }
     }
     Solaris: {

        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $execPath         = "/usr/jdk/${fullJDKName}/bin/amd64:${otherPath}"
        $checkCommand     = "/usr/ucb/ps wwxa | grep -v grep | /bin/grep 'weblogic.NodeManager'"
        $JAVA_HOME        = "/usr/jdk/${fullJDKName}"
        $nativeLib        = "solaris/x64"

        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
               cwd       => $nodeMgrHome,
             }
        File{
            owner   => $user,
            group   => $group,
            backup  => false,
#            mode    => 0775,
        }
     }
     windows: {

        $execPath         = "C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c"
        $JAVA_HOME        = "C:\\oracle\\${fullJDKName}"

        Exec { path      => $execPath,
               cwd       => $nodeMgrHome,
             }

        File{
            owner   => $user,
            group   => $group,
            backup  => false,
#            mode    => 0775,
        }
     }
   }

# nodemanager is part of the domain creation
if $version == "1212" {
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

             exec { "startNodemanager 1212 ${title}":
               command => "nohup ${wlHome}/../user_projects/domains/${domain}/bin/startNodeManager.sh &",
               unless  => "${checkCommand}",
             }
             exec { "sleep 20 sec for wlst exec ${title}":
               command     => "/bin/sleep 20",
               subscribe   => Exec ["startNodemanager 1212 ${title}"],
               refreshonly => true,
             }

         }
         windows: {
		        service { "window nodemanager initial start ${title}":
		                name       => "Oracle Weblogic ${domain} NodeManager (${serviceName})",
		                enable     => true,
		                ensure     => true,
		        }
         }
      }
}
elsif $version == "1111" {
   if $logDir != undef {
      # create all folders
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {
            if ! defined(Exec["create ${logDir} directory"]) {
             exec { "create ${logDir} directory":
                     command => "mkdir -p ${logDir}",
                     unless  => "test -d ${logDir}",
                     user    => 'root',
             }
           }
         }
         windows: {
      	   $logDirWin = slash_replace( $logDir )
           if ! defined(Exec["create ${logDir} directory"]) {
             exec { "create ${logDir} directory":
                  command => "${checkCommand} mkdir ${logDirWin}",
                  unless  => "${checkCommand} dir ${logDirWin}",
             }
           }
         }
         default: {
           fail("Unrecognized operating system")
         }
      }


      if ! defined(File["${logDir}"]) {
           file { "${logDir}" :
             ensure  => directory,
             recurse => false,
             replace => false,
             require => Exec["create ${logDir} directory"],
           }
      }
   }

   $javaCommand  = "java -client -Xms32m -Xmx200m -XX:PermSize=128m -XX:MaxPermSize=256m -DListenPort=${listenPort} -Dbea.home=${wlHome} -Dweblogic.nodemanager.JavaHome=${JAVA_HOME} -Djava.security.policy=${wlHome}/server/lib/weblogic.policy -Xverify:none weblogic.NodeManager -v"

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

        file { "nodemanager.properties ux ${title}":
                path    => "${nodeMgrHome}/nodemanager.properties",
                ensure  => present,
                replace => 'yes',
                content => template("wls/nodemgr/nodemanager.properties.erb"),
        }

        exec { "execwlst ux nodemanager ${title}":
          command     => "/usr/bin/nohup ${javaCommand} &",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${wlHome}/server/native/${nativeLib}"],
          unless      => "${checkCommand}",
          require     => File ["nodemanager.properties ux ${title}"],
        }


        exec { "sleep 5 sec for wlst exec ${title}":
          command     => "/bin/sleep 5",
          subscribe   => Exec ["execwlst ux nodemanager ${title}"],
          refreshonly => true,
        }


     }
     windows: {

        exec {"icacls win nodemanager bin ${title}":
           command    => "${checkCommand} icacls ${wlHome}\\server\\bin\\* /T /C /grant Administrator:F Administrators:F",
           unless     => "${checkCommand} test -e ${nodeMgrHome}/nodemanager.properties",
           logoutput  => false,
        }

        exec {"icacls win nodemanager native ${title}":
           command    => "${checkCommand} icacls ${wlHome}\\server\\native\\* /T /C /grant Administrator:F Administrators:F",
           unless     => "${checkCommand} test -e ${nodeMgrHome}/nodemanager.properties",
           logoutput  => false,
        }

        exec { "execwlst win nodemanager ${title}":
          command     => "${wlHome}\\server\\bin\\installNodeMgrSvc.cmd",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          require     => [Exec ["icacls win nodemanager bin ${title}"],Exec ["icacls win nodemanager native ${title}"]],
          unless      => "${checkCommand} test -e ${nodeMgrHome}/nodemanager.properties",
          logoutput   => true,
        }

        file { "nodemanager.properties win ${title}":
                path    => "${nodeMgrHome}/nodemanager.properties",
                ensure  => present,
                replace => 'yes',
                content => template("wls/nodemgr/nodemanager.properties.erb"),
                require => Exec ["execwlst win nodemanager ${title}"],
        }

        service { "window nodemanager initial start ${title}":
                name       => "Oracle WebLogic NodeManager (${serviceName})",
                enable     => true,
                ensure     => true,
                require    => File ["nodemanager.properties win ${title}"],
        }
     }
   }
 }

}
