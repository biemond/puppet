# == Define: wls::resourceadapter
#
# generic resourceadapter wlst script  
#
#
# === Examples
#  
#
#  wls::resourceadapter{
#   'DbAdapter_hr':
#    wlHome        => "/opt/oracle/wls/wls11g/wlserver_10.3",
#    fullJDKName   => $jdkWls11gJDK,
#    domain        => 'osbSoaDomain', 
#    adapterName   => 'dbadapter' ,
#    adapterPlan   => '/opt/wls/Middleware11gR1/Oracle_SOA1/soa/connectors/Plan_DB.xml' ,
#    adapterEntry  => 'eis/DB/initial',
#    address       => "localhost",
#    port          => "7001",
#    wlsUser       => "weblogic",
#    password      => "weblogic1",
#    user          => 'oracle',
#    group         => 'dba',
#    downloadDir   => "/install/",
#  }
#
#
# 

define wls::resourceadapter( $wlHome        = undef, 
                             $fullJDKName   = undef, 
                             $domain        = undef, 
                             $adapterName   = undef,
                             $adapterPlan   = undef,
                             $adapterEntry  = undef,
                             $address       = "localhost",
                             $port          = '7001',
                             $wlsUser       = "weblogic",
                             $password      = "weblogic1",
                             $userConfigFile = undef,
                             $userKeyFile    = undef,
                             $user          = 'oracle', 
                             $group         = 'dba',
                             $downloadDir   = '/install/',
                            ) {


   # if these params are empty always continue    
   if $domain == undef or $adapterName == undef or $adapterPlan == undef {
     fail("domain, adaptername or adapterplan is nill") 
   } else {
     # check if the object already exists on the weblogic domain 
     $found = artifact_exists($domain ,"resource",$adapterName,$adapterPlan )
     if $found == undef {
       $continuePlan = true
         notify {"wls::resourceadapter ${title} continue cause nill":}
     } else {
       if ( $found ) {
         notify {"wls::resourceadapter ${title} already exists":}
         $continuePlan = false
       } else {
         notify {"wls::resourceadapter ${title} continue, does not exists":}
         $continuePlan = true 
       }
     }
   }

   # if these params are empty always continue    
   if $domain == undef or $adapterName == undef or $adapterEntry == undef {
     fail("domain, adaptername or adapterEntry is nill") 
   } else {
     # check if the object already exists on the weblogic domain 
     $foundEntry = artifact_exists($domain ,'resource_entry',$adapterName,$adapterEntry )
     if $foundEntry == undef {
       $continueEntry = true
         notify {"wls::resourceadapter entry ${adapterEntry} ${title} continue cause nill":}
     } else {
       if ( $foundEntry ) {
         notify {"wls::resourceadapter entry ${adapterEntry} ${title} already exists":}
         $continueEntry = false
       } else {
         notify {"wls::resourceadapter entry ${adapterEntry} ${title} continue, does not exists":}
         $continueEntry = true 
       }
     }
   }



   # use userConfigStore for the connect
	 if $password == undef {
     $useStoreConfig = true  
   } else {	
     $useStoreConfig = false  
   }




   $javaCommand    = "java -Dweblogic.management.confirmKeyfileCreation=true -Dweblogic.security.SSL.ignoreHostnameVerification=true weblogic.WLST -skipWLSModuleScanning "

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path             = $downloadDir
        $JAVA_HOME        = "/usr/java/${fullJDKName}"

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

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $path             = $downloadDir 

        $JAVA_HOME        = "c:\\oracle\\${fullJDKName}"

        Exec { path      => $execPath,
               logoutput => true,
             }
        File { ensure  => present,
               replace => 'yes',
               mode    => 0777,
             }     
     }
   }

if ( $continuePlan ) {
    
   # the py script used by the wlst
#   file { "${path}${title}storeUserConfig.py":
#      path    => "${path}${title}storeUserConfig.py",
#      content => template("wls/wlst/storeUserConfig.py.erb"),
#   }
     
   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

#        exec { "execwlst ${title}storeUserConfig.py":
#          command     => "${javaCommand} ${path}${title}storeUserConfig.py",
#          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
#                          "JAVA_HOME=${JAVA_HOME}",
#                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
#          unless      => "ls -l ${userConfigDir}/${user}-${$domain}-WebLogicConfig.properties",
#          require     => File["${path}${title}storeUserConfig.py"],
#        }    
#
#        exec { "rm ${path}${title}storeUserConfig.py":
#           command => "rm -I ${path}${title}storeUserConfig.py",
#           require => Exec["execwlst ${title}storeUserConfig.py"],
#        }
#
     }
     windows: { 

#        exec { "execwlst ${title}storeUserConfig.py":
#          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommand} ${path}${title}storeUserConfig.py",
#          unless      => "dir ${userConfigDir}/${user}-${$domain}-WebLogicConfig.properties",
#          require     => File["${path}${title}storeUserConfig.py"],
#          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
#                          "JAVA_HOME=${JAVA_HOME}"],
#        }    
#
#
#        exec { "rm ${path}${title}storeUserConfig.py":
#           command => "C:\\Windows\\System32\\cmd.exe /c del ${path}${title}storeUserConfig.py",
#           require => Exec["execwlst ${title}storeUserConfig.py"],
#        }
     }
   }



}


if ( $continueEntry ) {

}


}