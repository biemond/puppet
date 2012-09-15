# class params of module wls

class wls::params {

   $wlsFileDefault      = "wls1211_generic.jar" 
   $wlsVersionDefault   = "wls12c" 
   
   $wls12cParameter     = "12c"
   $wlsFile12c          = "wls1211_generic.jar" 
   $wlsVersion12c       = "wls12c" 


   $jdkVersionDefault   = "7u7" 

   $jdkVersion7u7   = "7u7" 
   $fullJDKName7u7  = "jdk1.7.0_07"

   $jdkVersion7u8   = "7u8" 
   $fullJDKName7u8  = "jdk1.7.0_08"

   $javaCommand     = "java -Xmx1024m -jar"

   case $operatingsystem {
      centos, redhat, OracleLinux, ubuntu, debian: { 
        $path             = "/install/"

        $oracleHome       = "/opt/oracle/"
        $beaHome          = "${oracleHome}wls/"

        $user             = "oracle"
        $group            = "dba"

        $check            = '/usr/java/'
        $checkAfter       = '/bin'
        $otherPath        = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
        $checkCommand     = '/bin/ls -l'
     }
      windows: { 
        $path             = "C:\\temp\\"

        $oracleHome       = "C:\\oracle\\"
        $beaHome          = "${oracleHome}wls\\"

        $user             = "Administrator"
        $group            = "Administrators"

        $check            = "\"C:\\Program Files\\Java\\"
        $checkAfter       = "\\bin\""
        $otherPath        = "C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 

      }
      default: { 
        fail("Unrecognized operating system") 
      }
   }


}