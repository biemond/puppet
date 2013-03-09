# == Class: oradb::installdb
#
# The databaseType value should contain only one of these choices.        
# EE     : Enterprise Edition                                
# SE     : Standard Edition                                  
# SEONE  : Standard Edition One
#
#    class { 'oradb::installdb':
#            file         => 'p10404530_112030_Linux-x86-64',
#            databaseType => 'SE',
#            oracleBase   => '/oracle',
#            oracleHome   => '/oracle/product/11.2/db',
#            user         => 'oracle',
#            group        => 'dba',
#            downloadDir  => '/install/',  
#         }
#
#
#

class oradb::installdb( $file         = 'p10404530_112030_Linux-x86-64',
												$databaseType = 'SE',
                        $oracleBase   = undef,
                        $oracleHome   = undef,
                        $user         = 'oracle',
                        $group        = 'dba',
                        $downloadDir  = '/install/',
    
    )
  
  {

  notify {"oradb installdb.pp":}


  # check if the oracle software already exists
  $found = oracle_exists( $oracleHome )
  if $found == undef {
       $continue = true
  } else {
       if ( $found ) {
         notify {"wls::installdb ${oracleHome} already exists":}
         $continue = false
       } else {
         notify {"wls::installdb ${oracleHome} does not exists":}
         $continue = true 
       }
  }

if ( $continue ) {

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        $execPath        = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir
        $oraInstPath     = "/etc/"
        $oraInventory    = "${oracleBase}/oraInventory"
        
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

   if ! defined(Group[$group]) {
      group { $group : 
              ensure => present,
      }
   }

   if ! defined(User[$user]) {
      # http://raftaman.net/?p=1311 for generating password
      user { $user : 
              ensure     => present, 
              groups     => $group,
              shell      => '/bin/bash',
              password   => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',  
              home       => "/home/${user}",
              comment    => 'This user ${user} was created by Puppet',
              require    => Group[$group],
              managehome => true, 
       }
   }


   if ! defined(File[$path]) {
      # check oracle install folder
      file { $path :
        path    => $path,
        ensure  => directory,
        recurse => false, 
        replace => false,
      }
   }



   # db file 1 installer zip
   file { "${path}${file}_1of7.zip":
     source  => "puppet:///modules/oradb/${file}_1of7.zip",
     require => File[$path],
   }


   exec { "extract ${path}${file}_1of7.zip":
      command => "unzip ${path}${file}_1of7.zip -d ${path}${file}",
      require => File["${path}${file}_1of7.zip"],
   }
       

   # db file 2 installer zip
   file { "${path}${file}_2of7.zip":
     source  => "puppet:///modules/oradb/${file}_2of7.zip",
     require => File["${path}${file}_1of7.zip"],
   }

   exec { "extract ${path}${file}_2of7.zip":
      command => "unzip ${path}${file}_2of7.zip -d ${path}${file}",
      require => File["${path}${file}_2of7.zip"],
   }
       

   # db file 3 installer zip
   file { "${path}${file}_3of7.zip":
     source  => "puppet:///modules/oradb/${file}_3of7.zip",
     require => File["${path}${file}_2of7.zip"],
   }

   exec { "extract ${path}${file}_3of7.zip":
      command => "unzip ${path}${file}_3of7.zip -d ${path}${file}",
      require => File["${path}${file}_3of7.zip"],
   }
       


   # db file 4 installer zip
   file { "${path}${file}_4of7.zip":
     source  => "puppet:///modules/oradb/${file}_4of7.zip",
     require => File["${path}${file}_3of7.zip"],
   }

   exec { "extract ${path}${file}_4of7.zip":
      command => "unzip ${path}${file}_4of7.zip -d ${path}${file}",
      require => File["${path}${file}_4of7.zip"],
   }
       

   # db file 5 installer zip
   file { "${path}${file}_5of7.zip":
     source  => "puppet:///modules/oradb/${file}_5of7.zip",
     require => File["${path}${file}_4of7.zip"],
   }

   exec { "extract ${path}${file}_5of7.zip":
      command => "unzip ${path}${file}_5of7.zip -d ${path}${file}",
      require => File["${path}${file}_5of7.zip"],
   }
       


   # db file 6 installer zip
   file { "${path}${file}_6of7.zip":
     source  => "puppet:///modules/oradb/${file}_6of7.zip",
     require => File["${path}${file}_5of7.zip"],
   }

   exec { "extract ${path}${file}_6of7.zip":
      command => "unzip ${path}${file}_6of7.zip -d ${path}${file}",
      require => File["${path}${file}_6of7.zip"],
   }
       

   # db file 7 installer zip
   file { "${path}${file}_7of7.zip":
     source  => "puppet:///modules/oradb/${file}_7of7.zip",
     require => File["${path}${file}_6of7.zip"],
   }
                                   
   exec { "extract ${path}${file}_7of7.zip":
      command => "unzip ${path}${file}_7of7.zip -d ${path}${file}",
      require => File["${path}${file}_7of7.zip"],
   }


   if ! defined(File["${oraInstPath}/oraInst.loc"]) {
     file { "${oraInstPath}/oraInst.loc":
            ensure  => present,
            content => template("oradb/oraInst.loc.erb"),
          }
   }


   if ! defined(File[$oracleBase]) {
      # check oracle base folder
      file { $oracleBase :
        ensure  => directory,
        recurse => false, 
        replace => false,
      }
   }

   if ! defined(File["${path}db_install.rsp"]) {
     file { "${path}db_install.rsp":
            ensure  => present,
            content => template("oradb/db_install.rsp.erb"),
            require => File["${oraInstPath}/oraInst.loc"],
          }
   }

        
   exec { "install oracle database":
          command     => "${path}${file}/database/runInstaller -silent -responseFile ${path}db_install.rsp",
          require     => [File ["${oraInstPath}/oraInst.loc"],File["${path}db_install.rsp"],Exec["extract ${path}${file}_7of7.zip"]],
          creates     => $oracleHome,
   } 

   if ! defined(File["/home/${user}/.bash_profile"]) {
     file { "/home/${user}/.bash_profile":
            ensure  => present,
            content => template("oradb/bash_profile.erb"),
            require => Exec["install oracle database"],
          }
   }


   exec { "sleep 4 min for oracle db install":
          command     => "/bin/sleep 240",
          require     => [Exec ["install oracle database"],File["/home/${user}/.bash_profile"]],
   }    

}

}


