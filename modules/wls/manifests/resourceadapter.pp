# == Define: wls::resourceadapter
#
# generic resourceadapter wlst script  
#    adds a new plan to the jca resource adapter
#    adds a new entry to the plan
#
# === Examples
#  
#
#  wls::resourceadapter{
#   'DbAdapter_hr':
#    wlHome         => "/opt/oracle/wls/wls11g/wlserver_10.3",
#    fullJDKName    => $jdkWls11gJDK,
#    domain         => 'osbSoaDomain', 
#    adapterName    => 'DbAdapter' ,  or 'AqAdapter' or 'JmsAdapter'
#    adapterPlanDir => '/opt/wls/Middleware11gR1/Oracle_SOA1/soa/connectors' ,
#    adapterPlan    => 'Plan_DB.xml' ,
#    adapterEntry   => 'eis/DB/initial',
#    address        => "localhost",
#    port           => "7001",
#    wlsUser        => "weblogic",
#    password       => "weblogic1",
#    user           => 'oracle',
#    group          => 'dba',
#    downloadDir    => "/install/",
#  }
#
#
# 

define wls::resourceadapter( $wlHome         = undef, 
                             $fullJDKName    = undef, 
                             $domain         = undef, 
                             $adapterName    = undef,
                             $adapterPlanDir = undef,
                             $adapterPlan    = undef,
                             $adapterEntry   = undef,
                             $address        = "localhost",
                             $port           = '7001',
                             $wlsUser        = "weblogic",
                             $password       = "weblogic1",
                             $userConfigFile = undef,
                             $userKeyFile    = undef,
                             $user           = 'oracle', 
                             $group          = 'dba',
                             $downloadDir    = '/install/',
                            ) {


   # if these params are empty always continue    
   if $domain == undef or $adapterName == undef or $adapterPlanDir == undef or $adapterPlan == undef {
     fail("domain, adaptername,adapterPlanDir or adapterplan is nill") 
   } else {
     # check if the object already exists on the weblogic domain 
     $found = artifact_exists($domain ,"resource",$adapterName,"${adapterPlanDir}/${adapterPlan}" )
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
     $foundEntry = artifact_exists($domain ,'resource_entry',"${adapterPlanDir}/${adapterPlan}",$adapterEntry )
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
               mode    => 0744,
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
               mode    => 0777,
             }     
     }
   }

# lets make the a new plan for this adapter
if ( $continuePlan ) {

  # download the plan and put it on the right place
  if $adapterName == 'DbAdapter' {
    file { "${adapterPlanDir}/${adapterPlan}":
            path    => "${adapterPlanDir}/${adapterPlan}",
            content => template("wls/adapter_plans/Plan_DB.xml.erb"),
            before  => Exec["exec deployer adapter plan ${title}"],
    }
  } elsif $adapterName == 'JmsAdapter' {
    file { "${adapterPlanDir}/${adapterPlan}":
            path    => "${adapterPlanDir}/${adapterPlan}",
            content => template("wls/adapter_plans/Plan_JMS.xml.erb"),
            before  => Exec["exec deployer adapter plan ${title}"],
    }
  } elsif $adapterName == 'AqAdapter' {
    file { "${adapterPlanDir}/${adapterPlan}":
            path    => "${adapterPlanDir}/${adapterPlan}",
            content => template("wls/adapter_plans/Plan_AQ.xml.erb"),
            before  => Exec["exec deployer adapter plan ${title}"],
    }
  } else {
  	fail("adaptername ${adapterName} is unknown, choose for DbAdapter,JmsAdapter or AqAdapter ") 
  }
    
   $javaCommand    = "java weblogic.Deployer"

   # are we using credentials or using the WLST userConfig file 
   if $userConfigFile != undef {
     $credentials =   " -userconfigfile ${userConfigFile} -userkeyfile ${userKeyFile}"  	
   } elsif $wlsUser != undef {
     $credentials =   " -user ${wlsUser} -password ${password}"  	
   } else {
  	 fail("userConfigFile or wlsUser parameter is empty ") 
   }

     
   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

        # deploy the plan and update the adapter  
        exec { "exec deployer adapter plan ${title}":
          command     => "${javaCommand} -adminurl t3://${address}:${port} ${credentials} -update -name ${adapterName} -plan ${adapterPlanDir}/${adapterPlan}",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
        }    

     }
     windows: { 
        # deploy the plan and update the adapter  
        exec { "exec deployer adapter plan ${title}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommand} -adminurl t3://${address}:${port} ${credentials} -update -name ${adapterName} -plan ${adapterPlanDir}/${adapterPlan}",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
        }    
     }
   }



}

# after deployment of the plan we can add a new entry to the adapter  
if ( $continueEntry ) {

}


}