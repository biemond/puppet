# == Define: wls::wlscontrol
#
# Weblogic Server control, starts or stops a managed server
#
#  action = start|stop
#
define wls::wlscontrol
( $wlHome         = undef,
  $fullJDKName    = undef,
  $wlsDomain      = undef,
  $wlsDomainPath  = undef,
  $wlsServer      = 'AdminServer',
  $address        = 'localhost',
  $port           = '7001',
  $action         = 'start',
  $wlsUser        = undef,
  $password       = undef,
  $user           = 'oracle',
  $group          = 'dba',
  $downloadDir    = '/install',
  $logOutput      = false,
) {

   $javaCommand = "java -Dweblogic.security.SSL.ignoreHostnameVerification=true weblogic.WLST -skipWLSModuleScanning "
   $path        = $downloadDir

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {
        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $JAVA_HOME        = "/usr/java/${fullJDKName}"
        $checkCommand     = "/bin/ps -ef | grep -v grep | /bin/grep 'weblogic.Name=${wlsServer}' | /bin/grep ${wlsDomain}"
     }
     Solaris: {
        $execPath         = "/usr/jdk/${fullJDKName}/bin/amd64:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $JAVA_HOME        = "/usr/jdk/${fullJDKName}"
        $checkCommand     = "/usr/ucb/ps wwxa | grep -v grep | /bin/grep 'weblogic.NodeManager'"
     }
     windows: {
        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $JAVA_HOME        = "c:\\oracle\\${fullJDKName}"
     }
   }

   if $action == 'start' {
      $script = 'startWlsServer2.py'
   } elsif $action == 'stop' {
      $script = 'stopWlsServer2.py'
   } else {
      fail("Unknow action")
   }

   # the py script used by the wlst
   file { "${path}/${title}${script}":
      path    => "${path}/${title}${script}",
      content => template("wls/wlst/${script}.erb"),
      ensure  => present,
      replace => 'yes',
      mode    => 0775,
      owner   => $user,
      group   => $group,
   }

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

       if $action == 'start' {
         exec { "execwlst ${title}${script} ":
          command     => "${javaCommand} ${path}/${title}${script} ${password}",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          unless      => $checkCommand,
          require     => File["${path}/${title}${script}"],
          path        => $execPath,
          user        => $user,
          group       => $group,
          logoutput   => $logOutput,
         }
       } elsif $action == 'stop' {
         exec { "execwlst ${title}${script} ":
          command     => "${javaCommand} ${path}/${title}${script} ${password}",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          onlyif      => $checkCommand,
          require     => File["${path}/${title}${script}"],
          path        => $execPath,
          user        => $user,
          group       => $group,
          logoutput   => $logOutput,
         }
       }
     }
     windows: {
        exec { "execwlst ${title}${script}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommand} ${path}/${title}${script} ${password}",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          require     => File["${path}/${title}${script}"],
          path        => $execPath,
          user        => $user,
          group       => $group,
          logoutput   => $logOutput,
        }
     }
   }
}
