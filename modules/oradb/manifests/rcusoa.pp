# == Class: oradb::rcusoa
#
#
#    oradb::rcusoa{ 'DEV3_PS5':
#                     rcuFile          => 'ofm_rcu_linux_11.1.1.6.0_disk1_1of1.zip',
#                     version          => '11.1.1.6', 
#                     oracleHome       => '/oracle/product/11.2/db',
#                     user             => 'oracle',
#                     group            => 'dba',
#                     downloadDir      => '/install/',
#                     action           => 'create',
#                     dbServer         => 'dbagent1.alfa.local:1521', 
#                     dbService        => 'test.oracle.com',
#                     sysPassword      => 'Welcome01',
#                     schemaPrefix     => 'DEV3',
#                     reposPassword    => 'Welcome02',
#                     require          => Oradb::Dbactions['start testDb'],
#    }
#
#
define oradb::rcusoa(    $rcuFile                 = undef,
                         $version                 = '11.1.1.6', 
                         $oracleHome              = undef,
                         $user                    = 'oracle',
                         $group                   = 'dba',
                         $downloadDir             = '/install/',
                         $action                  = 'create',
                         $dbServer                = undef,  
                         $dbService               = undef,
                         $sysPassword             = undef,
                         $schemaPrefix            = undef,
                         $reposPassword           = undef,
                         $puppetDownloadMntPoint  = undef, 
    ){


   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        $execPath        = "${oracleHome}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
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
             }        
     }
     default: { 
        fail("Unrecognized operating system") 
     }
   }

   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/oradb/"    	
   } else {
     $mountPoint =	$puppetDownloadMntPoint
   }


   # put check_rcu.sql 
   file { "${path}/rcu_${version}/rcu_checks_${title}.sql":
           ensure  => present,
           content => template("oradb/rcu_checks.sql.erb"),
   }
   notify { "sqlplus \"sys/${sysPassword}@//${connectString} as sysdba\" @${path}/rcu_${version}/rcu_checks_${title}.sql":}
   
   # run check.sql 
   exec { "run sqlplus to check for repos ${title}":
           command     => "sqlplus \"sys/${sysPassword}@//${dbServer}/${dbService} as sysdba\" @${path}/rcu_${version}/rcu_checks_${title}.sql",
           require     => File["${path}/rcu_${version}/rcu_checks_${title}.sql"],
           environment => ["ORACLE_HOME=${oracleHome}",
                           "LD_LIBRARY_PATH=${oracleHome}/lib"],
   }

   # put rcu software
   if ! defined(File["${path}${rcuFile}"]) {
    file { "${path}${rcuFile}":
     source  => "puppet:///modules/oradb/${rcuFile}",
    }
   }
 
   # unzip rcu software
   if ! defined(Exec["extract ${rcuFile}"]) {
     exec { "extract ${rcuFile}":
       command => "unzip ${path}${rcuFile} -d ${path}/rcu_${version}",
       require => File ["${path}${rcuFile}"],
       creates => "${path}/rcu_${version}",
     }
   }



   file { "${path}/rcu_${version}/rcu_passwords_${title}.txt":
           ensure  => present,
           require => Exec ["extract ${rcuFile}"],
           content => template("oradb/rcu_passwords.txt.erb"),
   }


   if $action == 'create' {
     exec { "install rcu soa repos ${title}":
            command     => "${path}/rcu_${version}/rcuHome/bin/rcu -silent -createRepository -databaseType ORACLE -connectString ${dbServer}:${dbService} -dbUser SYS -dbRole SYSDBA -schemaPrefix ${schemaPrefix} -component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -f < ${path}/rcu_${version}/rcu_passwords_${title}.txt",
            require     => [Exec["extract ${rcuFile}"],Exec["run sqlplus to check for repos ${title}"],File["${path}${rcuFile}"],File["${path}/rcu_${version}/rcu_passwords_${title}.txt"]],
            unless      => "/bin/grep -c found /tmp/check_rcu_${schemaPrefix}.txt",
     }
     exec { "install rcu soa repos ${title} 2":
            command     => "${path}/rcu_${version}/rcuHome/bin/rcu -silent -createRepository -databaseType ORACLE -connectString ${dbServer}:${dbService} -dbUser SYS -dbRole SYSDBA -schemaPrefix ${schemaPrefix} -component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -f < ${path}/rcu_${version}/rcu_passwords_${title}.txt",
            require     => [Exec["extract ${rcuFile}"],Exec["run sqlplus to check for repos ${title}"],File["${path}${rcuFile}"],File["${path}/rcu_${version}/rcu_passwords_${title}.txt"]],
            onlyif      => "/bin/grep -c ORA-00942 /tmp/check_rcu_${schemaPrefix}.txt",
     }

   } elsif $action == 'delete' {
     exec { "delete rcu soa repos ${title}":
            command     => "${path}/rcu_${version}/rcuHome/bin/rcu -silent -dropRepository -databaseType ORACLE -connectString ${dbServer}:${dbService} -dbUser SYS -dbRole SYSDBA -schemaPrefix ${schemaPrefix} -component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -f < ${path}/rcu_${version}/rcu_passwords_${title}.txt",
            require     => [Exec["extract ${rcuFile}"],Exec["run sqlplus to check for repos ${title}"],File["${path}${rcuFile}"],File["${path}/rcu_${version}/rcu_passwords_${title}.txt"]],
            onlyif      => "/bin/grep -c found /tmp/check_rcu_${schemaPrefix}.txt",
     }
     exec { "delete rcu soa repos ${title} 2":
            command     => "${path}/rcu_${version}/rcuHome/bin/rcu -silent -dropRepository -databaseType ORACLE -connectString ${dbServer}:${dbService} -dbUser SYS -dbRole SYSDBA -schemaPrefix ${schemaPrefix} -component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -f < ${path}/rcu_${version}/rcu_passwords_${title}.txt",
            require     => [Exec["extract ${rcuFile}"],Exec["run sqlplus to check for repos ${title}"],File["${path}${rcuFile}"],File["${path}/rcu_${version}/rcu_passwords_${title}.txt"]],
            unless      => "/bin/grep -c ORA-00942 /tmp/check_rcu_${schemaPrefix}.txt",
     }

   } 
  
}    