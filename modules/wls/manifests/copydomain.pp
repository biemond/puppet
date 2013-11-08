# == Define: wls::copydomain
#
#   copydomain to an other node
##
#

define wls::copydomain ($version         = '1111',
                        $wlHome          = undef,
                        $mdwHome         = undef,
                        $fullJDKName     = undef,
                        $domain          = undef,
                        $adminListenAdr  = "localhost",
                        $adminListenPort = '7001',
                        $wlsUser         = undef,
                        $password        = undef,
                        $user            = 'oracle',
                        $userPassword    = 'oracle',
                        $group           = 'dba',
                        $downloadDir     = '/install',
                       ) {

   $domainPath  = "${mdwHome}/user_projects/domains"
   $appPath     = "${mdwHome}/user_projects/applications"

   if $version == "1111" {
     $nodeMgrHome = "${wlHome}/common/nodemanager"

   } elsif $version == "1212" {
     $nodeMgrHome = "${wlHome}/../user_projects/domains/${domain}/nodemanager"

   } else {
     $nodeMgrHome = "${wlHome}/common/nodemanager"
   }


   # check if the domain already exists
   $found = domain_exists("${domainPath}/${domain}",$version)
   if $found == undef {
     $continue = true
   } else {
     if ( $found ) {
       $continue = false
     } else {
       notify {"wls::wlsdomain ${title} ${domainPath}/${domain} ${version} does not exists":}
       $continue = true
     }
   }

   if ( $continue ) {

	   case $operatingsystem {
	     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

	        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"
	        $path             = $downloadDir
	        $JAVA_HOME        = "/usr/java/${fullJDKName}"

	        Exec { path      => $execPath,
	               user      => $user,
	               group     => $group,
	               logoutput => true,
	             }
	        File {
	               ensure  => present,
	               replace => true,
	               mode    => 0775,
	               owner   => $user,
	               group   => $group,
                 backup  => false,
	             }
	     }
	     Solaris: {

	        $execPath         = "/usr/jdk/${fullJDKName}/bin/amd64:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"
	        $path             = $downloadDir
	        $JAVA_HOME        = "/usr/jdk/${fullJDKName}"

	        Exec { path      => $execPath,
	               user      => $user,
	               group     => $group,
	               logoutput => true,
	             }
	        File {
	               ensure  => present,
	               replace => true,
	               mode    => 0775,
	               owner   => $user,
	               group   => $group,
                 backup  => false,
	             }

	     }
	   }

	   # make the default domain folders
	   if ! defined(File["${mdwHome}/user_projects"]) {
	      # check oracle install folder
	      file { "${mdwHome}/user_projects" :
	        ensure  => directory,
	        recurse => false,
	        replace => false,
	      }
	   }

	   if ! defined(File["${mdwHome}/user_projects/domains"]) {
	      # check oracle install folder
	      file { "${mdwHome}/user_projects/domains" :
	        ensure  => directory,
	        recurse => false,
	        replace => false,
	        require => File["${mdwHome}/user_projects"],
	      }
	   }

	   if ! defined(File["${mdwHome}/user_projects/applications"]) {
	      # check oracle install folder
	      file { "${mdwHome}/user_projects/applications" :
	        ensure  => directory,
	        recurse => false,
	        replace => false,
	        require => File["${mdwHome}/user_projects"],
	      }
	   }

     exec { "copy domain jar ${domain}":
        command => "sshpass -p ${userPassword} scp -oStrictHostKeyChecking=no -oCheckHostIP=no ${user}@${adminListenAdr}:${path}/domain_${domain}.jar ${path}/domain_${domain}.jar",
     }

     $unPackCommand    = "-domain=${domainPath}/${domain} -template=${path}/domain_${domain}.jar -app_dir=${appPath} -log=${path}/domain_${domain}.log -log_priority=INFO"

     exec { "unpack ${domain}":
        command => "${wlHome}/common/bin/unpack.sh ${unPackCommand} -user_name=${wlsUser} -password=${password}",
        require => [File["${mdwHome}/user_projects/domains"],Exec[ "copy domain jar ${domain}"]],
     }



     # the enroll domain.py used by the wlst
     file { "enroll.py ${domain} ${title}":
       path    => "${path}/enroll_domain_${domain}.py",
       content => template("wls/wlst/enrollDomain.py.erb"),
     }

	   case $operatingsystem {
	       CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

	        exec { "execwlst ${domain} ${title}":
	          command     => "${wlHome}/common/bin/wlst.sh ${path}/enroll_domain_${domain}.py",
	          environment => ["JAVA_HOME=${JAVA_HOME}"],
	          require     => [File["${path}/enroll_domain_${domain}.py"],Exec["unpack ${domain}"]],
	        }

	        case $operatingsystem {
	           CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {
	              exec { "domain.py ${domain} ${title}":
	                command     => "rm -I ${path}/enroll_domain_${domain}.py",
	                require     => Exec["execwlst ${domain} ${title}"],
	              }
	           }
	           Solaris: {
	             exec { "domain.py ${domain} ${title}":
	                command     => "rm ${path}/enroll_domain_${domain}.py",
	                require     => Exec["execwlst ${domain} ${title}"],
	             }
	           }
	        }
	     }
	   }

   }
}
