# wlsexec 

define wlsexec ($mdwHome = undef, $fullJDKName = undef, $wlsfile = undef, $silentfile = undef  ) {

   $javaCommand     = "java -Xmx1024m -jar"

   # install weblogic
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $execPath         = "/usr/java/${fullJDKName}$/bin:${otherPath}"
        $checkCommand     = '/bin/ls -l'
    
        exec { "installwls ${wlsfile}":
          command     => "${javaCommand} ${wlsfile} -mode=silent -silent_xml=${silentfile}",
          environment => ["JAVA_VENDOR=Sun",
                          "JAVA_HOME=/usr/java/${fullJDKName}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/../dev/urandom"],
          path        => $execPath,
          logoutput   => true,
          unless      => "${checkCommand} ${mdwHome}",
          user        => $user,
          group       => $group
        }    
     
     }
     windows: { 

        $otherPath        = "C:\\Windows\\system32;C:\\Windows"
        $execPath         = "\"C:\\Program Files\\Java\\${fullJDKName}\\bin\";${otherPath}"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 

        exec { "installwls  ${wlsfile}":
          command     => "${checkCommand} ${javaCommand} ${wlsfile} -mode=silent -silent_xml=${silentfile}",
          environment => ["JAVA_VENDOR=Sun",
                          "JAVA_HOME=\"C:\\Program Files\\Java\\${fullJDKName}\""],
          path        => $execPath,
          logoutput   => true,
          unless      => "${checkCommand} dir ${mdwHome}",
        }    
     }
   }
}
