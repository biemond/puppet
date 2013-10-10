# == Define: wls::utils::orainst
#
#  creates oraInst.loc
# 
#
## 
define wls::utils::orainst( $oraInventory    = undef,
                            $group           = 'dba',
                    ) {

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: { 
        $oraInstPath        = "/etc"
     }
     Solaris: { 
        $oraInstPath        = "/var/opt"
     }
     windows: {
        $oraInventory       = "C:\\Program Files\\Oracle\\Inventory"
     }
   }
   
   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: { 
        if ! defined(File["${oraInstPath}/oraInst.loc"]) {
         file { "${oraInstPath}/oraInst.loc":
           ensure  => present,
           content => template("wls/utils/oraInst.loc.erb"),
         }
        }
     }
     windows: { 
        if ! defined(Registry_Key["HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle"]) { 
          registry_key { "HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle":
            ensure  => present,
          }
        }

        if ! defined(Registry_Value ["HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle\\inst_loc"]) {
          registry_value { "HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle\\inst_loc":
            type    => string,
            data    => $oraInventory,
            require => Registry_Key["HKEY_LOCAL_MACHINE\\SOFTWARE\\Oracle"],
          }
        }
       }
    }                  
}