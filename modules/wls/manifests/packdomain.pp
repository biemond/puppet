# == Define: wls::packdomain
#
# packs a  weblogic domain to the download folder
##
define wls::packdomain (
  $wlHome          = undef,
  $mdwHome         = undef,
  $fullJDKName     = undef,
  $domain          = undef,
  $user            = 'oracle',
  $group           = 'dba',
  $downloadDir     = '/install',
) {

  $domainPath = "${mdwHome}/user_projects/domains"

  case $operatingsystem {
    CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES : {
      $execPath = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"
    }
    Solaris : {
      $execPath = "/usr/jdk/${fullJDKName}/bin/amd64:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"
    }
    windows : {
      $execPath = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
      $checkCommand = "C:\\Windows\\System32\\cmd.exe /c"
    }
  }

  $packCommand = "-domain=${domainPath}/${domain} -template=${downloadDir}/domain_${domain}.jar -template_name=domain_${domain} -log=${downloadDir}/domain_${domain}.log -log_priority=INFO"

  case $operatingsystem {
    CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris : {
      exec { "pack domain ${domain} ${title}":
        command   => "${wlHome}/common/bin/pack.sh ${packCommand}",
        creates   => "${downloadDir}/domain_${domain}.jar",
        logoutput => true,
      }
    }
    windows : {
      exec { "pack domain ${domain} ${title}":
        command   => "${checkCommand} ${wlHome}/common/bin/pack.cmd ${packCommand}",
        creates   => "${downloadDir}/domain_${domain}.jar",
        logoutput => true,
      }
    }
  }
}
