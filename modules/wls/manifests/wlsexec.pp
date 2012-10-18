# == Define: wls::wlsexec
#
# install weblogic on operating system   
#
# === Parameters
#
# [*mdwHome*]
#   the middleware home path /opt/oracle/wls/wls12c
#
# [*checkPath*]
#   the middleware home path for test -f
#
#
# [*fullJDKName*]
#   jdk path jdk1.7.0_07 this maps to /usr/java/.. or c:\program files\
#
# [*wlsfile*]
#   the generic weblogic jar like  wls1211_generic.jar
#
# [*silentfile*]
#   the xml with beahome
#
# === Variables
#
# === Examples
#
#  wls::wlsexec{'domain':
#    mdwHome      => '/opt/oracle/wls/wls12c/wlserver_12.1',
#    checkPath    => '/opt/oracle/wls/wls12c',
#    fullJDKName  => 'jdk1.7.0_07',	
#    wlsfile      => '/install/wls1211_generic.jar',
#    silentfile   => '/install/silent.xml', 
#  }
# 

define wls::wlsexec ( $mdwHome     = undef, 
                      $checkPath   = undef, 
                      $fullJDKName = undef, 
                      $wlsfile     = undef, 
                      $silentfile  = undef,
                      $user        = undef,
                      $group       = undef,  ) {

   $javaCommand     = "java -Xmx1024m -jar"

   # install weblogic
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"

        exec { "installwls ${wlsfile}":
          command     => "${javaCommand} ${wlsfile} -mode=silent -silent_xml=${silentfile}",
          environment => ["JAVA_VENDOR=Sun",
                          "JAVA_HOME=/usr/java/${fullJDKName}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          path        => $execPath,
          logoutput   => true,
#         unless      => "/usr/bin/test -e ${checkPath}",
          creates     => "${checkPath}",
          user        => $user,
          group       => $group,
          tries       => 2,
          try_sleep   => 5,
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
          creates     => "${checkPath}",
#          unless      => "C:\\Windows\\System32\\cmd.exe /c test -e ${checkPath}",
          tries       => 2,
          try_sleep   => 5,
        }    
     }
   }
}
