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
# [*template*]
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
#   template     => "/common/templates/domains/wls.jar",
#   domain       => 'myTestDomain',
#   domainPath   => "/opt/oracle/wls/wls12c/admin";
#
#   'testDomain2':
#   template     => "/common/templates/domains/wls.jar",
#   domain       => 'myTestDomain2',
#   domainPath   => "/opt/oracle/wls/wls12c/admin";
# }
# 
# 

define wls::wlsdomain ($wlHome          = undef, 
                       $fullJDKName     = undef,
                       $template        = "/common/templates/domains/wls.jar",
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
     content => template("wls/domain.xml.erb"),
   }
    
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
        
        exec { "execwlst ux ${domain}":
          command     => "${javaCommand} ${path}domain_${domain}.py",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          unless      => "/usr/bin/test -f ${domainPath}/${domain} && echo 1 || echo 0",
          require     => File["domain.py ${domain}"],
        }    
     
     }
     windows: { 
     
        notify{"${domainPath}/${domain}":}
        
        exec { "execwlst win ${domain}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommand} ${path}domain_${domain}.py",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          unless      => "C:\\Windows\\System32\\cmd.exe /c test -e ${domainPath}/${domain}",
          require     => File["domain.py ${domain}"],
        }    
     }
   }
}
