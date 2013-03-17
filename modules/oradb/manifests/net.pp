# == Class: oradb::net
#
#
#
#
#

define oradb::net(       $oracleHome   = undef,
                         $user         = 'oracle',
                         $group        = 'dba',
                         $downloadDir  = '/install/',){


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

   if ! defined(File["${path}netca_11.2.rsp"]) {
     file { "${path}netca_11.2.rsp":
            ensure  => present,
            content => template("oradb/netca_11.2.rsp.erb"),
          }
   }

   exec { "install oracle net ${title}":
            command     => "netca /silent /responsefile ${path}netca_11.2.rsp",
            require     => File["${path}netca_11.2.rsp"],
            creates     => "${oracleHome}/network/admin/listener.ora",
   } 


}


