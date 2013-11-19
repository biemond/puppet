# == Define: wls::wlsdeploy
#
# wls deploy for OSB
#
#
# === Examples
#
#  case $operatingsystem {
#     CentOS, RedHat, OracleLinux, Ubuntu, Debian: {
#       $osMdwHome    = "/opt/oracle/wls/wls11g"
#       $osWlHome     = "/opt/oracle/wls/wls11g/wlserver_10.3"
#       $user         = "oracle"
#       $group        = "dba"
#     }
#     windows: {
#       $osMdwHome    = "c:/oracle/wls/wls11g"
#       $osWlHome     = "c:/oracle/wls/wls11g/wlserver_10.3"
#       $user         = "Administrator"
#       $group        = "Administrators"
#     }
#  }
#
#  # default parameters for the wlst scripts
#  Wls::Wlsdeploy {
#    wlHome       => $osWlHome,
#    osbHome      => $osbHome,
#    fullJDKName  => $jdkWls11gJDK,
#    user         => $user,
#    group        => $group,
#    address      => "localhost",
#    wlsUser      => "weblogic",
#    password     => "weblogic1",
#    port         => "7001",
#  }
#
#  # deploy OSB jar to the OSB server
#  wls::wlsdeploy {
#    'deployOSBallProjects':
#      deployType => 'osb',
#      artifact   => '/tmp/osb.jar',
#      customFile => 'None',
#      project    => 'None',
#  }
#
#

define wls::wlsdeploy ($wlHome        = undef,
											 $deployType    = 'weblogic',
                       $osbHome       = undef,
                       $fullJDKName   = undef,
                       $address       = "localhost",
                       $port          = '7001',
                       $wlsUser       = "weblogic",
                       $password      = "weblogic1",
                       $user          = 'oracle',
                       $group         = 'dba',
                       $artifact      = undef,
                       $customFile    = 'None',
                       $project       = 'None',
                       $downloadDir   = '/install/',
                      ) {

   notify {"wls::wlsdeploy ${title}":}

   $javaCommand    = "java -Dweblogic.security.SSL.ignoreHostnameVerification=true weblogic.WLST -skipWLSModuleScanning "

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path             = $downloadDir
        $JAVA_HOME        = "/usr/java/${fullJDKName}"

        if $deployType == 'weblogic' {
          $classpath = "${wlHome}/server/lib/weblogic.jar"
        }

        elsif $deployType == 'osb' {
          $classpath = "${wlHome}/server/lib/weblogic.jar:${osbHome}/modules/com.bea.core.xml.xmlbeans_2.2.0.0_2-5-1.jar:${osbHome}/lib/alsb.jar:${osbHome}/lib/sb-kernel-wls.jar:${osbHome}/lib/sb-kernel-impl.jar:${osbHome}/lib/sb-kernel-api.jar:${osbHome}/modules/com.bea.common.configfwk_1.6.0.0.jar"
        }

        else {
           fail("Unrecognized deployType choose weblogic or osb")
        }

        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => false,
             }
        File {
               ensure  => present,
               replace => true,
               mode    => 0555,
               owner   => $user,
               group   => $group,
               backup  => false,
             }
     }
     windows: {

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $path             = $downloadDir

        $JAVA_HOME        = "c:\\oracle\\${fullJDKName}"

        if $deployType == 'weblogic' {
          $classpath        = "${wlHome}\\server\\lib\\weblogic.jar"
        }

        elsif $deployType == 'osb' {
          $classpath        = "${wlHome}\\server\\lib\\weblogic.jar;${osbHome}\\modules\\com.bea.core.xml.xmlbeans_2.2.0.0_2-5-1.jar;${osbHome}\\lib\\alsb.jar;${osbHome}\\lib\\sb-kernel-wls.jar;${osbHome}\\lib\\sb-kernel-impl.jar;${osbHome}\\lib\\sb-kernel-api.jar;${osbHome}\\modules\\com.bea.common.configfwk_1.6.0.0.jar"
        }

        else {
           fail("Unrecognized deployType choose weblogic or osb")
        }

        Exec { path      => $execPath,
               logoutput => true,
             }
        File { ensure  => present,
               replace => true,
               mode    => 0777,
               backup  => false,
             }
     }
   }


   # the py script used by the wlst
   file { "${path}/${title}importOSB.py":
      path    => "${path}/${title}importOSB.py",
      content => template("wls/importOSB.py.erb"),
   }

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        exec { "execwlst ${title}importOSB.py":
          command     => "${javaCommand} ${path}/${title}importOSB.py",
          environment => ["CLASSPATH=${classpath}",
                          "JAVA_HOME=${JAVA_HOME}"],
          require     => File["${path}/${title}importOSB.py"],
        }

        exec { "rm ${path}/${title}importOSB.py":
           command => "rm ${path}/${title}importOSB.py",
           require => Exec["execwlst ${title}importOSB.py"],
        }

     }
     windows: {

        exec { "execwlst ${title}importOSB.py":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${javaCommand} ${path}/${title}importOSB.py",
          environment => ["CLASSPATH=${classpath}",
                          "JAVA_HOME=${JAVA_HOME}"],
          require     => File["${path}/${title}importOSB.py"],
        }


        exec { "rm ${path}/${title}importOSB.py":
           command => "C:\\Windows\\System32\\cmd.exe /c del ${path}/${title}importOSB.py",
           require => Exec["execwlst ${title}importOSB.py"],
        }
     }
   }
}

