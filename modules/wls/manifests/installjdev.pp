# == Define: wls::installjdev
#
# Downloads from file folder and install jdeveloper with a silent install on linux and windows servers 
#
#
# 

define wls::installjdev( $jdevFile    = undef, 
                         $fullJDKName = undef,
                         $mdwHome     = undef,
                         $soaAddon    = false,
                         $user        = 'oracle',
                         $group       = 'dba',
                         $downloadDir = '/install/',
                      ) {


   case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian: { 
        $path            = $downloadDir
        $wlHome          = "${mdwHome}/wlserver_10.3"
        $execPath        = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $javaHome        = "/usr/java/${fullJDKName}"
        
        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
        File {
               ensure  => present,
               mode    => 0775,
               owner   => $user,
               group   => $group,
             }   

        if ! defined(Group[$group]) {
          group { $group : 
                  ensure => present,
          }
        }
        if ! defined(User[$user]) {
          # http://raftaman.net/?p=1311 for generating password
          user { $user : 
              ensure     => present, 
              groups     => $group,
              shell      => '/bin/bash',
              password   => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',  
              home       => "/home/${user}",
              comment    => 'This user ${user} was created by Puppet',
              require    => Group[$group],
              managehome => true, 
          }
        }


     }
     default: { 
        fail("Unrecognized operating system") 
     }
   }


   if ! defined(File[$path]) {
      # check oracle install folder
      file { $path :
        path    => $path,
        ensure  => directory,
        recurse => false, 
        replace => false,
      }
   }

   if ! defined(File[$mdwHome]) {
      # check oracle jdev folder
      file { $mdwHome :
        path    => $mdwHome,
        ensure  => directory,
        recurse => false, 
        replace => false,
      }
   }

   
   # put weblogic generic jar
   file { "${jdevFile}":
     path    => "${path}${jdevFile}",
     ensure  => file,
     source  => "puppet:///modules/wls/${jdevFile}",
     require => File[$path],
     replace => false,
     backup  => false,
   }

   # de xml used by the wls installer
   file { "silent_jdeveloper.xml ${title}":
     path    => "${path}silent_jdeveloper.xml",
     ensure  => present,
     replace => 'yes',
     content => template("wls/silent_jdeveloper.xml.erb"),
     require => File[$path],
   }

   # install jdeveloper
   exec { "installjdev ${jdevFile}":
          command     => "java -jar ${path}${jdevFile} -mode=silent -silent_xml=${path}silent_jdeveloper.xml -log=${path}installJdev.log",
          environment => ["JAVA_HOME=/usr/java/${fullJDKName}",
                          "CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom"],
          require     => [File["${jdevFile}"],File["silent_jdeveloper.xml ${title}"],File[$mdwHome]],
          creates     => "${mdwHome}/jdeveloper",
   }    

   if ( $soaAddon == true ) { 
     # de xml used by the wls installer
     file { "jdeveloper soa addon ${title}":
       path    => "${path}soa-jdev-extension.zip",
       ensure  => present,
       replace => 'no',
       source  => "puppet:///modules/wls/soa-jdev-extension.zip",
       require => [File[$path],Exec["installjdev ${jdevFile}"]],
     }
     exec { "extract soa addon ${title}":
       command => "unzip -o ${path}soa-jdev-extension.zip",
       cwd     => "${mdwHome}/jdeveloper",
       require => [File[$path],Exec["installjdev ${jdevFile}"],File["jdeveloper soa addon ${title}"]],
       creates => "${mdwHome}/jdeveloper/jdev/extensions/oracle.sca.modeler.jar",
     }

     exec { "chmod soa jdev bin ${title}":
       command => "chmod -R 775 ${mdwHome}/jdeveloper/bin",
       require => [Exec["extract soa addon ${title}"],Exec["installjdev ${jdevFile}"]],
     }



   }

}
   