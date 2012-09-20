# wlsdomain.pp 

define wls::wlsdomain ($wlHome          = undef, 
                       $fullJDKName     = undef,
                       $template        = "/common/templates/domains/wls.jar",
                       $domain          = undef,
                       $AdminServerName = "AdminServer",
                       $AdminListenAdr  = "localhost",
                       $AdminListenPort = 7001,
                       $wlsUser         = "weblogic",
                       $password        = "weblogic1",
                       $domainPath      = undef,
                       $user            = 'oracle',
                       $group           = 'dba',
                       ) {

   $javaCommand    = "java weblogic.WLST"

   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $execPath         = "/usr/java/${fullJDKName}$/bin:${otherPath}"
        $checkCommand     = '/bin/ls -l'
        $path             = '/install/'
        $JAVA_HOME        = "/usr/java/${fullJDKName}"
        $NodeMgrMachine   = "UnixMachine"
     
     }
     windows: { 

        $otherPath        = "C:\\Windows\\system32;C:\\Windows"
        $execPath         = "\"C:\\Program Files\\Java\\${fullJDKName}\\bin\";${otherPath}"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 
        $path             = "c:\\temp\\" 
        $JAVA_HOME        = "\"C:\\Program Files\\Java\\${fullJDKName}\""
        $NodeMgrMachine   = "Machine"

     }
   }

    
   # the domain.py used by the wlst
   file { "domain.py ${domain}":
     path    => "${path}domain_${domain}.py",
     ensure  => present,
     replace => 'yes',
     mode    => 0555,
     owner   => $user,
     group   => $group,
     content => template("wls/domain.xml.erb"),
   }
    
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
        
        exec { "execwlst ux domain":
          command     => "${javaCommand} ${path}domain_${domain}.py",
          path        => $execPath,
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/../dev/urandom"],
          logoutput   => true,
          user        => $user,
          group       => $group,
          unless      => "${checkCommand} ${domainPath}/${domain}",
          require => File["domain.py ${domain}"],
        }    
     
     }
     windows: { 

        exec { "execwlst win domain":
          command     => "${checkCommand} ${javaCommand} ${path}domain_${domain}.py",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          path        => $execPath,
          logoutput   => true,
          unless      => "${checkCommand} dir ${domainPath}\\${domain}",
          require => File["domain.py ${domain}"],
        }    
     }
   }
}
