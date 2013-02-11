# == Define: wls::wlsexec
#
# install weblogic on operating system called from installwls.pp  
#
#
# === Examples
#
#   # install weblogic
#   wls::wlsexec{ "installer ${version}":
#      mdwHome     => "/opt/oracle/wls/wls11g",
#      fullJDKName => "jdk1.7.0_09",
#      wlsfile     => "/install/wls1036_generic.jar",
#      silentfile  => "/install/silent1036.xml",
#      user        => "oracle",
#      group       => "dba",
#   }
# 

define wls::wlsexec ( $mdwHome     = undef, 
                      $fullJDKName = undef, 
                      $wlsfile     = undef, 
                      $silentfile  = undef,
                      $user        = undef,
                      $group       = undef, 
                       ) {

   $javaCommand     = "java -Xmx1024m -jar"

   # install weblogic
   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"

        exec { "installwls ${wlsfile}":
          command     => "${javaCommand} ${wlsfile} -mode=silent -silent_xml=${silentfile}",
          environment => ["JAVA_VENDOR=Sun",
                          "JAVA_HOME=/usr/java/${fullJDKName}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          path        => $execPath,
          logoutput   => true,
          user        => $user,
          group       => $group,
        }    
     
     }
     windows: { 

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\UnxUtils\\bin;C:\\UnxUtils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"

        exec { "installwls  ${wlsfile}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommand} ${wlsfile} -mode=silent -silent_xml=${silentfile}",
          environment => ["JAVA_VENDOR=Sun",
                          "JAVA_HOME=C:\\oracle\\${fullJDKName}"],
          path        => "${execPath}",
          logoutput   => true,
        }    
     }
   }
}
