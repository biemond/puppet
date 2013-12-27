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
                        $sshpass         = true,
                        $user            = 'oracle',
                        $userPassword    = 'oracle',
                        $group           = 'dba',
                        $logDir          = undef, 
                        $downloadDir     = '/install',
                       ) {


   if $::override_weblogic_domain_folder == undef {
     $domainPath = "${mdwHome}/user_projects/domains"
     $appPath    = "${mdwHome}/user_projects/applications"
   } else {
     $domainPath = "${::override_weblogic_domain_folder}/domains"
     $appPath    = "${::override_weblogic_domain_folder}/applications"
   }

   if $version == "1111" {
     $nodeMgrHome = "${wlHome}/common/nodemanager"

   } elsif $version == "1212" {
     if $::override_weblogic_domain_folder == undef {
       $nodeMgrHome = "${wlHome}/../user_projects/domains/${domain}/nodemanager"
     } else {
       $nodeMgrHome = "${::override_weblogic_domain_folder}/domains/${domain}/nodemanager"
     }

   } else {
     $nodeMgrHome = "${wlHome}/common/nodemanager"
   }


   # check if the domain already exists
   $found = domain_exists("${domainPath}/${domain}",$version,$domainPath)
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

    if $logDir != undef {

      # create all log folders
      if !defined(Exec["create ${logDir} directory"]) {
        exec { "create ${logDir} directory":
          command => "mkdir -p ${logDir}",
          unless  => "test -d ${logDir}",
          user    => 'root',
          path    => $execPath,
        }
      }
      if !defined(File[$logDir]) {
        file { $logDir:
          ensure  => directory,
          recurse => false,
          replace => false,
          require => Exec["create ${logDir} directory"],
          mode    => 0775,
          owner   => $user,
          group   => $group,
        }
      }
    }

    if $::override_weblogic_domain_folder == undef {
      # make the default domain folders
      if !defined(File["weblogic_domain_folder"]) {
        # check oracle install folder
        file { "weblogic_domain_folder":
          path    => "${mdwHome}/user_projects",
          ensure  => directory,
          recurse => false,
          replace => false,
        }
      }
    } else {
      # make override domain folders

      if !defined(File["weblogic_domain_folder"]) {
        # check oracle install folder
        file { "weblogic_domain_folder":
          path    => $::override_weblogic_domain_folder,
          ensure  => directory,
          recurse => false,
          replace => false,
        }
      }
    }


    if !defined(File[$domainPath]) {
      # check oracle install folder
      file { $domainPath:
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => 0775,
        require => File["weblogic_domain_folder"],
      }
    }

    if !defined(File[$appPath]) {
      # check oracle install folder
      file { $appPath:
        ensure  => directory,
        recurse => false,
        replace => false,
        require => File["weblogic_domain_folder"],
      }
    }

    if ( $sshpass == false ) {
      exec { "copy domain jar ${domain}":
        command => "scp -oStrictHostKeyChecking=no -oCheckHostIP=no ${user}@${adminListenAdr}:${path}/domain_${domain}.jar ${path}/domain_${domain}.jar",
      }
    } else {
      exec { "copy domain jar ${domain}":
        command => "sshpass -p ${userPassword} scp -oStrictHostKeyChecking=no -oCheckHostIP=no ${user}@${adminListenAdr}:${path}/domain_${domain}.jar ${path}/domain_${domain}.jar",
      }
    }
     $unPackCommand = "-domain=${domainPath}/${domain} -template=${path}/domain_${domain}.jar -app_dir=${appPath} -log=${path}/domain_${domain}.log -log_priority=INFO"

     exec { "unpack ${domain}":
        command => "${wlHome}/common/bin/unpack.sh ${unPackCommand} -user_name=${wlsUser} -password=${password}",
        require => [File[$domainPath],
                    Exec[ "copy domain jar ${domain}"]],
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
            require     => [File["${path}/enroll_domain_${domain}.py"],
                            Exec["unpack ${domain}"]],
          }

          case $operatingsystem {
             CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {
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
