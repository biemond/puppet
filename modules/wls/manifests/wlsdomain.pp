# == Define: wls::wlsdomain
#
# install a new weblogic domain  
#
#
# === Examples
#
#  $jdkWls11gJDK = 'jdk1.7.0_09'
#
#  $wlsDomainName   = "osbDomain"
#  $osTemplate      = "osb"
#  $osTemplate      = "standard"
#  $adminListenPort = "7001"
#  $nodemanagerPort = "5556"
#  $address         = "localhost"
#  $wlsUser         = "weblogic"
#  $password        = "weblogic1"
# 
# 
#  case $operatingsystem {
#     centos, redhat, OracleLinux, Ubuntu, debian: { 
#       $osMdwHome    = "/opt/oracle/wls/wls11g"
#       $osWlHome     = "/opt/oracle/wls/wls11g/wlserver_10.3"
#       $osDomainPath = "/opt/oracle/wls/wls11g/admin"
#       $user         = "oracle"
#       $group        = "dba"
#     }
#     windows: { 
#       $osMdwHome    = "c:/oracle/wls/wls11g"
#       $osWlHome     = "c:/oracle/wls/wls11g/wlserver_10.3"
#       $osDomainPath = "c:/oracle/wls/wls11g/admin"
#       $user         = "Administrator"
#       $group        = "Administrators"
#       $serviceName  = "C_oracle_wls_wls11g_wlserver_10.3"
#     }
#  }
#
#  # set the defaults
#
#  Wls::Wlsdomain {
#    wlHome       => $osWlHome,
#    mdwHome      => $osMdwHome,
#    fullJDKName  => $jdkWls11gJDK,	
#    user         => $user,
#    group        => $group,    
#  }
#
# # install OSB domain
# wls::wlsdomain{
# 
#   'osbDomain':
#   wlsTemplate     => $osTemplate,
#   domain          => $wlsDomainName,
#   domainPath      => $osDomainPath,
#   adminListenPort => $adminListenPort,
#   nodemanagerPort => $nodemanagerPort,
# }
## 
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
                       $user            = 'oracle',
                       $group           = 'dba',
                       $downloadDir     = '/install/',
                       $reposDbUrl      = undef,
                       $reposPrefix     = undef,
                       $reposPassword   = undef,
                       ) {

   notify {"Domain ${domain} wlHome ${wlHome}":}

   $domainPath  = "${mdwHome}/user_projects/domains"
   $appPath     = "${mdwHome}/user_projects/applications"



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


     $found2 = rcu_exists($reposDbUrl,$reposPrefix,$reposPassword)
     if $found2 == undef {
     } else {
      if ( $found2 ) {
         notify {"wls::wlsdomain ${title} rcu already exists":}
      } else {
         notify {"wls::wlsdomain ${title} rcu does not exists":}
      }
     }

if ( $continue ) {

   
   $template             = "${wlHome}/common/templates/domains/wls.jar"
   $templateWS           = "${wlHome}/common/templates/applications/wls_webservice.jar"

   $templateOSB          = "${mdwHome}/Oracle_OSB1/common/templates/applications/wlsb.jar"
   $templateSOAAdapters  = "${mdwHome}/Oracle_OSB1/common/templates/applications/oracle.soa.common.adapters_template_11.1.1.jar"

   $templateSOA          = "${mdwHome}/Oracle_SOA1/common/templates/applications/oracle.soa_template_11.1.1.jar"

   $templateJaxWS        = "${mdwHome}/oracle_common/common/templates/applications/wls_webservice_jaxws.jar"
   $templateJRF          = "${mdwHome}/oracle_common/common/templates/applications/jrf_template_11.1.1.jar"
   $templateApplCore     = "${mdwHome}/oracle_common/common/templates/applications/oracle.applcore.model.stub.11.1.1_template.jar"
   $templateWSMPM        = "${mdwHome}/oracle_common/common/templates/applications/oracle.wsmpm_template_11.1.1.jar"
   $templateEM           = "${mdwHome}/oracle_common/common/templates/applications/oracle.em_11_1_1_0_0_template.jar"
   
   if $wlsTemplate == 'standard' {
      $templateFile  = "wls/domain.xml.erb"

   } elsif $wlsTemplate == 'osb' {
      $templateFile  = "wls/domain_osb.xml.erb"

   } elsif $wlsTemplate == 'osb_soa' {
      $templateFile  = "wls/domain_osb_soa.xml.erb"

   } else {
      $templateFile  = "wls/domain.xml.erb"
   } 

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:${wlHome}/common/bin"
        $path             = $downloadDir
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
               mode    => 0775,
               owner   => $user,
               group   => $group,
             }     
     }
     windows: { 

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows;${wlHome}\\common\\bin"
        $path             = $downloadDir 
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

   # make the default domain folders 
   if ! defined(File["${mdwHome}/user_projects"]) {
      # check oracle install folder
      file { "${mdwHome}/user_projects" :
        ensure  => directory,
        recurse => false, 
        replace => false,
      }
   }

   if ! defined(File["${mdwHome}/user_projects/domains"]) {
      # check oracle install folder
      file { "${mdwHome}/user_projects/domains" :
        ensure  => directory,
        recurse => false, 
        replace => false,
        require => File["${mdwHome}/user_projects"],
      }
   }

   if ! defined(File["${mdwHome}/user_projects/applications"]) {
      # check oracle install folder
      file { "${mdwHome}/user_projects/applications" :
        ensure  => directory,
        recurse => false, 
        replace => false,
        require => File["${mdwHome}/user_projects"],
      }
   }

   $javaCommand    = "java -Dweblogic.security.SSL.ignoreHostnameVerification=true weblogic.WLST -skipWLSModuleScanning "
	 $packCommand    = "-domain=${domainPath}/${domain} -template=${path}domain_${domain}.jar -template_name=domain_${domain} -log=${path}domain_${domain}.log -log_priority=INFO" 	


    
   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 
        
        exec { "execwlst ux ${domain} ${title}":
          command     => "${javaCommand} ${path}domain_${domain}.py",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          unless      => "/usr/bin/test -e ${domainPath}/${domain}",
          creates     => "${domainPath}/${domain}",
          require     => [File["domain.py ${domain} ${title}"],File["${mdwHome}/user_projects/domains"],File["${mdwHome}/user_projects/applications"]],
        }    

        exec { "setDebugFlagOnFalse ${domain} ${title}":
        	command => "sed -i -e's/debugFlag=\"true\"/debugFlag=\"false\"/g' ${domainPath}/${domain}/bin/setDomainEnv.sh",
          onlyif  => "/bin/grep debugFlag=\"true\" ${domainPath}/${domain}/bin/setDomainEnv.sh | /usr/bin/wc -l",
          require => Exec["execwlst ux ${domain} ${title}"],
        }

        exec { "domain.py ${domain} ${title}":
           command     => "rm -I ${path}domain_${domain}.py",
           require     => Exec["execwlst ux ${domain} ${title}"],
        }

        exec { "pack domain ${domain} ${title}":
           command     => "pack.sh ${packCommand}",
           require     => Exec["setDebugFlagOnFalse ${domain} ${title}"],
        }

        # kill the nodemanager 
        exec { "execwlst ux kill nodemanager ${title}":
          command     => "/bin/kill -9 `/bin/ps -ef | /bin/grep -i nodemanager.javahome | /bin/grep -v grep | /bin/grep -i ${nodemanagerPort} | awk {'print \$2'} | head -1`",
          onlyif      => "/bin/ps -ef | grep -v grep | /bin/grep 'weblogic.NodeManager' | /bin/grep '${nodemanagerPort}'",
          subscribe   => Exec["pack domain ${domain} ${title}"],
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
          creates     => "${domainPath}/${domain}",
          require     => [File["domain.py ${domain} ${title}"],File["${mdwHome}/user_projects/domains"],File["${mdwHome}/user_projects/applications"]],
        }    

        exec {"icacls domain ${title}${script}": 
           command    => "C:\\Windows\\System32\\cmd.exe /c  icacls ${domainPath}/${domain} /T /C /grant Administrator:F Administrators:F",
           logoutput  => false,
           subscribe   => Exec["execwlst win ${domain} ${title}"],
           refreshonly => true,
        } 

        exec { "domain.py ${domain} ${title}":
           command     => "C:\\Windows\\System32\\cmd.exe /c del ${path}domain_${domain}.py",
           subscribe   => Exec["icacls domain ${title}${script}"],
           refreshonly => true,
          }

        exec { "pack domain ${domain} ${title}":
           command     => "C:\\Windows\\System32\\cmd.exe /c pack.cmd ${packCommand}",
           subscribe   => Exec["icacls domain ${title}${script}"],
           refreshonly => true,
        }

        exec { "domain win stop service ${title}":
          command     => "C:\\Windows\\System32\\cmd.exe /c NET STOP \"Oracle WebLogic NodeManager (${serviceName})\"",
          subscribe   => Exec["pack domain ${domain} ${title}"],
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
