# == Class: oradb::dbactions
#
#
# action        =  stop|start
#
#
#  oradb::dbactions{ 'stop testDb':
#                   oracleHome  => '/oracle/product/11.2/db',
#                   user        => 'oracle',
#                   group       => 'dba',
#                   action      => 'stop',
#                   dbName      => 'test',
#  }
#
#
#
define oradb::dbactions( $oracleHome  = undef,
                         $user        = 'oracle',
                         $group       = 'dba',
                         $action      = 'start',
                         $dbName      = 'orcl',
)

{
  case $operatingsystem {
    CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {
      $execPath    = "${oracleHome}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
      Exec { path  => $execPath,
        user       => $user,
        group      => $group,
        logoutput  => true,
      }
      File {
        ensure     => present,
        mode       => 0775,
        owner      => $user,
        group      => $group,
      }
    }
    default: {
      fail("Unrecognized operating system")
    }
  }

  if $action == 'stop' {
    exec { "stop oracle database ${title}":
      command      => "sqlplus /nolog <<-EOF
connect / as sysdba
shutdown immediate
EOF",
      environment  => ["ORACLE_HOME=${oracleHome}", "ORACLE_SID=${dbName}", "LD_LIBRARY_PATH=${oracleHome}/lib"],
      logoutput    => true,
      onlyif       => "/bin/ps -ef | grep -v grep | /bin/grep 'ora_smon_${dbName}'",
    }
  } elsif $action == 'start' {
    exec { "start oracle database ${title}":
      command      => "sqlplus /nolog <<-EOF
connect / as sysdba
startup
EOF",
      environment  => ["ORACLE_HOME=${oracleHome}", "ORACLE_SID=${dbName}", "LD_LIBRARY_PATH=${oracleHome}/lib"],
      logoutput    => true,
      unless       => "/bin/ps -ef | grep -v grep | /bin/grep 'ora_smon_${dbName}'",
    }
  }
}