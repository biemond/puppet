# == Define: wls::wlstexec
#
# generic wlst script  
#
# === Parameters
#
# [*wlHome*]
#   the weblogic home path /opt/oracle/wls/wls12c/wlserver_12.1
#
# [*fullJDKName*]
#   jdk path jdk1.7.0_07 this maps to /usr/java/.. or c:\program files\
#
# [*id*]
#   unique for the scripting
#
# [*script*]
#   wlst script
#
# [*address*]
#   address of nodemanager or adminserver
#
# [*port*]
#   port number of nodemanager or adminserver
#
# [*wlsUser*]
#   weblogic username
#
# [*password*]
#   weblogic password
#
# [*user*]
#   the user which owns the software on unix = oracle on windows = administrator
#
# [*group*]
#   the group which owns the software on unix = dba on windows = administrators
#
# [*params*]
#   extra params for WLST script 
#
# === Variables
#
# === Examples
#  
# default parameters for the wlst scripts
#  Wls::Wlstexec {
#    wlHome       => '/opt/oracle/wls/wls12c/wlserver_12.1',
#    fullJDKName  => 'jdk1.7.0_07',	
#    user         => 'oracle',
#    group        => 'dba', 
#    address      => "localhost",
#    wlsUser      => "weblogic",
#    password     => "weblogic1",
#  }
#  
#  # start AdminServers for configuration of both domains myTestDomain
#  wls::wlstexec { 
#    'startAdminServer':
#     id          => 'unique1',
#     script      => 'startWlsServer.py',
#     port        => '5556',
#     params      =>  ["domain = 'myTestDomain'",
#                      "domainPath = '${osDomainPath}/myTestDomain'",
#                      "wlsServer = 'AdminServer'"],
#  }
# 

define wls::wlstexec ($wlHome      = undef, 
                      $fullJDKName = undef, 
                      $id          = undef,
                      $script      = undef,
                      $address     = "localhost",
                      $port        = '7001',
                      $wlsUser     = "weblogic",
                      $password    = "weblogic1",
                      $user        = 'oracle', 
                      $group       = 'dba',
                      $params      = undef,
                      ) {

   $javaCommand    = "java weblogic.WLST"

   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path             = '/install/'
        $JAVA_HOME        = "/usr/java/${fullJDKName}"

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

        Exec { path      => $execPath,
               logoutput => true,
             }
        File { ensure  => present,
               replace => 'yes',
               mode    => 0555,
             }     
     }
   }

    
   # the py script used by the wlst
   if ! defined(File["${path}${id}${script}"]) {
    file { "${path}${id}${script}":
      path    => "${path}${id}${script}",
      content => template("wls/${script}.erb"),
    }
   }
     
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        exec { "execwlst ${id}${script}":
          command     => "${javaCommand} ${path}${script}",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          require     => File["${path}${id}${script}"],
        }    
        if ! defined(Exec["rm ${path}${id}${script}"]) {
          exec { "rm ${path}${id}${script}":
           command => "rm -I ${path}${id}${script}",
           require => Exec["execwlst ${id}${script}"],
          }
        }

     }
     windows: { 

        exec { "execwlst ${id}${script}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommand} ${path}${script}",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          require     => File["${path}${id}${script}"],
        }    
        if ! defined(Exec["rm ${path}${id}${script}"]) {
          exec { "rm ${path}${id}${script}":
           command => "C:\\Windows\\System32\\cmd.exe /c delete ${path}${id}${script}",
           require => Exec["execwlst ${id}${script}"],
          }
        }
     }
   }


}
