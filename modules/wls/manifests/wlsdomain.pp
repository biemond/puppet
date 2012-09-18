# wlsdomain.pp 

define wls::wlsdomain ($wlHome          = undef, 
                       $fullJDKName     = undef, 
                       $domain          = undef,
                       $AdminServerName = "AdminServer",
                       $AdminListenAdr  = "localhost",
                       $AdminListenPort = 7001,
                       $user            = "weblogic",
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
     
     }
     windows: { 

        $otherPath        = "C:\\Windows\\system32;C:\\Windows"
        $execPath         = "\"C:\\Program Files\\Java\\${fullJDKName}\\bin\";${otherPath}"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 
        $path             = "c:\\temp\\" 
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
        
        exec { "execwlst ux":
          command     => "${javaCommand} ${path}domain_${domain}.py",
          path        => $execPath,
          environment => "CLASSPATH=${wlHome}/server/lib/weblogic.jar",
          logoutput   => true,
          user        => $user,
          group       => $group,
          unless      => "${checkCommand} ${domainPath}/${domain}",
          require => File["domain.py ${domain}"],
        }    
     
     }
     windows: { 

        exec { "execwlst ux":
          command     => "${checkCommand} ${javaCommand} ${path}domain_${domain}.py",
          environment => "CLASSPATH=${wlHome}/server/lib/weblogic.jar",
          path        => $execPath,
          logoutput   => true,
          unless      => "${checkCommand} dir ${domainPath}\\${domain}",
          require => File["domain.py ${domain}"],
        }    
     }
   }
}
