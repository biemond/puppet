# == Define: orautils::nodemanagerautostart
#
#  autostart of the nodemanager for linux
#
define oradb::autostartdatabase( $oracleHome  = undef,
                                 $dbName      = undef,
                                 $user        = 'oracle',
)

{
  case $operatingsystem {
    CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {
      $execPath    = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
      Exec { path  => $execPath,
        logoutput  => true,
      }
    }
    default: {
      fail("Unrecognized operating system")
    }
  }

  file { "/etc/init.d/dbora" :
    ensure         => present,
    mode           => "0755",
    owner          => 'root',
    content        => template("oradb/dbora.erb"),
  }

  exec { "set dbora ${dbName}:${oracleHome}":
    command        => "sed -i -e's/:N/:Y/g' /etc/oratab",
    unless         => "/bin/grep '^${dbName}:${oracleHome}:Y' /etc/oratab",
    require        => File["/etc/init.d/dbora"],
  }

  exec { "chkconfig dbora":
    command        => "chkconfig --add dbora",
    require        => File["/etc/init.d/dbora"],
    user           => 'root',
    unless         => "chkconfig | /bin/grep 'dbora'",
  }
}