# == Define: wls::params
#
# params class  
#
# === Parameters
#
# === Variables
#
# === Examples
#
# 


class wls::params {



   case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 

        $execPath        = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = "/install/"
        $user            = "oracle" 
        $group           = "dba" 
        $mode            = 0775
        $logoutput       = true

        $oraInstPath     = "/etc/"
        $oraInventory    = "/opt/oracle/orainventory"

        $oracleHome       = "/opt/oracle/"

        $nodeMgrMachine   = "UnixMachine"

     }
     windows: { 

        $execPath         = "C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c" 
        $path             = "c:\\temp\\" 
        $user             = "oracle" 
        $group            = "dba" 
        $mode             = 0555
        $logoutput        = true

        $oraInventory     = "C:\Program Files\Oracle\Inventory"

        $oracleHome       = "C:\\oracle\\"

        $nodeMgrMachine   = "Machine"

     }




}