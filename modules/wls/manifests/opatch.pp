# == Define: wls::opatch
#
# installs oracle patches for Oracle products  
#
#
# === Examples
#
#    $jdkWls11gJDK = 'jdk1.7.0_09'
# 
#  case $operatingsystem {
#     centos, redhat, OracleLinux, ubuntu, debian: { 
#       $oracleHome   = "/opt/oracle/wls/wls11g/Oracle_OSB1"
#       $user         = "oracle"
#       $group        = "dba"
#     }
#     windows: { 
#       $oracleHome   = "c:/oracle/wls/wls11g/Oracle_OSB1"
#       $user         = "Administrator"
#       $group        = "Administrators"
#     }
#  }
#
#  wls::opatch{'14389126_osb_patch':
#    oracleHome   => $oracleHome ,
#    fullJDKName  => $defaultFullJDK,
#    patchId      => '14389126',	
#    patchFile    => 'p14389126_111160_Generic.zip',	
#    user         => $user,
#    group        => $group, 
#  }
## 


define wls::opatch(  $oracleHome      = undef,
                     $fullJDKName     = undef, 
                     $patchId         = undef,
                     $patchFile       = undef,	
                     $user            = 'oracle',
                     $group           = 'dba',
                    ) {

   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $execPath         = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $path             = '/install'
        $JAVA_HOME        = "/usr/java/${fullJDKName}"

        
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
        $JAVA_HOME        = "c:\\oracle\\${fullJDKName}"
        $oracleHomeWin    = slash_replace($oracleHome)

        Exec { path      => $execPath,
        	     logoutput => true,
             }
        File { ensure  => present,
               mode    => 0555,
             }   
     }
   }

   # the patch used by the bsu
   if ! defined(File["${path}${patchFile}"]) {
    file { "${path}${patchFile}":
     source  => "puppet:///modules/wls/${patchFile}",
    }
   }



     # check if the opatch already is installed 
     $found = opatch_exists($oracleHome,$patchId)
     if $found == undef {
       $continue = true
     } else {
       if ( $found ) {
         notify {"wls::opatch ${title} ${oracleHome} already exists":}
         $continue = false
       } else {
         notify {"wls::opatch ${title} ${oracleHome} does not exists":}
         $continue = true 
       }
     }

if ( $continue ) {

   # opatch apply -silent -jdk %JDK_HOME% -jre %JDK_HOME%\jre  -oh C:\oracle\MiddlewarePS5\Oracle_OSB1 C:\temp\14389126
   $oPatchCommand  = "opatch apply -silent -jre"
    
   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        exec { "extract opatch ${patchFile} ${title}":
          command => "unzip -n ${path}/${patchFile} -d ${path}",
          require => File ["${path}${patchFile}"],
          creates => "${path}/${patchId}",
        }
        
        exec { "exec opatch ux ${title}":
          command     => "${oracleHome}/OPatch/${oPatchCommand} ${JAVA_HOME}/jre -oh ${oracleHome} ${path}/${patchId}",
          require     => Exec["extract opatch ${patchFile} ${title}"],
        }    
             
     }
     windows: { 

        exec { "extract opatch ${patchFile} ${title}":
          command => "jar.exe xf ${path}${patchFile}",
          creates => "${path}${patchId}",
          cwd     => $path, 
          require => File ["${path}${patchFile}"],
        }
        #notify {"wls::opatch win exec ${title} ${checkCommand} ${oracleHome}/OPatch/${oPatchCommand} ${JAVA_HOME}\\jre -oh ${oracleHomeWin} ${path}${patchId}":}
        exec { "exec opatch win ${title}":
          command     => "${checkCommand} ${oracleHome}/OPatch/${oPatchCommand} ${JAVA_HOME}\\jre -oh ${oracleHomeWin} ${path}${patchId}",
          logoutput   => true,
          require     => Exec["extract opatch ${patchFile} ${title}"],
        }    

     }
   }
}
}
