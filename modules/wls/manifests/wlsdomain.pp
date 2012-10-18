# == Define: wls::wlsdomain
#
# install a new weblogic domain  
#
# === Parameters
#
# [*wlHome*]
#   the weblogic home path /opt/oracle/wls/wls12c/wlserver_12.1
#
# [*fullJDKName*]
#   jdk path jdk1.7.0_07 this maps to /usr/java/.. or c:\program files\
#
# [*wlsTemplate*]
#   default weblogic domain template   
#
# [*domain*]
#   the name of the domain
#
# [*adminServerName*]
#   weblogic adminserver name
#
# [*adminListenAdr*]
#   listen ip addresses for the adminserver
#
# [*adminListenPort*]
#   port for adminserver
#
# [*wlsUser*]
#   weblogic username
#
# [*password*]
#   weblogic password
#
# [*domainPath*]
#   path for the weblogic domains
#
# [*user*]
#   the user which owns the software on unix = oracle on windows = administrator
#
# [*group*]
#   the group which owns the software on unix = dba on windows = administrators
#
# === Variables
#
# === Examples
#
# Wls::Wlsdomain {
#   wlHome       => '/opt/oracle/wls/wls12c/wlserver_12.1',
#   fullJDKName  => 'jdk1.7.0_07',	
#   user         => 'oracle',
#   group        => 'dba',    
# }
#
# wls::wlsdomain{
# 
#   'testDomain':
#   wlsTemplate  => "standard",
#   domain       => 'myTestDomain',
#   domainPath   => "/opt/oracle/wls/wls12c/admin";
#
#   'testDomain2':
#   wlsTemplate  => "standard",
#   domain       => 'myTestDomain2',
#   domainPath   => "/opt/oracle/wls/wls12c/admin";
# }
# 
# 

define wls::wlsdomain ($wlHome          = undef,
                       $mdwHome         = undef,
                       $fullJDKName     = undef,
                       $wlsTemplate     = "standard",
                       $domain          = undef,
                       $adminServerName = "AdminServer",
                       $adminListenAdr  = "localhost",
                       $adminListenPort = '7001',
                       $nodemanagerPort = '5556',
                       $wlsUser         = "weblogic",
                       $password        = "weblogic1",
                       $domainPath      = undef,
                       $user            = 'oracle',
                       $group           = 'dba',
                       ) {

   notify {"Domain ${domain} wlHome ${wlHome}":}

     # check if the domain already exists 
     $found = domain_exists("${domainPath}/${domain}")
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         notify {"wls::wlsdomain ${title} ${domainPath}/${domain} already exists":}
         $continue = false
       } else {
         notify {"wls::wlsdomain ${title} ${domainPath}/${domain} does not exists":}
         $continue = true 
       }
     }


if ( $continue ) {


   $javaCommand    = "java weblogic.WLST"
   
   $template             = "${wlHome}/common/templates/domains/wls.jar"
   $templateOSB          = "${mdwHome}/Oracle_OSB1/common/templates/applications/wlsb.jar"
   $templateSOAAdapters  = "${mdwHome}/Oracle_OSB1/common/templates/applications/oracle.soa.common.adapters_template_11.1.1.jar"
   $templateWS           = "${wlHome}/common/templates/applications/wls_webservice.jar"
   $templateJRF          = "${mdwHome}/oracle_common/common/templates/applications/jrf_template_11.1.1.jar"
   
   if $wlsTemplate == 'standard' {

      $templateFile  = "wls/domain.xml.erb"

   } elsif $wlsTemplate == 'osb' {

      $templateFile  = "wls/domain_osb.xml.erb"

   } else {

      $templateFile  = "wls/domain.xml.erb"
   } 
   

   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path             = '/install/'
        $JAVA_HOME        = "/usr/java/${fullJDKName}"
        $nodeMgrMachine   = "UnixMachine"


        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
        File {
               ensure  => present,
               replace => 'yes',
               mode    => 0555,
               owner   => $user,
               group   => $group,
             }     
     }
     windows: { 

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $path             = "c:/temp/" 
        $path_win         = "c:\\temp\\" 
        $JAVA_HOME        = "c:\\oracle\\${fullJDKName}"
        $nodeMgrMachine   = "Machine"

        Exec { path      => $execPath,
               logoutput => true,
             }
        File { ensure  => present,
               replace => 'yes',
               mode    => 0777,
             }     
     }
   }

    
   # the domain.py used by the wlst
   file { "domain.py ${domain} ${title}":
     path    => "${path}domain_${domain}.py",
     content => template($templateFile),
   }
    
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
        
        exec { "execwlst ux ${domain} ${title}":
          command     => "${javaCommand} ${path}domain_${domain}.py",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          unless      => "/usr/bin/test -e ${domainPath}/${domain}",
          creates     => "${domainPath}/${domain}",
          require     => File["domain.py ${domain} ${title}"],
        }    

        exec { "domain.py ${domain} ${title}":
           command     => "rm -I ${path}domain_${domain}.py",
           subscribe   => Exec["execwlst ux ${domain} ${title}"],
           refreshonly => true
        }

        # kill the nodemanager 
        exec { "execwlst ux kill nodemanager ${title}":
          command     => "/bin/kill -9 `/bin/ps -ef | /bin/grep -i nodemanager.javahome | /bin/grep -v grep | /bin/grep -i ${nodemanagerPort} | awk {'print \$2'} | head -1`",
          onlyif      => "/bin/ps -ef | grep -v grep | /bin/grep 'weblogic.NodeManager' | /bin/grep '${nodemanagerPort}'",
          subscribe   => Exec["execwlst ux ${domain} ${title}"],
          refreshonly => true
        }    

        $javaNodeCommand  = "java -client -Xms32m -Xmx200m -XX:PermSize=128m -XX:MaxPermSize=256m -DListenPort=${nodemanagerPort} -Dbea.home=${wlHome} -Dweblogic.nodemanager.JavaHome=${JAVA_HOME} -Djava.security.policy=${wlHome}/server/lib/weblogic.policy -Xverify:none weblogic.NodeManager -v"

        # start the nodemanager
        exec { "execwlst ux start nodemanager ${title}":
          command     => "/usr/bin/nohup ${javaNodeCommand} &",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${wlHome}/server/native/linux/x86_64",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          unless      =>  "/bin/ps -ef | grep -v grep | /bin/grep 'weblogic.NodeManager' | /bin/grep '${nodemanagerPort}'",
          cwd         => "${wlHome}/common/nodemanager",
          subscribe   => Exec["execwlst ux kill nodemanager ${title}"],
          refreshonly => true
        }    


     
     }
     windows: { 
     
        notify{"${domainPath}/${domain} ${title}":}
        
        exec { "execwlst win ${domain} ${title}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommand} ${path}domain_${domain}.py",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
#          unless      => "C:\\Windows\\System32\\cmd.exe /c test -e ${domainPath}/${domain}",
          creates     => "${domainPath}/${domain}",
          require     => File["domain.py ${domain} ${title}"],
        }    

        exec {"icacls domain ${title}${script}": 
           command    => "C:\\Windows\\System32\\cmd.exe /c  icacls ${domainPath}/${domain} /T /C /grant Administrator:F Administrators:F",
           logoutput  => false,
           subscribe   => Exec["execwlst win ${domain} ${title}"],
           refreshonly => true,
#           require    => Exec["execwlst win ${domain} ${title}"],
        } 

        exec { "domain.py ${domain} ${title}":
           command     => "C:\\Windows\\System32\\cmd.exe /c del ${path_win}domain_${domain}.py",
#           require => Exec["icacls domain ${title}${script}"],
           subscribe   => Exec["icacls domain ${title}${script}"],
           refreshonly => true,
          }

        exec { "domain win stop service ${title}":
          command     => "C:\\Windows\\System32\\cmd.exe /c NET STOP \"Oracle WebLogic NodeManager (${serviceName})\"",
          subscribe   => Exec["domain.py ${domain} ${title}"],
          refreshonly => true,
          logoutput   => true,
        } 

        exec { "domain win start service ${title}":
          command     => "C:\\Windows\\System32\\cmd.exe /c NET START \"Oracle WebLogic NodeManager (${serviceName})\"",
          subscribe   => Exec ["domain win stop service ${title}"],
          refreshonly => true,
          logoutput   => true,
        } 


     }
   }

}
}
