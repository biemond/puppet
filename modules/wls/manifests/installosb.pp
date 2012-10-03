# == Define: wls::installosb
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
#  wls::installosb{'osbPS5':
#    mdwHome      => '/opt/oracle/wls/wls11g',
#    wlHome       => '/opt/oracle/wls/wls11g/wlserver_10.3',
#    osbFile      => 'ofm_osb_generic_11.1.1.6.0_disk1_1of1.zip',
#    fullJDKName  => 'jdk1.7.0_07',	
#    user         => 'oracle',
#    group        => 'dba', 
#  }
# 


define wls::installosb($mdwHome         = undef,
                       $wlHome          = undef,
                       $fullJDKName     = undef,
                       $osbFile         = undef, 
                       $oepeHome        = undef,
                       $user            = 'oracle',
                       $group           = 'dba',
                    ) {

   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $execPath        = "/usr/java/${fullJDKName}/bin;/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = '/install/'
        $oracleHome      = "${mdwHome}/Oracle_OSB1"
        
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
        $oracleHome       = "${mdwHome}\\Oracle_OSB1"
        
        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0555,
             }   
     }
   }

   if $oepeHome == undef {
      $osbTemplate =  "wls/silent_osb.xml.erb"
   } else {
      $osbTemplate =  "wls/silent_osb_oepe.xml.erb"
   }

   if ! defined(File["${path}silent_osb.xml"]) {
     file { "${path}silent_osb.xml":
       ensure  => present,
       content => template($osbTemplate),
     }
   }

   # weblogic generic installer zip
   if ! defined(File["${path}${osbFile}"]) {
    file { "${path}${osbFile}":
     source  => "puppet:///modules/wls/${osbFile}",
     require => File ["${path}silent_osb.xml"],
    }
   }

   
   $command  = "-silent -response ${path}silent_osb.xml -invPtrLoc ${mdwHome}/oraInst.loc"
    
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        if ! defined(Exec["extract ${osbFile}"]) {
         exec { "extract ${osbFile}":
          command => "unzip ${path}${osbFile} -d ${path}/osb",
          require => File ["${path}${osbFile}"],
          creates => "${path}/osb",
         }
        }

        if ! defined(File["${mdwHome}/oraInst.loc"]) {
         file { "${mdwHome}/oraInst.loc":
           ensure  => present,
           content => template("wls/oraInst.loc.erb"),
           require     => Exec["extract ${osbFile}"],
         }
        }
        
        exec { "install osb ${title}":
          command     => "${path}osb/Disk1/install/linux64/runInstaller ${command} -ignoreSysPrereqs -jreLoc /usr/java/${fullJDKName}",
          require     => File ["${mdwHome}/oraInst.loc"],
          creates     => $oracleHome,
          environment => ["CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
        }    
             
     }
     windows: { 

        if ! defined(Exec["extract ${osbFile}"]) {
         exec { "extract ${osbFile}":
          command => "jar xf ${path}${osbFile}",
          require => File ["${path}${osbFile}"],
          creates => "${path}Disk1",
         }
        }

        exec { "install osb ${title}":
          command     => "${path}Disk1\\setup ${command} -jreLoc C:\\oracle\\${fullJDKName}",
          logoutput   => true,
          require     => Exec["extract ${osbFile}"],
        }    

     }
   }
}
