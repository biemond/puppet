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
                       $adminListenPort = 7001,
                       $wlsUser         = "weblogic",
                       $password        = "weblogic1",
                       $domainPath      = undef,
                       $user            = 'oracle',
                       $group           = 'dba',
                       ) {

    notify {"Domain ${domain} wlHome ${wlHome}":}

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
        $JAVA_HOME        = "c:\\oracle\\${fullJDKName}"
        $nodeMgrMachine   = "Machine"

        Exec { path      => $execPath,
               logoutput => true,
             }
        File { ensure  => present,
               replace => 'yes',
               mode    => 0555,
             }     
     }
   }

    
   # the domain.py used by the wlst
   file { "domain.py ${domain}":
     path    => "${path}domain_${domain}.py",
     content => template($templateFile),
   }
    
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
        
        exec { "execwlst ux ${domain}":
          command     => "${javaCommand} ${path}domain_${domain}.py",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
#          unless      => "/usr/bin/test -e ${domainPath}/${domain}",
          creates     => "${domainPath}/${domain}",
          require     => File["domain.py ${domain}"],
        }    
        if ! defined(Exec["domain.py ${domain}"]) {
          exec { "domain.py ${domain}":
           command => "rm -I ${path}domain_${domain}.py",
           require => Exec["execwlst ux ${domain}"],
          }
        }
     
     }
     windows: { 
     
        notify{"${domainPath}/${domain}":}
        
        exec { "execwlst win ${domain}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommand} ${path}domain_${domain}.py",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
#          unless      => "C:\\Windows\\System32\\cmd.exe /c test -e ${domainPath}/${domain}",
          creates     => "${domainPath}/${domain}",
          require     => File["domain.py ${domain}"],
        }    
        if ! defined(Exec["domain.py ${domain}"]) {
          exec { "domain.py ${domain}":
           command => "C:\\Windows\\System32\\cmd.exe /c delete ${path}domain_${domain}.py",
           require => Exec["execwlst win ${domain}"],
          }
        }
     }
   }
}
