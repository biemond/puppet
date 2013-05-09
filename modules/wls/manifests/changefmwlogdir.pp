# == Define: wls::changefmwlogdir
#
# generic changefmwlogdir wlst script  
#
#
# === Examples
#  
#  # set the defaults
#
#  Wls::Changefmwlogdir {
#    mdwHome      => $osMdwHome,
#    user         => 'oracle',
#    group        => 'dba',    
#  }
#
#  wls::changefmwlogdir{
#   'adminServer':
#    address      => "localhost",
#    wlsUser      => "weblogic",
#    password     => "weblogic1",
#    port         => "7001",
#    wlsServer    => "AdminServer",
#    logDir       => "/data/logs",
#    downloadDir  => "/install/",
#  }
#
#
# 

define wls::changefmwlogdir ($mdwHome       = undef, 
                             $address       = "localhost",
                             $port          = '7001',
                             $wlsUser       = "weblogic",
                             $password      = "weblogic1",
                             $user          = 'oracle', 
                             $group         = 'dba',
                             $wlsServer     = undef,
                             $logDir        = undef,
                             $downloadDir   = '/install/',
                            ) {


   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        $execPath         = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path             = $downloadDir

        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
        File {
               ensure  => present,
               replace => 'yes',
               mode    => 0555,
               owner   => $user,
               group   => $group,
             }     
     }
     windows: { 

        $execPath         = "C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $path             = $downloadDir 


        Exec { path      => $execPath,
               logoutput => true,
             }
        File { ensure  => present,
               replace => 'yes',
               mode    => 0777,
             }     
     }
   }


    
   # the py script used by the wlst
   file { "${path}${title}changeFMWLogFolder.py":
      path    => "${path}${title}changeFMWLogFolder.py",
      content => template("wls/wlst/changeFMWLogFolder.py.erb"),
   }
     
   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        exec { "execwlst ${title}changeFMWLogFolder.py":
          command     => "${mdwHome}/oracle_common/common/bin/wlst.sh ${path}${title}changeFMWLogFolder.py",
          environment => ["CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          unless      => "ls -l ${logDir}/${wlsServer}-diagnostic.log",
          require     => File["${path}${title}changeFMWLogFolder.py"],
        }    

        exec { "rm ${path}${title}changeFMWLogFolder.py":
           command => "rm -I ${path}${title}changeFMWLogFolder.py",
           require => Exec["execwlst ${title}changeFMWLogFolder.py"],
        }

     }
     windows: { 

        exec { "execwlst ${title}changeFMWLogFolder.py":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${mdwHome}/oracle_common/common/bin/wlst.cmd ${path}${title}changeFMWLogFolder.py",
          unless      => "dir ${logDir}\\${wlsServer}-diagnostic.log",
          require     => File["${path}${title}changeFMWLogFolder.py"],
        }    


        exec { "rm ${path}${title}changeFMWLogFolder.py":
           command => "C:\\Windows\\System32\\cmd.exe /c del ${path}${title}changeFMWLogFolder.py",
           require => Exec["execwlst ${title}changeFMWLogFolder.py"],
        }
     }
   }



}

