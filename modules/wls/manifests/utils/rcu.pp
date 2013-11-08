# == Class: wls::utils::rcu
#    rcu for adf 12.1.2
#
#    wls::utils::rcu{ 'DEV3_12c':
#                     product          => 'adf',
#                     oracleHome       => '/oracle/product/11.2/db',
#                     user             => 'oracle',
#                     group            => 'dba',
#                     downloadDir      => '/install',
#                     action           => 'create',
#                     dbUrl            => 'dbagent2.alfa.local:1521/test.oracle.com',
#                     sysPassword      => 'Welcome01',
#                     schemaPrefix     => 'DEV',
#                     reposPassword    => 'Welcome02',
#    }
#
#
define wls::utils::rcu(  $product                 = 'adf',
                         $oracleHome              = undef,
                         $fullJDKName             = undef,
                         $user                    = 'oracle',
                         $group                   = 'dba',
                         $downloadDir             = '/install',
                         $action                  = 'create',
                         $dbUrl                   = undef,
                         $sysPassword             = undef,
                         $schemaPrefix            = undef,
                         $reposPassword           = undef,
    ){


   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

        $execPath        = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir

        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
        File {
               ensure  => present,
               mode    => 0775,
               owner   => $user,
               group   => $group,
               backup  => false,
             }
     }
     windows: {

        $execPath         = "C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c"
        $path             = $downloadDir


        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0777,
               backup  => false,
             }
     }
     default: {
        fail("Unrecognized operating system")
     }
   }

   if $product == 'adf' {
      $components = '-component MDS -component IAU -component IAU_APPEND -component IAU_VIEWER -component OPSS -component WLS -component UCSCC  '
      $componentsPasswords = [$reposPassword, $reposPassword, $reposPassword,$reposPassword,$reposPassword,$reposPassword,$reposPassword]
   } else {
      fail("Unrecognized FMW product")
   }

   file { "${path}/rcu_passwords_${product}_${action}.txt":
           ensure  => present,
           content => template("wls/utils/rcu_passwords.txt.erb"),
   }

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {
       $script   = "${oracleHome}/bin/rcu"
       $javaHome = "/usr/java/${fullJDKName}"

     }
     Solaris: {
       $javaHome = "/usr/jdk/${fullJDKName}"
     }
     windows: {
       $script = "${checkCommand} ${oracleHome}/bin/rcu.bat"
       $javaHome = "C:\\oracle\\${fullJDKName}"
     }
   }

   if $action == 'create' {
     exec { "install rcu repos ${title}":
            command     => "${script} -silent -createRepository -databaseType ORACLE -connectString ${dbUrl} -dbUser SYS -dbRole SYSDBA -schemaPrefix ${schemaPrefix} ${components} -f < ${path}/rcu_passwords_${product}_${action}.txt",
            require     => File["${path}/rcu_passwords_${product}_${action}.txt"],
            environment => ["JAVA_HOME=${javaHome}","LANG='en_US.UTF8'","LC_ALL='en_US.UTF8'","NLS_LANG='american_america'"],
     }

   } elsif $action == 'delete' {
     exec { "delete rcu repos ${title}":
            command     => "${script} -silent -dropRepository -databaseType ORACLE -connectString ${dbUrl} -dbUser SYS -dbRole SYSDBA -schemaPrefix ${schemaPrefix} ${components} -f < ${path}/rcu_passwords_${product}_${action}.txt",
            require     => File["${path}/rcu_passwords_${product}_${action}.txt"],
            environment => ["JAVA_HOME=${javaHome}"],
     }
   }

}
