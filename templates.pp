# templates.pp
#

include jdk7
include wls

class osb_oepe{

  if $jdkWls11gVersion == undef {
    $jdkWls11gVersion = "7u9"
    notify {"wls11g jdkWls11gVersion not defined,use defaults":}
  }

  if $jdkWls11gJDK == undef {
    $jdkWls11gJDK = 'jdk1.7.0_09'
  }

  if $wls11gVersion == undef {
    $wls11gVersion = "1036"
  }

  jdk7::install7{'jdk7_husdon':
    version => $jdkWls11gVersion,
    x64     => "true",
  }

  $osMdwHome    = "/opt/oracle/wls/wls11g"
  $osWlHome     = "/opt/oracle/wls/wls11g/wlserver_10.3"
  $user         = "oracle"
  $group        = "dba"

  $oepeFile     = "oepe-indigo-all-in-one-11.1.1.8.0.201110211138-linux-gtk-x86_64.zip"


  # set the defaults
  Wls::Installwls {
    version      => $wls11gVersion,
    versionJdk   => $jdkWls11gVersion,
    user         => $user,
    group        => $group,    
  }


  Wls::Installosb {
    mdwHome      => $osMdwHome,
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls11gJDK,	
    user         => $user,
    group        => $group,    
  }

  # install
  wls::installwls{'11gPS5_hudson':
    require      => Jdk7::Install7['jdk7_husdon'],
  }


  # download oepe to hudson server
  if ! defined(File["/install/${oepeFile}"]) {
    file { "/install/${oepeFile}":
       source  => "puppet:///modules/wls/${oepeFile}",
       require => Wls::Installwls['11gPS5_hudson'],
       ensure  => present,
       mode    => 0775,
    }
  }

  # extract oepe in middleware home
  if ! defined(Exec["extract ${oepeFile}"]) {
     exec { "extract ${oepeFile}":
          command   => "unzip -n /install/${oepeFile} -d ${osMdwHome}/oepe11.1.1.8",
          require   => File["/install/${oepeFile}"],
          creates   => "${osMdwHome}/oepe11.1.1.8",
          path      => "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:",
          user      => $user,
          group     => $group,
          logoutput => true,
         }
  }

  #install OSB with OEPE
  wls::installosb{'osbPS5_oepe':
    osbFile      => 'ofm_osb_generic_11.1.1.6.0_disk1_1of1.zip',
    oepeHome     => 'oepe11.1.1.8',
    require      => Exec["extract ${oepeFile}"],
  }


}



class wls1036osb{

  if $jdkWls11gVersion == undef {
    $jdkWls11gVersion = "7u9"
    notify {"wls11g jdkWls11gVersion not defined,use defaults":}
  }

  if $jdkWls11gJDK == undef {
    $jdkWls11gJDK = 'jdk1.7.0_09'
  }

  if $wls11gVersion == undef {
    $wls11gVersion = "1036"
  }


  jdk7::install7{'jdk7_2':
    version => $jdkWls11gVersion,
    x64     => "true",
  }
 
  case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
       $osMdwHome    = "/opt/oracle/wls/wls11g"
       $osWlHome     = "/opt/oracle/wls/wls11g/wlserver_10.3"
       $user         = "oracle"
       $group        = "dba"
     }
     windows: { 
       $osMdwHome    = "c:/oracle/wls/wls11g"
       $osWlHome     = "c:/oracle/wls/wls11g/wlserver_10.3"
       $user         = "Administrator"
       $group        = "Administrators"
       $serviceName  = "C_oracle_wls_wls11g_wlserver_10.3"
     }
  }

  # set the defaults
  Wls::Installwls {
    version      => $wls11gVersion,
    versionJdk   => $jdkWls11gVersion,
    user         => $user,
    group        => $group,    
  }

  Wls::Installosb {
    mdwHome      => $osMdwHome,
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls11gJDK,	
    user         => $user,
    group        => $group,    
  }
  
  Wls::Nodemanager {
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls11gJDK,	
    user         => $user,
    group        => $group,
    serviceName  => $serviceName,  
  }
  

  # install
  wls::installwls{'11gPS5':
    require      => Jdk7::Install7['jdk7_2'],
  }

  wls::installosb{'osbPS5':
    osbFile      => 'ofm_osb_generic_11.1.1.6.0_disk1_1of1.zip',
    require      => Wls::Installwls['11gPS5'],
  }

  wls::bsupatch{'p13573621':
    mdwHome      => $osMdwHome ,
    wlHome       => $osWlHome,
    fullJDKName  => $defaultFullJDK,
    patchId      => 'KZKQ',	
    patchFile    => 'p13573621_1036_Generic.zip',	
    user         => $user,
    group        => $group, 
    require      => Wls::Installosb['osbPS5'],
  }


 #nodemanager configuration and starting
 wls::nodemanager{'nodemanager11g':
   listenPort  => '5556',
   require     => Wls::Installosb['osbPS5'],
 }


}

class wls12{

  if $jdkWls12cVersion == undef {
    $jdkWls12cVersion = "7u9"
    notify {"wls12 jdkWls12cVersion not defined,use defaults":}
  }

  if $jdkWls12cJDK == undef {
    $jdkWls12cJDK = 'jdk1.7.0_09'
  }

  if $wls12cVersion == undef {
    $wls12cVersion = "1211"
  }

  jdk7::install7{'jdk7':
    version => $jdkWls12cVersion,
    x64     => "true",
  }
  
  case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
       $osWlHome     = "/opt/oracle/wls/wls12c/wlserver_12.1"
       $user         = "oracle"
       $group        = "dba"
     }
     windows: { 
       $osWlHome     = "c:/oracle/wls/wls12c/wlserver_12.1"
       $user         = "Administrator"
       $group        = "Administrators"
       $serviceName  = "C_oracle_wls_wls12c_wlserver_12.1"
     }
  }

  # set the defaults
  Wls::Installwls {
    version      => $wls12cVersion,
    versionJdk   => $jdkWls12cVersion,
    user         => $user,
    group        => $group,    
  }

  Wls::Nodemanager {
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls12cJDK,	
    user         => $user,
    group        => $group,
    serviceName  => $serviceName,  
  }
  
  # install
  wls::installwls{'wls12c':
    require      => Jdk7::Install7['jdk7'],
  }

  #nodemanager configuration and starting
  wls::nodemanager{'nodemanager':
    listenPort   => '5656',
    require      => Wls::Installwls['wls12c'],
  }

} 