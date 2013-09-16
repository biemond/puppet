# javaexec 
# unpack the java tar.gz
# set the default java links
# set this java as default
# update urandom for weblogic

define javaexec ($path        = undef, 
                 $fullVersion = undef, 
                 $jdkfile     = undef,
                 $user        = undef,
                 $group       = undef,) {

   # install jdk
   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: { 

      $execPath         = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
			$javaInstall      = "/usr/java"

      Exec {
       path        => $execPath, 
       logoutput   => true,
       user        => $user,
       group       => $group,   
      }

      # check java install folder
      if ! defined(File[$javaInstall]) {
        file { $javaInstall :
          path    => $javaInstall,
          ensure  => directory,
          mode    => 0755,
        }
      }
      
      # extract gz file in /usr/java
      exec { "extract java ${fullVersion}":
        cwd     => "${javaInstall}",
        command => "tar -xzf ${path}/${jdkfile}",
        creates => "${javaInstall}/${fullVersion}",
        require => File[$javaInstall],
      }

			# java link to latest
      file { '/usr/java/latest':
        ensure      => link,
        target      => "/usr/java/${fullVersion}",
        mode        => 0755,
        require     => Exec["extract java ${fullVersion}"],
      }

			# java link to default
      file { '/usr/java/default':
        ensure      => link,
        target      => "/usr/java/latest",
        mode        => 0755,
        require     => File['/usr/java/latest'],
      }

      case $operatingsystem {
        CentOS, RedHat, OracleLinux: {
			    # set the java default
          exec { "default java alternatives ${fullVersion}":
            command => "alternatives --install /usr/bin/java java /usr/java/${fullVersion}/bin/java 17065",
            require => File['/usr/java/default'],
            unless  => "alternatives --display java | /bin/grep ${fullVersion}",
          }
        }
        Ubuntu, Debian, SLES:{
			    # set the java default
          exec { "default java alternatives ${fullVersion}":
            command => "update-alternatives --install /usr/bin/java java /usr/java/${fullVersion}/bin/java 17065",
            require => File['/usr/java/default'],
            unless  => "update-alternatives --list java | /bin/grep ${fullVersion}",
          }

        }

      }
     
     }
   }

}
