# class params of module wls

class wls::params {

   
   $wls12cParameter     = "12c"

   $wlsFile12c          = "wls1211_generic.jar" 
   $wlsVersion12c       = "wls12c" 

   $wlsFileDefault      = $wlsFile12c 
   $wlsVersionDefault   = $wlsVersion12c 


   $jdkVersion7u7   = "7u7" 
   $fullJDKName7u7  = "jdk1.7.0_07"

   $jdkVersion7u8   = "7u8" 
   $fullJDKName7u8  = "jdk1.7.0_08"

   $jdkVersionDefault   = $jdkVersion7u7 



   case $operatingsystem {
      centos, redhat, OracleLinux, ubuntu, debian: { 
        $path             = "/install/"

        $oracleHome       = "/opt/oracle/"
        $beaHome          = "${oracleHome}wls/"

        $user             = "oracle"
        $group            = "dba"
     }
      windows: { 
        $path             = "C:\\temp\\"

        $oracleHome       = "C:\\oracle\\"
        $beaHome          = "${oracleHome}wls\\"

        $user             = "Administrator"
        $group            = "Administrators"
      }
      default: { 
        fail("Unrecognized operating system") 
      }
   }


}