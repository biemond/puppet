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
#    adapterPath    => '/opt/wls/Middleware11gR1/Oracle_SOA1/soa/connectors/DbAdapter.rar'
#    adapterPlanDir => '/opt/wls/Middleware11gR1/Oracle_SOA1/soa/connectors' ,
#    adapterPlan    => 'Plan_DB.xml' ,
#    adapterEntry   => 'eis/DB/initial',
#    adapterEntryProperty => 'xADataSourceName',  or 'dataSourceName' or 'ConnectionFactoryLocation' (jms)
#    adapterEntryValue    => 'jdbc/hrDS',
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

define wls::resourceadapter( $version        = '1111',
                             $wlHome         = undef,
                             $fullJDKName    = undef,
                             $domain         = undef,
                             $adapterName    = undef,
                             $adapterPath    = undef,
                             $adapterPlanDir = undef,
                             $adapterPlan    = undef,
                             $adapterEntry   = undef,
                             $adapterEntryProperty = undef,
                             $adapterEntryValue    = undef,
                             $address        = "localhost",
                             $port           = '7001',
                             $wlsUser        = "weblogic",
                             $password       = "weblogic1",
                             $userConfigFile = undef,
                             $userKeyFile    = undef,
                             $user           = 'oracle',
                             $group          = 'dba',
                             $downloadDir    = '/install',
                            ) {

   # if these params are empty always continue
   if $domain == undef or $adapterName == undef or $adapterPlanDir == undef or $adapterPlan == undef {
     fail("domain, adaptername,adapterPlanDir or adapterplan is nill")
   } else {
     # check if the object already exists on the weblogic domain
     $found = artifact_exists($domain ,"resource",$adapterName,"${adapterPlanDir}/${adapterPlan}",$version )
     if $found == undef {
       $continuePlan = true
         notify {"wls::resourceadapter ${title} ${version} continue cause nill":}
     } else {
       if ( $found ) {
         $continuePlan = false
       } else {
         notify {"wls::resourceadapter ${title} ${version} continue, does not exists":}
         $continuePlan = true
       }
     }
   }

   # if these params are empty always continue
   if $domain == undef or $adapterName == undef or $adapterEntry == undef {
     fail("domain, adaptername or adapterEntry is nill")
   } else {
     # check if the object already exists on the weblogic domain
     $foundEntry = artifact_exists($domain ,"resource_entry",$adapterName,$adapterEntry,$version )
     if $foundEntry == undef {
       $continueEntry = true
         notify {"wls::resourceadapter entry ${adapterEntry} ${title} ${version} continue cause nill":}
     } else {
       if ( $foundEntry ) {
         $continueEntry = false
       } else {
         notify {"wls::resourceadapter entry ${adapterEntry} ${title} ${version} continue, does not exists":}
         $continueEntry = true
       }
     }
   }

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

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
               backup  => false,
             }
     }
     Solaris: {

        $execPath         = "/usr/jdk/${fullJDKName}/bin/amd64:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path             = $downloadDir
        $JAVA_HOME        = "/usr/jdk/${fullJDKName}"


        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
        File {
               ensure  => present,
               replace => 'yes',
               mode    => 0744,
               owner   => $user,
               group   => $group,
               backup  => false,
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
               mode    => 0744,
               backup  => false,
             }
     }
   }

   # are we using credentials or using the WLST userConfig file
   if $userConfigFile != undef {
     $credentials    =   " -userconfigfile ${userConfigFile} -userkeyfile ${userKeyFile}"
     $useStoreConfig = true
   } elsif $wlsUser != undef {
     $credentials =   " -user ${wlsUser} -password ${password}"
     $useStoreConfig = false
   } else {
  	 fail("userConfigFile or wlsUser parameter is empty ")
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

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

        # deploy the plan and update the adapter
        exec { "exec deployer adapter plan ${title}":
          command     => "${javaCommand} -adminurl t3://${address}:${port} ${credentials} -update -name ${adapterName} -plan ${adapterPlanDir}/${adapterPlan}",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
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

  if $adapterName == 'DbAdapter' or $adapterName == 'AqAdapter'  {
     $connectionFactoryInterface='javax.resource.cci.ConnectionFactory'

  } elsif $adapterName == 'JmsAdapter' {
     $connectionFactoryInterface='oracle.tip.adapter.jms.IJmsConnectionFactory'
  }

   $javaCommandPlan = "java -Dweblogic.security.SSL.ignoreHostnameVerification=true weblogic.WLST -skipWLSModuleScanning "

   file { "${path}/${title}redeployResourceAdapter.py":
            path    => "${path}/${title}redeployResourceAdapter.py",
            content => template("wls/wlst/redeployResourceAdapter.py.erb"),
            before  => Exec["exec redeploy adapter plan ${title}"],
   }

   file { "${path}/${title}createResourceAdapterEntry.py":
            path    => "${path}/${title}createResourceAdapterEntry.py",
            content => template("wls/wlst/createResourceAdapterEntry.py.erb"),
            before  => Exec["exec create resource adapter entry ${title}"],
   }


   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

        # deploy the plan and update the adapter
        exec { "exec create resource adapter entry ${title}":
          command     => "${javaCommandPlan} ${path}/${title}createResourceAdapterEntry.py",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
        }

        # deploy the plan and update the adapter
        exec { "exec redeploy adapter plan ${title}":
          command     => "${javaCommandPlan} ${path}/${title}redeployResourceAdapter.py",
          environment => ["CLASSPATH=${wlHome}/server/lib/weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          require  => Exec["exec create resource adapter entry ${title}"],
        }

        case $operatingsystem {
           CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

		        exec { "rm ${path}/${title}createResourceAdapterEntry.py":
		           command => "rm -I ${path}/${title}createResourceAdapterEntry.py",
		           require  => Exec["exec create resource adapter entry ${title}"],
		        }

		        exec { "rm ${path}/${title}redeployResourceAdapter.py":
		           command => "rm -I ${path}/${title}redeployResourceAdapter.py",
		           require => Exec["exec redeploy adapter plan ${title}"],
		        }
        }
          Solaris: {

		        exec { "rm ${path}/${title}createResourceAdapterEntry.py":
		           command => "rm ${path}/${title}createResourceAdapterEntry.py",
		           require  => Exec["exec create resource adapter entry ${title}"],
		        }

		        exec { "rm ${path}/${title}redeployResourceAdapter.py":
		           command => "rm ${path}/${title}redeployResourceAdapter.py",
		           require => Exec["exec redeploy adapter plan ${title}"],
		        }

          }
        }


     }
     windows: {
        # deploy the plan and update the adapter
        exec { "exec create resource adapter entry ${title}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommandPlan} ${path}/${title}createResourceAdapterEntry.py",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
        }

        # deploy the plan and update the adapter
        exec { "exec redeploy adapter plan ${title}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommandPlan} ${path}/${title}redeployResourceAdapter.py",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          require  => Exec["exec create resource adapter entry ${title}"],
        }
        exec { "rm ${path}/${title}createResourceAdapterEntry.py":
           command => "C:\\Windows\\System32\\cmd.exe /c rm ${path}/${title}createResourceAdapterEntry.py",
           require  => Exec["exec create resource adapter entry ${title}"],
        }

        exec { "rm ${path}/${title}redeployResourceAdapter.py":
           command => "C:\\Windows\\System32\\cmd.exe /c rm ${path}/${title}redeployResourceAdapter.py",
           require => Exec["exec redeploy adapter plan ${title}"],
        }

     }
   }
}


}
