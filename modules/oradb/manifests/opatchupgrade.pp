# == Define: oradb::opatchupgrade
#
# upgrades oracle opatch
#
#
# === Examples
#
#
#   oradb::opatchupgrade{'112000_opatch_upgrade':
#     oracleHome => '/oracle/product/11.2/db' ,
#     patchFile         => '112030', 
#     user              => 'oracle',
#     group             => 'dba',
#     downloadDir       => '/install/',   
#     require           => Class['oradb::installdb'],
#   }
#
## 


define oradb::opatchupgrade(  
    $oracleHome     = undef,
    $patchFile      = undef,  
    $csiNumber      = undef,
    $supportId      = undef,
    $user           = 'oracle',
    $group          = 'dba',
    $downloadDir    = '/install/',
    $puppetMountDir = undef,
  ) {

  case $operatingsystem {
    CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

      $execPath  = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
      $patchDir  = "${oracleHome}/OPatch"

        
      Exec {  path      => $execPath,
              user      => $user,
              group     => $group,
              logoutput => true,
      }

      File {  ensure  => present,
              mode    => 0775,
              owner   => $user,
              group   => $group,
      }        
    }
  }

  # check install folder
  if ! defined(File[$downloadDir]) {
    file { $downloadDir :
      mode    => 0777,
      path    => $downloadDir,
      ensure  => directory,
    }
  }

  # if a mount was not specified then get the install media from the puppet master
  if $puppetMountDir == undef {
    $mountDir = "puppet:///modules/oradb/"      
  } else {
    $mountDir = $puppetMountDir
  }

     # check if the opatch already is installed 
     # $found = opatch_exists($oracleHome,$patchId)
     # if $found == undef {
     #   $continue = true
     # } else {
     #   if ( $found ) {
     #     notify {"oradb::opatch ${title} ${oracleHome} already exists":}
     #     $continue = false
     #   } else {
     #     notify {"oradb::opatch ${title} ${oracleHome} does not exists":}
     #     $continue = true 
     #   }
     # }
  if ! defined(File["${downloadDir}${patchFile}"]) {
    file {"${downloadDir}${patchFile}":
      path    => "${downloadDir}${patchFile}",
      ensure  => present,
      source  => "${mountDir}${patchFile}",
      require => File[$downloadDir],
      mode    => 0777,
    } 
  }

  case $operatingsystem {
    CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

      file { "remove_old":
        ensure  => absent,
        recurse => true,
        path    => $patchDir,
        force   => true,
      }
      ->
      exec { "extract opatch ${patchFile}":
        command => "unzip -n ${downloadDir}${patchFile} -d ${oracleHome}",
        require => File ["${downloadDir}${patchFile}"],
      }

      if $csiNumber != undef and supportId != undef {
        exec { "exec emocmrsp":
          cwd      => "${patchDir}",
          command  => "${patchDir}/ocm/bin/emocmrsp ${csiNumber} ${supportId}",
          require  => Exec["extract opatch ${patchFile}"],
        } 
      }
    }  
  }
}
