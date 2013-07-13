# == Define: wls::installwls
#
# Downloads from file folder and install weblogic with a silent install on linux and windows servers 
#
# === Examples
#
#
#  $jdkWls12cJDK  = 'jdk1.7.0_25'
#  $wls12cVersion = "1212"
#  
#  $user         = "oracle"
#  $group        = "dba"
#  $osOracleHome = "/opt/wls"
#  $osMdwHome    = "/opt/wls/Middleware11gR1"
#
#  # set the defaults
#  Wls::Installwls {
#    version      => $wls12cVersion,
#    fullJDKName  => $jdkWls12cJDK,
#    oracleHome   => $osOracleHome,
#    mdwHome      => $osMdwHome,
#    user         => $user,
#    group        => $group,    
#  }
#
#  
#  # install
#  wls::installwls{'wls12c':
#  }
#
# 

define wls::installwls( $version     = undef, 
                        $fullJDKName = undef,
                        $oracleHome  = undef,
                        $mdwHome     = undef,
                        $user        = 'oracle',
                        $group       = 'dba',
                        $downloadDir = '/install',
                        $puppetDownloadMntPoint  = undef,  
                      ) {

   notify {"wls::installwls ${version}":}

   $wls1212Parameter     = "1212"
   $wlsFile1212          = "ofm_wls_generic_12.1.2.0.0_disk1_1of1.zip" 
   $wlsFile1212_jar      = "wls_121200.jar" 

   $wls1211Parameter     = "1211"
   $wlsFile1211          = "wls1211_generic.jar" 

   $wls1036Parameter     = "1036"
   $wlsFile1036          = "wls1036_generic.jar" 


   $wlsFileDefault       = $wlsFile1036 

   case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 
        $execPath        = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir
        $beaHome         = $mdwHome

        $oraInventory    = "${oracleHome}/oraInventory"

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
      Solaris: {

        $execPath        = "/usr/jdk/${fullJDKName}/bin/amd64:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir
        $beaHome         = $mdwHome

        $oraInventory    = "${oracleHome}/oraInventory"

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
        $path            = $downloadDir 
        $beaHome         = $mdwHome

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 
        
        Exec { path      => $execPath,
             }
        File { ensure  => present,
               mode    => 0555,
             }   
      }
      default: { 
        fail("Unrecognized operating system") 
      }
   }



    # check weblogic version like 12c
    if $version == undef {
      $wlsFile    =  $wlsFileDefault 
    }
    elsif $version == $wls1211Parameter  {
      $wlsFile    =  $wlsFile1211 
    } 
    elsif $version == $wls1212Parameter  {
      $wlsFile    =  $wlsFile1212 
    } 
    elsif $version == $wls1036Parameter  {
      $wlsFile    =  $wlsFile1036 
    } 
    else {
      $wlsFile    =  $wlsFileDefault 
    } 

     # check if the wls already exists 
     $found = wls_exists($mdwHome)
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         notify {"wls::installwls ${title} ${mdwHome} already exists":}
         $continue = false
       } else {
         notify {"wls::installwls ${title} ${mdwHome} does not exists":}
         $continue = true 
       }
     }


if ( $continue ) {


   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/wls/"    	
   } else {
     $mountPoint =	$puppetDownloadMntPoint
   }

   wls::utils::defaultusersfolders{'create wls home':
            oracleHome      => $oracleHome,
            oraInventory    => $oraInventory, 
            user            => $user,
            group           => $group,
            downloadDir     => $path,
   }

#
#   if ! defined(File[$beaHome]) {
#     file { $beaHome:
#       path    => $beaHome,
#       ensure  => directory,
#       recurse => true, 
#       replace => false,
#       require => File[$oracleHome],
#     }
#   }

    if $version == $wls1212Parameter  {

       wls::utils::orainst{'create wls oraInst':
            oraInventory    => $oraInventory, 
            group           => $group,
       }

		   # de xml used by the wls installer
		   file { "silent.xml ${version}":
		     path    => "${path}/silent${version}.xml",
		     ensure  => present,
		     replace => 'yes',
		     content => template("wls/silent_${wls1212Parameter}.xml.erb"),
		     require => [ Wls::Utils::Orainst ['create wls oraInst']],
		   }

		   # put weblogic generic jar
		   file { "wls.jar ${version}":
		     path    => "${path}/${wlsFile}",
		     ensure  => file,
		     source  => "${mountPoint}/${wlsFile}",
		     require => File[$path],
		     replace => false,
		     backup  => false,
		   }

       exec { "extract ${wlsFile}":
          command => "unzip ${path}/${wlsFile} -d ${path}/wls",
          require => File ["wls.jar ${version}"],
          creates => "${path}/wls",
       }
		
       $command  = "-silent -responseFile ${path}/silent${version}.xml "
    
   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 
        
        exec { "install wls ${title}":
          command     => "java -jar ${path}/wls/${wlsFile1212_jar} ${command} -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs",
          require     => [Wls::Utils::Defaultusersfolders['create wls home'],File ["silent.xml ${version}"],Exec["extract ${wlsFile}"]],
          environment => ["CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          timeout     => 0,
        }    
             
     }
     Solaris: { 

        
        exec { "install wls ${title}":
          command     => "java -jar ${path}/wls/${wlsFile1212_jar} ${command} -invPtrLoc /var/opt/oraInst.loc -ignoreSysPrereqs",
          require     => [Wls::Utils::Defaultusersfolders['create wls home'],File ["silent.xml ${version}"],Exec["extract ${wlsFile}"]],
          timeout     => 0,
        }    

             
     }

     windows: { 

        exec {"icacls wls disk ${title}": 
           command    => "${checkCommand} icacls ${path}\\wls\\* /T /C /grant Administrator:F Administrators:F",
           logoutput  => false,
           require    => Exec["extract ${wlsFile}"],
        } 

        exec { "install wls ${title}":
          command     => "${checkCommand} java -jar ${path}/wls/${wlsFile1212_jar}  ${command} -ignoreSysPrereqs",
          logoutput   => true,
          require     => [Wls::Utils::Defaultusersfolders['create wls home'],Exec["icacls wls disk ${title}"],File ["silent.xml ${version}"],Exec["extract ${wlsFile}"]],
          timeout     => 0,
        }    

     }
   }

    } 
    else {

       # de xml used by the wls installer
       file { "silent.xml ${version}":
         path    => "${path}/silent${version}.xml",
         ensure  => present,
         replace => 'yes',
         content => template("wls/silent.xml.erb"),
         require => File[$path],
       }


		   # put weblogic generic jar
		   file { "wls.jar ${version}":
		     path    => "${path}/${wlsFile}",
		     ensure  => file,
		     source  => "${mountPoint}/${wlsFile}",
		     require => File[$path],
		     replace => false,
		     backup  => false,
		   }
		
       $javaCommand     = "java -Xmx1024m -jar"

		   # install weblogic
		   case $operatingsystem {
		     CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 
		        exec { "installwls ${path}/${wlsFile}":
		          command     => "${javaCommand} ${path}/${wlsFile} -mode=silent -silent_xml=${path}/silent${version}.xml",
		          environment => ["JAVA_VENDOR=Sun",
		                          "JAVA_HOME=/usr/java/${fullJDKName}",
		                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
		          logoutput   => true,
		          require     => [Wls::Utils::Defaultusersfolders['create wls home'],File ["wls.jar ${version}"],File ["silent.xml ${version}"]],
		        }    
		     }
		     Solaris: { 
		        exec { "installwls ${path}/${wlsFile}":
		          command     => "${javaCommand} ${path}/${wlsFile} -mode=silent -silent_xml=${path}/silent${version}.xml",
		          environment => ["JAVA_VENDOR=Sun",
		                          "JAVA_HOME=/usr/jdk/${fullJDKName}"],
		          require     => [Wls::Utils::Defaultusersfolders['create wls home'],File ["wls.jar ${version}"],File ["silent.xml ${version}"]],                
		        }    
		     }
		     windows: { 
		        exec { "installwls  ${path}/${wlsFile}":
		          command     => "${checkCommand} /c ${javaCommand} ${path}/${wlsFile} -mode=silent -silent_xml=${path}/silent${version}.xml",
		          environment => ["JAVA_VENDOR=Sun",
		                          "JAVA_HOME=C:\\oracle\\${fullJDKName}"],
              require     => [Wls::Utils::Defaultusersfolders['create wls home'],File ["wls.jar ${version}"],File ["silent.xml ${version}"]],
		        }    
		     }
		   }

    } 

 }
}   