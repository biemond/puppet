# == Define: wls::bsupatch
#
# install bsu patch for weblogic  
#
# === Parameters
#
# [*mdwHome*]
#   the middleware home path /opt/oracle/wls/wls12c
#
# [*wlHome*]
#   the weblogic home path /opt/oracle/wls/wls12c/wlserver_12.1
#
# [*patchFile*]
#   bsu patch zip
#
# [*patchId*]
#   bsu patch id
#
# [*user*]
#   the user which runs the nodemanager on unix = oracle on windows = administrator
#
# [*group*]
#   the group which runs the nodemanager on unix = dba on windows = administrators
#
# === Variables
#
# === Examples
#
#  wls::bsupatch{'p13573621':
#    mdwHome      => '/opt/oracle/wls/wls11g',
#    wlHome       => '/opt/oracle/wls/wls11g/wlserver_10.3',
#    fullJDKName  => 'jdk1.7.0_07',	
#    patchId      => 'KZKQ',	
#    patchFile    => 'p13573621_1036_Generic.zip',	
#    user         => 'oracle',
#    group        => 'dba', 
#  }
# 


define wls::bsupatch($mdwHome         = undef,
                     $wlHome          = undef,
                     $fullJDKName     = undef, 
                     $patchId         = undef,
                     $patchFile       = undef,	
                     $user            = 'oracle',
                     $group           = 'dba',
                    ) {

   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $execPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $path             = '/install/'
        
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
     windows: { 

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 
        $path             = "c:\\temp\\" 

        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0555,
             }   
     }
   }
   if ! defined(File["${mdwHome}/utils/bsu/cache_dir"]) {
     file { "${mdwHome}/utils/bsu/cache_dir":
       ensure  => directory,
       recurse => false, 
     }
   }

   # the patch used by the bsu
   if ! defined(File["${path}${patchFile}"]) {
    file { "${path}${patchFile}":
     source  => "puppet:///modules/wls/${patchFile}",
     require => File ["${mdwHome}/utils/bsu/cache_dir"],
    }
   }

   
   $bsuCommand  = "-prod_dir=${wlHome} -patchlist=${patchId} -verbose -install"
    
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        if ! defined(Exec["extract ${patchFile}"]) {
         exec { "extract ${patchFile}":
          command => "unzip -n ${path}/${patchFile} -d ${mdwHome}/utils/bsu/cache_dir",
          require => File ["${path}${patchFile}"],
          creates => "${mdwHome}/utils/bsu/cache_dir/${patchId}.jar",
         }
        }
        
        exec { "execwlst ux nodemanager":
          command     => "${mdwHome}/utils/bsu/bsu.sh ${bsuCommand}",
          require     => Exec["extract ${patchFile}"],
        }    
             
     }
     windows: { 

        if ! defined(Exec["extract ${patchFile}"]) {
         exec { "extract ${patchFile}":
          command => "jar xf ${path}/${patchFile}",
          cwd     => "${mdwHome}/utils/bsu/cache_dir",
          require => File ["${path}${patchFile}"],
          creates => "${mdwHome}/utils/bsu/cache_dir/${patchId}.jar",
         }
        }

        exec { "execwlst win nodemanager":
          command     => "${checkCommand} ${mdwHome}\\utils\\bsu\\bsu.bat ${bsuCommand}",
          logoutput   => true,
          require     => Exec["extract ${patchFile}"],
        }    

     }
   }
}
