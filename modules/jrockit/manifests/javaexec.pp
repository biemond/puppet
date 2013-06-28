# javaexec 
# run the silent install
# set the default java links
# set this java as default

define javaexec ($path        = undef, 
                 $fullversion = undef, 
                 $jdkfile     = undef,
                 $setDefault  = undef,
                 $user        = undef,
                 $group       = undef,) {

  # install jdk
  case $operatingsystem {
    CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 

      $execPath     = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
			$javaInstall  = "/usr/java/"
      $silentfile   = "${path}silent${version}.xml"

      Exec {
        logoutput   => true,
        path        => $execPath,
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
      
      # Create the silent install xml
      file { "silent.xml ${version}":
        path    => "${silentfile}",
        ensure  => present,
        replace => 'yes',
        content => template("jrockit/jrockit-silent.xml.erb"),
        require => File[$path],
      }
  
      # Do the installation but only if the directry doesn't exist
      exec { "installjrockit":
        command     => "${jdkfile} -mode=silent -silent_xml=${silentfile}",
        cwd         => "${path}",
        path        => "${path}",
        logoutput   => true,
        require     => File["${silentfile}"],
        creates     => "/usr/java/${fullversion}",
      }
      
    	# java link to latest
      file { '/usr/java/latest':
        ensure      => link,
        target      => "/usr/java/${fullversion}",
        mode        => 0755,
        require     => Exec["installjrockit"],
      }

			# java link to default
      file { '/usr/java/default':
        ensure      => link,
        target      => "/usr/java/latest",
        mode        => 0755,
        require     => File['/usr/java/latest'],
      }

      # Add to alternatives and set as the default if required
      case $operatingsystem {
        CentOS, RedHat, OracleLinux: {
			    # set the java default
          exec { "install alternatives":
            command => "alternatives --install /usr/bin/java java /usr/java/${fullversion}/bin/java 17065",
            require => File['/usr/java/default'],
          }

          if $setDefault == 'true' {
            exec { "default alternatives":
              command => "alternatives --set java /usr/java/${fullversion}/bin/java",
              require => Exec['install alternatives'],
            }
          }

        }

        Ubuntu, Debian:{
			    # set the java default
          exec { "install alternatives":
            command => "update-alternatives --install /usr/bin/java java /usr/java/${fullversion}/bin/java 17065",
            require => File['/usr/java/default'],
          }

          if $setDefault == 'true' {
            exec { "default alternatives":
              command => "update-alternatives --set java /usr/java/${fullversion}/bin/java",
              require => Exec['install alternatives'],
            }
          }

        }
      }
    }
  }
}
