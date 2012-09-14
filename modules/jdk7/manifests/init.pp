# = Class: jdk7
# 
# This class installs oracle jdk7
#
class jdk7 ( $version =  undef , $x64 = "true" ) {


    case $operatingsystem {
      centos, redhat, OracleLinux, ubuntu, debian: { 
        $installVersion   = "linux"
        $installExtension = "rpm"
        $exeBin           = "/bin/rpm -Uvh --replacepkgs "
        $exeBinAfter      = undef
        $path             = "/root/"
        $check            = "/usr/java/"
        $checkAfter       = "/bin"
        $user             = "root"
        $group            = "root"
        $checkCommand     = "/bin/ls -l"
      }
      windows: { 
        $installVersion   = "windows"
        $installExtension = "exe"
        $exeBin           = undef
        $exeBinAfter      = " /s ADDLOCAL=\"ToolsFeature\""
        $path             = "C:\\temp\\"
        $check            = "\"C:\\Program Files\\Java\\"
        $checkAfter       = "\\bin\""
        $user             = "Administrator"
        $group            = "Administrators"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c dir" 
      }
      default: { 
        fail("Unrecognized operating system") 
      }
    }

    if $x64 == "true" {
      $type = 'x64'
    } else {
      $type = 'i586'
    }

    if $version == undef {
      $jdkVersion = "7u7"
    } else {
      $jdkVersion = $version
    } 
     
    if $jdkVersion      == "7u7" {
       $jdkfile         =  "jdk-7u7-${installVersion}-${type}.${installExtension}"
       $fullVersion     =  "jdk1.7.0_07"
    } elsif $jdkVersion == "7u8" {
       $jdkfile         =  "jdk-7u8-${installVersion}-${type}.${installExtension}"
       $fullVersion     =  "jdk1.7.0_08"
    } else {
        fail("Unrecognized jdk version")        
    }

    file {"jdk_file":
        path   => "${path}${jdkfile}",
        ensure => present,
        source => "puppet:///modules/jdk7/${jdkfile}",
        owner  => "${user}",
        group  => "${group}",
        mode   => 0770,
    } 

    exec {"jdk_install": 
        cwd     =>  "${path}",
        command =>  "${exeBin}${path}${jdkfile}${exeBinAfter}",
        require =>  File["jdk_file"],
#        creates =>  "${check}${fullVersion}${checkAfter}",
        unless  =>  "${checkCommand} ${check}${fullVersion}${checkAfter}",
    } 

#    notify {"Operating system ${operatingsystem}":}
#    notify {"jdk file ${jdkfile} type ${type}":}
#    notify {"exec command ${exeBin}${path}${jdkfile}$exeBinAfter":}
#    notify {"create command ${check}${fullVersion}${checkAfter}":}

}