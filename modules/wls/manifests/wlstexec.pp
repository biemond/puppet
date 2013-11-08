# == Define: wls::wlstexec
#
# generic wlst script
#
# pass on the weblogic username or password
# or provide userConfigFile and userKeyFile file locations
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
#    port         => "5556",
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
define wls::wlstexec ($version        = '1111',
                      $wlsDomain      = undef,
                      $wlstype        = undef,
                      $wlsObjectName  = undef,
                      $wlHome         = undef,
                      $fullJDKName    = undef,
                      $script         = undef,
                      $address        = "localhost",
                      $port           = '7001',
                      $wlsUser        = undef,
                      $password       = undef,
                      $userConfigFile = undef,
                      $userKeyFile    = undef,
                      $user           = 'oracle',
                      $group          = 'dba',
                      $params         = undef,
                      $downloadDir    = '/install',
                      $logOutput      = false,
                      ) {

   # if these params are empty always continue
   if $wlsDomain == undef or $wlstype == undef or $wlsObjectName == undef {
     $continue = true
   } else {
     # check if the object already exists on the weblogic domain
     $found = artifact_exists($wlsDomain ,$wlstype,$wlsObjectName ,$version)
     if $found == undef {
       $continue = true
         notify {"wls::wlstexec ${title} ${version} continue true cause nill":}
     } else {
       if ( $found ) {
         $continue = false
       } else {
         notify {"wls::wlstexec ${title} ${version} continue true cause not exists":}
         $continue = true
       }
     }
   }

   # use userConfigStore for the connect
	 if $password == undef {
     $useStoreConfig = true
   } else {
     $useStoreConfig = false
   }


if ( $continue ) {
   $javaCommand    = "java -Dweblogic.security.SSL.ignoreHostnameVerification=true weblogic.WLST -skipWLSModuleScanning "

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path             = $downloadDir
        $JAVA_HOME        = "/usr/java/${fullJDKName}"

        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => $logOutput,
             }
        File {
               ensure  => present,
               replace => true,
               mode    => 0555,
               owner   => $user,
               group   => $group,
               backup  => false,
             }
     }
     Solaris: {

        $execPath         = "/usr/jdk/${fullJDKName}/bin/amd64:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path             = $downloadDir
        $JAVA_HOME        = "/usr/jdk/${fullJDKName}"

        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => $logOutput,
             }
        File {
               ensure  => present,
               replace => true,
               mode    => 0775,
               owner   => $user,
               group   => $group,
               backup  => false,
             }

     }
     windows: {

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $path             = $downloadDir

        $JAVA_HOME        = "c:\\oracle\\${fullJDKName}"

        Exec { path      => $execPath,
               logoutput => $logOutput,
             }
        File { ensure  => present,
               replace => true,
               mode    => 0777,
               backup  => false,
             }
     }
   }


   # the py script used by the wlst
   file { "${path}/${title}${script}":
      path    => "${path}/${title}${script}",
      content => template("wls/wlst/${script}.erb"),
   }

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

        exec { "execwlst ${title}${script}":
          command     => "${javaCommand} ${path}/${title}${script}",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          require     => File["${path}/${title}${script}"],
        }

        case $operatingsystem {
           CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {
              exec { "rm ${path}/${title}${script}":
                 command => "rm -I ${path}/${title}${script}",
                 require => Exec["execwlst ${title}${script}"],
              }
           }
           Solaris: {
              exec { "rm ${path}/${title}${script}":
                 command => "rm ${path}/${title}${script}",
                 require => Exec["execwlst ${title}${script}"],
              }
           }
        }

     }
     windows: {

        exec { "execwlst ${title}${script}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommand} ${path}/${title}${script}",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          require     => File["${path}/${title}${script}"],
        }

        exec { "rm ${path}/${title}${script}":
           command => "C:\\Windows\\System32\\cmd.exe /c rm ${path}/${title}${script}",
           require => Exec["execwlst ${title}${script}"],
        }
     }
   }

}
}
