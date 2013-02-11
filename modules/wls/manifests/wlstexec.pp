# == Define: wls::wlstexec
#
# generic wlst script  
#
#
# === Examples
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
#  # default parameters for the wlst scripts
#  Wls::Wlstexec {
#    wlsDomain    => "${osDomainPath}/osbDomain",
#    wlHome       => $osWlHome,
#    fullJDKName  => $jdkWls11gJDK,	
#    user         => $user,
#    group        => $group,
#    address      => "localhost",
#    wlsUser      => "weblogic",
#    password     => "weblogic1",
#    port         => "7001",
#  }
#
#  # create jdbc datasource for osb_server1 
#  wls::wlstexec { 
#  
#    'createJdbcDatasourceHr':
#     wlstype       => "jdbc",
#     wlsObjectName => "hrDS",
#     script        => 'createJdbcDatasource.py',
#     params        => ["dsName                      = 'hrDS'",
#                      "jdbcDatasourceTargets       = 'AdminServer,osb_server1'",
#                      "dsJNDIName                  = 'jdbc/hrDS'",
#                      "dsDriverName                = 'oracle.jdbc.xa.client.OracleXADataSource'",
#                      "dsURL                       = 'jdbc:oracle:thin:@master.alfa.local:1521/XE'",
#                      "dsUserName                  = 'hr'",
#                      "dsPassword                  = 'hr'",
#                      "datasourceTargetType        = 'Server'",
#                      "globalTransactionsProtocol  = 'xxxx'"
#                      ],
#  }
#
# 

define wls::wlstexec ($wlsDomain     = undef, 
                      $wlstype       = undef,
                      $wlsObjectName = undef,
                      $wlHome        = undef, 
                      $fullJDKName   = undef, 
                      $script        = undef,
                      $address       = "localhost",
                      $port          = '7001',
                      $wlsUser       = "weblogic",
                      $password      = "weblogic1",
                      $user          = 'oracle', 
                      $group         = 'dba',
                      $params        = undef,
                      $downloadDir   = '/install/',
                      ) {

   notify {"wls::wlstexec ${title} execute ${wlsDomain}":}

 
   # if these params are empty always continue    
   if $wlsDomain == undef or $wlstype == undef or wlsObjectName == undef {

     $continue = true  
   } else {
     # check if the object already exists on the weblogic domain 
     $found = artifact_exists($wlsDomain ,$wlstype,$wlsObjectName )
     if $found == undef {
       $continue = true
         notify {"wls::wlstexec ${title} continue true cause nill":}
     } else {
       if ( $found ) {
         notify {"wls::wlstexec ${title} continue false cause already exists":}
         $continue = false
       } else {
         notify {"wls::wlstexec ${title} continue true cause not exists":}
         $continue = true 
       }
     }
   }


if ( $continue ) {
   $javaCommand    = "java -Dweblogic.security.SSL.ignoreHostnameVerification=true weblogic.WLST -skipWLSModuleScanning "

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path             = $downloadDir
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
        $path             = $downloadDir 

        $JAVA_HOME        = "c:\\oracle\\${fullJDKName}"

        Exec { path      => $execPath,
               logoutput => true,
             }
        File { ensure  => present,
               replace => 'yes',
               mode    => 0777,
             }     
     }
   }

    
   # the py script used by the wlst
   file { "${path}${title}${script}":
      path    => "${path}${title}${script}",
      content => template("wls/wlst/${script}.erb"),
   }
     
   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        exec { "execwlst ${title}${script}":
          command     => "${javaCommand} ${path}${title}${script}",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          require     => File["${path}${title}${script}"],
        }    

        exec { "rm ${path}${title}${script}":
           command => "rm -I ${path}${title}${script}",
           require => Exec["execwlst ${title}${script}"],
        }

     }
     windows: { 

        exec { "execwlst ${title}${script}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommand} ${path}${title}${script}",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          require     => File["${path}${title}${script}"],
        }    


        exec { "rm ${path}${title}${script}":
           command => "C:\\Windows\\System32\\cmd.exe /c del ${path}${title}${script}",
           require => Exec["execwlst ${title}${script}"],
        }
     }
   }



}
}
