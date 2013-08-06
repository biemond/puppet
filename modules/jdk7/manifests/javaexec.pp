# javaexec 
# unpack the java tar.gz
# set the default java links
# set this java as default
# update urandom for weblogic

define javaexec ($path        = undef, 
                 $fullversion = undef, 
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
      exec { "extract java ${fullversion}":
        cwd     => "${javaInstall}",
        command => "tar -xzf ${path}/${jdkfile}",
        creates => "${javaInstall}/${fullversion}",
        require => File[$javaInstall],
      }

			# java link to latest
      file { '/usr/java/latest':
        ensure      => link,
        target      => "/usr/java/${fullversion}",
        mode        => 0755,
        require     => Exec["extract java ${fullversion}"],
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
          exec { "default java alternatives ${fullversion}":
            command => "alternatives --install /usr/bin/java java /usr/java/${fullversion}/bin/java 17065",
            require => File['/usr/java/default'],
            unless  => "alternatives --display java | /bin/grep ${fullversion}",
          }
        }
        Ubuntu, Debian, SLES:{
			    # set the java default
          exec { "default java alternatives ${fullversion}":
            command => "update-alternatives --install /usr/bin/java java /usr/java/${fullversion}/bin/java 17065",
            require => File['/usr/java/default'],
            unless  => "update-alternatives --list java | /bin/grep ${fullversion}",
          }

        }

      }
        
      exec { "set urandom ${fullversion}":
       	command => "sed -i -e's/securerandom.source=file:\/dev\/urandom/securerandom.source=file:\/dev\/.\/urandom/g' /usr/java/${fullversion}/jre/lib/security/java.security",
        unless  => "/bin/grep '^securerandom.source=file:/dev/./urandom' /usr/java/${fullversion}/jre/lib/security/java.security",
        require => Exec["extract java ${fullversion}"],
      }

     
     }
   }

}
