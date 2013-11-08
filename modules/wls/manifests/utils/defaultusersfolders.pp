# == Define: wls::utils::defaultusersfolders
#
#  create users/ group , download folder and oracle home
#
#
##
define wls::utils::defaultusersfolders(
                       $oracleHome      = undef,
                       $oraInventory    = undef,
                       $createUser      = true,
                       $user            = 'oracle',
                       $group           = 'dba',
                       $downloadDir     = '/install',
                    ) {


		  case $operatingsystem {
		     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

		        $execPath           = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"

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

		        Exec { path      => $execPath,
		             }
		        File { ensure  => present,
		               mode    => 0777,
                   backup  => false,
		             }
		     }
		   }

       if ( $createUser ) {
			   # for linux , create a oracle user plus a dba group
			   case $operatingsystem {
			      CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {
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
			              comment    => 'created by Puppet',
			              require    => Group[$group],
			              managehome => true,
			          }
			        }
			     }
			      Solaris: {
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
			              home       => "/export/home/${user}",
			              comment    => 'created by Puppet',
			              require    => Group[$group],
			              managehome => true,
			          }
			        }
			     }
			   }
		   }
	   # create all folders
	   case $operatingsystem {
	      CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {
	        if ! defined(Exec ["create ${oracleHome} directory"]) {
	          exec { "create ${oracleHome} directory":
	                  command => "mkdir -p ${oracleHome}",
	                  unless  => "test -d ${oracleHome}",
	                  user    => 'root',
	          }
	        }
          if ! defined(Exec ["create ${downloadDir} home directory"]) {
	          exec { "create ${downloadDir} home directory":
	                  command => "mkdir -p ${downloadDir}",
	                  unless  => "test -d ${downloadDir}",
	                  user    => 'root',
	          }
          }
	      }
	      windows: {
	        # make dir folder suitable for unxtools
	        $oracleHomeWin  = slash_replace( $oracleHome )
	        $downloadDirWin = slash_replace( $downloadDir )
          if ! defined(Exec ["create ${oracleHome} directory"]) {
	          exec { "create ${oracleHome} directory":
	                  command => "${checkCommand} mkdir ${oracleHomeWin}",
	                  unless  => "${checkCommand} dir ${oracleHomeWin}",
	          }
	        }
          if ! defined(Exec ["create ${downloadDir} home directory"]) {
	          exec { "create ${downloadDir} home directory":
	                  command => "${checkCommand} mkdir ${downloadDirWin}",
	                  unless  => "${checkCommand} dir ${downloadDirWin}",
	          }
           }
	       }
	       default: {
	        fail("Unrecognized operating system")
	        }
	     }

		   if ( $createUser == true and $operatingsystem != "windows" ) {
				   # also set permissions on downloadDir
				   if ! defined(File[$downloadDir]) {
				      # check oracle install folder
				      file { $downloadDir :
				        ensure  => directory,
				        recurse => false,
				        replace => false,
				        require => [User[$user],Exec["create ${downloadDir} home directory"]],
				      }
				   }

				   # also set permissions on oracleHome
				   if ! defined(File[$oracleHome]) {
				     file { $oracleHome:
				       ensure  => directory,
				       recurse => false,
				       replace => false,
				       require => [User[$user],Exec["create ${oracleHome} directory"]],
				     }
				   }

		       if (  $oraInventory != undef ) {
		          # also set permissions on oraInventory
		          if ! defined(File[$oraInventory]) {
		            file { $oraInventory:
		              ensure  => directory,
		              recurse => false,
		              replace => false,
		              require => [User[$user],Exec["create ${oracleHome} directory"]],
		            }
		          }
		       }
		   } else {
		       # also set permissions on downloadDir
		       if ! defined(File[$downloadDir]) {
		          # check oracle install folder
		          file { $downloadDir :
		            ensure  => directory,
		            recurse => false,
		            replace => false,
		            require => Exec["create ${downloadDir} home directory"],
		          }
		       }

		       # also set permissions on oracleHome
		       if ! defined(File[$oracleHome]) {
		         file { $oracleHome:
		           ensure  => directory,
		           recurse => false,
		           replace => false,
		           require => Exec["create ${oracleHome} directory"],
		         }
		       }

		       if (  $oraInventory != undef ) {
		         case $operatingsystem {
		           CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {
		             # also set permissions on oraInventory
		             if ! defined(File[$oraInventory]) {
		               file { $oraInventory:
		                 ensure  => directory,
		                 recurse => false,
		                 replace => false,
		                 require => Exec["create ${oracleHome} directory"],
		               }
		             }
		          }
		         }
		       }
		   }
}
