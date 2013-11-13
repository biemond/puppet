# == Define: wls::wlsdomain
#
# install a new weblogic domain
# support a normal WebLogic Domain , OSB , OSB plus SOA, OSB plus SOA & BPM , ADF , Webcenter, Webcenter + Content + BPM
# use parameter wlsTemplate to control this
#
# in weblogic 12.1.2 the domain creation will also create a nodemanager inside the domain folder
# other version need to manually create a nodemanager.
#
# === Examples
#
#  $jdkWls11gJDK = 'jdk1.7.0_09'
#
#  $wlsDomainName   = "osbDomain"
#  $osTemplate      = "osb"
#  $osTemplate      = "standard"
#  $adminListenPort = "7001"
#  $nodemanagerPort = "5556"
#  $address         = "localhost"
#  $wlsUser         = "weblogic"
#  $password        = "weblogic1"
#
#
#  case $operatingsystem {
#     centos, redhat, OracleLinux, Ubuntu, debian: {
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
#       $serviceName  = "C_oracle_wls_wls11g_wlserver_10.3"
#     }
#  }
#
#  # set the defaults
#
#  Wls::Wlsdomain {
#    wlHome       => $osWlHome,
#    mdwHome      => $osMdwHome,
#    fullJDKName  => $jdkWls11gJDK,
#    user         => $user,
#    group        => $group,
#  }
#
# # install OSB domain
# wls::wlsdomain{
#
#   'osbDomain':
#   wlsTemplate     => $osTemplate,
#   domain          => $wlsDomainName,
#   domainPath      => $osDomainPath,
#   adminListenPort => $adminListenPort,
#   nodemanagerPort => $nodemanagerPort,
# }
##
#

define wls::wlsdomain ($version         = '1111',
                       $wlHome          = undef,
                       $mdwHome         = undef,
                       $fullJDKName     = undef,
                       $wlsTemplate     = "standard",
                       $domain          = undef,
                       $developmentMode = true,
                       $adminServerName = "AdminServer",
                       $adminListenAdr  = "localhost",
                       $adminListenPort = '7001',
                       $nodemanagerPort = '5556',
                       $wlsUser         = undef,
                       $password        = undef,
                       $user            = 'oracle',
                       $group           = 'dba',
                       $logDir          = undef,
                       $downloadDir     = '/install',
                       $reposDbUrl      = undef,
                       $reposPrefix     = undef,
                       $reposPassword   = undef,
                       $dbUrl           = undef,
                       $sysPassword     = undef,
                       ) {

   $domainPath  = "${mdwHome}/user_projects/domains"
   $appPath     = "${mdwHome}/user_projects/applications"

   # check if the domain already exists
   $found = domain_exists("${domainPath}/${domain}",$version)
   if $found == undef {
     $continue = true
   } else {
     if ( $found ) {
       $continue = false
     } else {
       notify {"wls::wlsdomain ${title} ${domainPath}/${domain} ${version} does not exists":}
       $continue = true
     }
   }


if ( $continue ) {

   if $version == "1111" {

     $template             = "${wlHome}/common/templates/domains/wls.jar"
     $templateWS           = "${wlHome}/common/templates/applications/wls_webservice.jar"
     $templateJaxWS        = "${mdwHome}/oracle_common/common/templates/applications/wls_webservice_jaxws.jar"

     $templateEM           = "${mdwHome}/oracle_common/common/templates/applications/oracle.em_11_1_1_0_0_template.jar"
     $templateJRF          = "${mdwHome}/oracle_common/common/templates/applications/jrf_template_11.1.1.jar"
     $templateApplCore     = "${mdwHome}/oracle_common/common/templates/applications/oracle.applcore.model.stub.11.1.1_template.jar"
     $templateWSMPM        = "${mdwHome}/oracle_common/common/templates/applications/oracle.wsmpm_template_11.1.1.jar"

   } elsif $version == "1121" {

     $template             = "${wlHome}/common/templates/domains/wls.jar"
     $templateWS           = "${wlHome}/common/templates/applications/wls_webservice.jar"
     $templateJaxWS        = "${mdwHome}/oracle_common/common/templates/applications/wls_webservice_jaxws.jar"

     $templateEM           = "${mdwHome}/oracle_common/common/templates/applications/oracle.em_11_1_1_0_0_template.jar"
     $templateJRF          = "${mdwHome}/oracle_common/common/templates/applications/jrf_template_11.1.1.jar"
     $templateApplCore     = "${mdwHome}/oracle_common/common/templates/applications/oracle.applcore.model.stub.11.1.1_template.jar"
     $templateWSMPM        = "${mdwHome}/oracle_common/common/templates/applications/oracle.wsmpm_template_11.1.1.jar"

     $templateOIM          = "${mdwHome}/Oracle_IDM1/common/templates/applications/oracle.oim_11.1.2.0.0_template.jar"
     $templateOAM          = "${mdwHome}/Oracle_IDM1/common/templates/applications/oracle.oam_ds_11.1.2.0.0_template.jar"

   } elsif $version == "1212" {

     $template             = "${wlHome}/common/templates/wls/wls.jar"
     $templateWS           = "${wlHome}/common/templates/wls/wls_webservice.jar"
     $templateJaxWS        = "${wlHome}/common/templates/wls/wls_webservice_jaxws.jar"
     $templateSoapJms      = "${wlHome}/common/templates/wls/wls_webservice_soapjms.jar"
     $templateCoherence    = "${wlHome}/common/templates/wls/wls_coherence.jar"

     $templateEM           = "${mdwHome}/em/common/templates/wls/oracle.em_wls_template_12.1.2.jar"
     $templateJRF          = "${mdwHome}/oracle_common/common/templates/wls/oracle.jrf_template_12.1.2.jar"
     $templateApplCore     = "${mdwHome}/oracle_common/common/templates/applications/oracle.applcore.model.stub.12.1.3_template.jar"
     $templateWSMPM        = "${mdwHome}/oracle_common/common/templates/wls/oracle.wsmpm_template_12.1.2.jar"


   } else {

     $template             = "${wlHome}/common/templates/domains/wls.jar"
     $templateWS           = "${wlHome}/common/templates/applications/wls_webservice.jar"

     $templateEM           = "${mdwHome}/oracle_common/common/templates/applications/oracle.em_11_1_1_0_0_template.jar"
     $templateJRF          = "${mdwHome}/oracle_common/common/templates/applications/jrf_template_11.1.1.jar"
     $templateJaxWS        = "${mdwHome}/oracle_common/common/templates/applications/wls_webservice_jaxws.jar"
     $templateApplCore     = "${mdwHome}/oracle_common/common/templates/applications/oracle.applcore.model.stub.11.1.1_template.jar"
     $templateWSMPM        = "${mdwHome}/oracle_common/common/templates/applications/oracle.wsmpm_template_11.1.1.jar"

   }


   $templateOSB          = "${mdwHome}/Oracle_OSB1/common/templates/applications/wlsb.jar"
   $templateSOAAdapters  = "${mdwHome}/Oracle_OSB1/common/templates/applications/oracle.soa.common.adapters_template_11.1.1.jar"

   $templateSOA          = "${mdwHome}/Oracle_SOA1/common/templates/applications/oracle.soa_template_11.1.1.jar"
   $templateBPM          = "${mdwHome}/Oracle_SOA1/common/templates/applications/oracle.bpm_template_11.1.1.jar"
   $templateBAM          = "${mdwHome}/Oracle_SOA1/common/templates/applications/oracle.bam_template_11.1.1.jar"



   $templateSpaces       = "${mdwHome}/Oracle_WC1/common/templates/applications/oracle.wc_spaces_template_11.1.1.jar"
   $templateBPMSpaces    = "${mdwHome}/Oracle_WC1/common/templates/applications/oracle.bpm.spaces_template_11.1.1.jar"
   $templatePortlets     = "${mdwHome}/Oracle_WC1/common/templates/applications/oracle.producer_apps_template_11.1.1.jar"
   $templatePagelet      = "${mdwHome}/Oracle_WC1/common/templates/applications/oracle.pagelet-producer_template_11.1.1.jar"
   $templateDiscussion   = "${mdwHome}/Oracle_WC1/common/templates/applications/oracle.owc_discussions_template_11.1.1.jar"

   $templateUCM          = "${mdwHome}/Oracle_WCC1/common/templates/applications/oracle.ucm.cs_template_11.1.1.jar"


   if $wlsTemplate == 'standard' {
      $templateFile  = "wls/domains/domain.xml.erb"
      $wlstPath      = "${wlHome}/common/bin"

   } elsif $wlsTemplate == 'oim' {
      $templateFile  = "wls/domains/domain_oim.xml.erb"
      $wlstPath      = "${mdwHome}/Oracle_IDM1/common/bin"
      $oracleHome    = "${mdwHome}/Oracle_IDM1"

   } elsif $wlsTemplate == 'osb' {
      $templateFile  = "wls/domains/domain_osb.xml.erb"
      $wlstPath      = "${mdwHome}/Oracle_OSB1/common/bin"
      $oracleHome    = "${mdwHome}/Oracle_OSB1"

   } elsif $wlsTemplate == 'osb_soa' {
      $templateFile  = "wls/domains/domain_osb_soa.xml.erb"
      $wlstPath      = "${mdwHome}/Oracle_SOA1/common/bin"
      $oracleHome    = "${mdwHome}/Oracle_SOA1"

   } elsif $wlsTemplate == 'adf' {
      $templateFile  = "wls/domains/domain_adf.xml.erb"
      $wlstPath      = "${mdwHome}/oracle_common/common/bin"
      $oracleHome    = "${mdwHome}/oracle_common"

   } elsif $wlsTemplate == 'osb_soa_bpm' {
      $templateFile  = "wls/domains/domain_osb_soa_bpm.xml.erb"
      $wlstPath      = "${mdwHome}/Oracle_SOA1/common/bin"
      $oracleHome    = "${mdwHome}/Oracle_SOA1"

   } elsif $wlsTemplate == 'wc' {
      $templateFile  = "wls/domains/domain_wc.xml.erb"
      $wlstPath      = "${mdwHome}/Oracle_WC1/common/bin"
      $oracleHome    = "${mdwHome}/Oracle_WC1"

   } elsif $wlsTemplate == 'wc_wcc_bpm' {
      $templateFile  = "wls/domains/domain_wc_wcc_bpm.xml.erb"
      $wlstPath      = "${mdwHome}/Oracle_WCC1/common/bin"
      $oracleHome    = "${mdwHome}/Oracle_WCC1"

   } else {
      $templateFile  = "wls/domains/domain.xml.erb"
      $wlstPath      = "${wlHome}/common/bin"
   }

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {

        $execPath         = "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"
        $path             = $downloadDir
        $JAVA_HOME        = "/usr/java/${fullJDKName}"
        $nodeMgrMachine   = "UnixMachine"


        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
        File {
               ensure  => present,
               replace => true,
               mode    => 0775,
               owner   => $user,
               group   => $group,
               backup  => false,
             }
     }
     Solaris: {

        $execPath         = "/usr/jdk/${fullJDKName}/bin/amd64:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"
        $path             = $downloadDir
        $JAVA_HOME        = "/usr/jdk/${fullJDKName}"
        $nodeMgrMachine   = "UnixMachine"


        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
        File {
               ensure  => present,
               replace => true,
               mode    => 0775,
               owner   => $user,
               group   => $group,
               backup  => false,
             }

     }
     windows: {

        $execPath         = "C:\\oracle\\${fullJDKName}\\bin;C:\\unxutils\\bin;C:\\unxutils\\usr\\local\\wbin;C:\\Windows\\system32;C:\\Windows"
        $path             = $downloadDir
        $JAVA_HOME        = "c:\\oracle\\${fullJDKName}"
        $nodeMgrMachine   = "Machine"
        $checkCommand     = "C:\\Windows\\System32\\cmd.exe /c"

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


   if $logDir == undef {

      $adminNodeMgrLogDir             = "${domainPath}/${domain}/servers/${adminServerName}/logs"
      $osbNodeMgrLogDir               = "${domainPath}/${domain}/servers/osb_server1/logs"
      $soaNodeMgrLogDir               = "${domainPath}/${domain}/servers/soa_server1/logs"
      $bamNodeMgrLogDir               = "${domainPath}/${domain}/servers/bam_server1/logs"

      $oimNodeMgrLogDir               = "${domainPath}/${domain}/servers/oim_server1/logs"
      $oamNodeMgrLogDir               = "${domainPath}/${domain}/servers/oam_server1/logs"

      $wcCollaborationNodeMgrLogDir   = "${domainPath}/${domain}/servers/WC_Collaboration/logs"
      $wcPortletNodeMgrLogDir         = "${domainPath}/${domain}/servers/WC_Portlet/logs"
      $wcSpacesNodeMgrLogDir          = "${domainPath}/${domain}/servers/WC_Spaces/logs"
      $umcNodeMgrLogDir               = "${domainPath}/${domain}/servers/UCM_server1/logs"

      $nodeMgrLogDir                  = "${domainPath}/${domain}/nodemanager/nodemanager.log"


   } else {
      $adminNodeMgrLogDir = "${logDir}"
      $osbNodeMgrLogDir   = "${logDir}"
      $soaNodeMgrLogDir   = "${logDir}"
      $bamNodeMgrLogDir   = "${logDir}"

      $oimNodeMgrLogDir   = "${logDir}"
      $oamNodeMgrLogDir   = "${logDir}"


      $wcCollaborationNodeMgrLogDir   = "${logDir}"
      $wcPortletNodeMgrLogDir         = "${logDir}"
      $wcSpacesNodeMgrLogDir          = "${logDir}"
      $umcNodeMgrLogDir               = "${logDir}"

      $nodeMgrLogDir                  = "${logDir}/nodemanager_${domain}.log"

      # create all log folders
      case $operatingsystem {
         CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {
           if ! defined(Exec["create ${logDir} directory"]) {
             exec { "create ${logDir} directory":
                     command => "mkdir -p ${logDir}",
                     unless  => "test -d ${logDir}",
                     user    => 'root',
             }
           }
         }
         windows: {
           $logDirWin = slash_replace( $logDir )
           if ! defined(Exec["create ${logDir} directory"]) {
             exec { "create ${logDir} directory":
                  command => "${checkCommand} mkdir ${logDirWin}",
                  unless  => "${checkCommand} dir ${logDirWin}",
             }
           }
         }
         default: {
           fail("Unrecognized operating system")
         }
      }

      if ! defined(File["${logDir}"]) {
           file { "${logDir}" :
             ensure  => directory,
             recurse => false,
             replace => false,
             require => Exec["create ${logDir} directory"],
           }
      }
   }

   if ( $version == "1212" and $wlsTemplate == 'adf' ) {
     # only works for a 12c middleware home
     # creates RCU for ADF
     if ( $dbUrl == undefined or
          $sysPassword  == undefined or
          $reposPassword  == undefined or
          $reposPrefix  == undefined
     ) {
       fail("Not all RCU parameters are provided")
     }

     wls::utils::rcu{ "RCU_12c ${title}":
                     product                => 'adf',
                     oracleHome             => $oracleHome,
                     fullJDKName            => $fullJDKName,
                     user                   => $user,
                     group                  => $group,
                     downloadDir            => $downloadDir,
                     action                 => 'create',
                     dbUrl                  => $dbUrl,
                     sysPassword            => $sysPassword,
                     schemaPrefix           => $reposPrefix,
                     reposPassword          => $reposPassword,
                     notify                 => File["domain.py ${domain} ${title}"]
    }
   }


   # the domain.py used by the wlst
   file { "domain.py ${domain} ${title}":
     path    => "${path}/domain_${domain}.py",
     content => template($templateFile),
   }

   # make the default domain folders
   if ! defined(File["${mdwHome}/user_projects"]) {
      # check oracle install folder
      file { "${mdwHome}/user_projects" :
        ensure  => directory,
        recurse => false,
        replace => false,
      }
   }

   if ! defined(File["${mdwHome}/user_projects/domains"]) {
      # check oracle install folder
      file { "${mdwHome}/user_projects/domains" :
        ensure  => directory,
        recurse => false,
        replace => false,
        require => File["${mdwHome}/user_projects"],
      }
   }

   if ! defined(File["${mdwHome}/user_projects/applications"]) {
      # check oracle install folder
      file { "${mdwHome}/user_projects/applications" :
        ensure  => directory,
        recurse => false,
        replace => false,
        require => File["${mdwHome}/user_projects"],
      }
   }

#   $packCommand    = "-domain=${domainPath}/${domain} -template=${path}/domain_${domain}.jar -template_name=domain_${domain} -log=${path}/domain_${domain}.log -log_priority=INFO"

   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {

        exec { "execwlst ${domain} ${title}":
          command     => "${wlstPath}/wlst.sh ${path}/domain_${domain}.py",
          environment => ["JAVA_HOME=${JAVA_HOME}"],
          unless      => "/usr/bin/test -e ${domainPath}/${domain}",
          creates     => "${domainPath}/${domain}",
          require     => [File["domain.py ${domain} ${title}"],File["${mdwHome}/user_projects/domains"],File["${mdwHome}/user_projects/applications"]],
          timeout     => 0,
        }

        if ($wlsTemplate == 'oim') {

          exec { "execwlst create OPSS store ${domain} ${title}":
            command     => "${wlstPath}/wlst.sh ${mdwHome}/Oracle_IDM1/common/tools/configureSecurityStore.py -d ${domainPath}/${domain} -m create -c IAM -p ${reposPassword}",
            environment => ["JAVA_HOME=${JAVA_HOME}"],
            require     => Exec["execwlst ${domain} ${title}"],
            timeout     => 0,
          }

          exec { "execwlst validate OPSS store ${domain} ${title}":
            command     => "${wlstPath}/wlst.sh ${mdwHome}/Oracle_IDM1/common/tools/configureSecurityStore.py -d ${domainPath}/${domain} -m validate",
            environment => ["JAVA_HOME=${JAVA_HOME}"],
            require     => [Exec["execwlst ${domain} ${title}"],Exec["execwlst create OPSS store ${domain} ${title}"]],
            timeout     => 0,
          }

        }

        case $operatingsystem {
           CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {
              exec { "setDebugFlagOnFalse ${domain} ${title}":
                command => "sed -i -e's/debugFlag=\"true\"/debugFlag=\"false\"/g' ${domainPath}/${domain}/bin/setDomainEnv.sh",
                onlyif  => "/bin/grep debugFlag=\"true\" ${domainPath}/${domain}/bin/setDomainEnv.sh | /usr/bin/wc -l",
                require => Exec["execwlst ${domain} ${title}"],
              }
              exec { "domain.py ${domain} ${title}":
                command     => "rm -I ${path}/domain_${domain}.py",
                require     => Exec["execwlst ${domain} ${title}"],
              }
           }
           Solaris: {
             exec { "setDebugFlagOnFalse ${domain} ${title}":
               command => "sed -e's/debugFlag=\"true\"/debugFlag=\"false\"/g' ${domainPath}/${domain}/bin/setDomainEnv.sh > /tmp/test.tmp && mv /tmp/test.tmp ${domainPath}/${domain}/bin/setDomainEnv.sh",
               onlyif  => "/bin/grep debugFlag=\"true\" ${domainPath}/${domain}/bin/setDomainEnv.sh | /usr/bin/wc -l",
               require => Exec["execwlst ${domain} ${title}"],
             }
             exec { "domain.py ${domain} ${title}":
                command     => "rm ${path}/domain_${domain}.py",
                require     => Exec["execwlst ${domain} ${title}"],
             }
           }
        }

#        exec { "pack domain ${domain} ${title}":
#           command     => "${wlHome}/common/bin/pack.sh ${packCommand}",
#           require     => Exec["setDebugFlagOnFalse ${domain} ${title}"],
#           creates     => "${path}/domain_${domain}.jar",
#        }

     }
     windows: {

        notify{"${domainPath}/${domain} ${title}":}

        exec { "execwlst ${domain} ${title}":
          command     => "C:\\Windows\\System32\\cmd.exe /c ${wlstPath}/wlst.cmd ${path}/domain_${domain}.py",
          environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                          "JAVA_HOME=${JAVA_HOME}"],
          creates     => "${domainPath}/${domain}",
          require     => [File["domain.py ${domain} ${title}"],File["${mdwHome}/user_projects/domains"],File["${mdwHome}/user_projects/applications"]],
          timeout     => 0,
        }

        exec {"icacls domain ${title}":
           command    => "C:\\Windows\\System32\\cmd.exe /c  icacls ${domainPath}/${domain} /T /C /grant Administrator:F Administrators:F",
           logoutput  => false,
           require   => Exec["execwlst ${domain} ${title}"],
        }

        exec { "domain.py ${domain} ${title}":
           command     => "C:\\Windows\\System32\\cmd.exe /c rm ${path}/domain_${domain}.py",
           require   => Exec["icacls domain ${title}"],
          }

#        exec { "pack domain ${domain} ${title}":
#           command     => "C:\\Windows\\System32\\cmd.exe /c ${wlHome}/common/bin/pack.cmd ${packCommand}",
#           require   => Exec["icacls domain ${title}"],
#           creates     => "${path}/domain_${domain}.jar",
#        }
     }
   }

   $nodeMgrHome  = "${domainPath}/${domain}/nodemanager"
   $listenPort   = $nodemanagerPort

   # set our 12.1.2 nodemanager properties
   if ( $version == "1212" ){
       case $operatingsystem {
          CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES, Solaris: {
            file { "nodemanager.properties ux 1212 ${title}":
                path    => "${nodeMgrHome}/nodemanager.properties",
                ensure  => present,
                replace => 'yes',
                content => template("wls/nodemgr/nodemanager.properties_1212.erb"),
                require => Exec["execwlst ${domain} ${title}"],
            }
          }
         windows: {
            file { "nodemanager.properties ux 1212 ${title}":
                path    => "${nodeMgrHome}/nodemanager.properties",
                ensure  => present,
                replace => 'yes',
                content => template("wls/nodemgr/nodemanager.properties_1212.erb"),
                require => Exec["execwlst ${domain} ${title}"],
            }
            exec {"icacls win nodemanager bin ${title}":
               command    => "${checkCommand} icacls ${wlHome}\\server\\bin\\* /T /C /grant Administrator:F Administrators:F",
               logoutput  => false,
            }
            exec {"icacls win nodemanager native ${title}":
               command    => "${checkCommand} icacls ${wlHome}\\server\\native\\* /T /C /grant Administrator:F Administrators:F",
               logoutput  => false,
            }
            exec { "execwlst win nodemanager ${title}":
              command     => "${domainPath}/${domain}/bin/installNodeMgrSvc.cmd",
              environment => ["CLASSPATH=${wlHome}\\server\\lib\\weblogic.jar",
                              "JAVA_HOME=${JAVA_HOME}"],
              cwd         => "${domainPath}/${domain}/bin",
              require     => [Exec ["icacls win nodemanager bin ${title}"],
                              Exec ["icacls win nodemanager native ${title}"],
                              File["nodemanager.properties ux 1212 ${title}"]],
              logoutput   => true,
            }
         }
       }
     }
}
}
