Oracle WebLogic / Fusion Middleware puppet module
=================================================

created by Edwin Biemond<br>
[biemond.blogspot.com](http://biemond.blogspot.com)<br>
[Github homepage](https://github.com/biemond/puppet)<br>

for more infomation about this Oracle WebLogic / FMW puppet module see this [AMIS blogpost](http://technology.amis.nl/2012/10/13/configure-fmw-servers-with-puppet/)

Windows agents
--------------
for windows puppet agents it is necessary to install unxutils tools and extract this on the c drive C:\unxutils<br>
For windows and JDK, you need copy the jdk to c:\oracle\ ( unpossible with the space in c:\program files folder).<br>

Also for registry support install this on the master, read this [registry blogpost](http://puppetlabs.com/blog/module-of-the-week-puppetlabs-registry-windows/) and install this forge module on the puppet master<br>
puppet module install puppetlabs/registry

WLS WebLogic Features
---------------------------

- installs weblogic
- installs OSB with or without OEPE ( Oracle Eclipse )
- configures + starts nodemanager
- domain creation
- domain OSB creation
- can start the AdminServer for configuration 
- apply bsu patch ( WebLogic Patch )
- create File or JDBC Persistence Store
- create JMS Server
- create JMS Module
- create JMS subdeployment
- create JMS connection factory
- create JMS queue or topic
- create users with group
- create SAF agents 
- create SAF Remote Destinations
- create SAf imported Destinations
- create SAF objects
- create Foreign Servers
- create Foreign Servers entries
- run every wlst script with the flexible WLST define
- deploy an OSB project to the OSB server


WLS WebLogic Facter
-------------------

- Contains WebLogic Facter which displays 
- Middleware homes
- Domains
- Domain configuration ( deployments, datasource, JMS, SAF)
- running nodemanagers
- running WebLogic servers

Example of the WebLogic Facts 

oracle installed products<br>
ora_inst_loc_data /opt/oracle/orainventory<br>
ora_inst_products /opt/oracle/wls/wls11g/oracle_common;/opt/oracle/wls/wls11g/Oracle_OSB1;<br>

Middleware home 0<br>
ora_mdw_0 /opt/oracle/wls/wls11g<br>

BSU patches on the Middleware home<br>
ora_mdw_0_bsu KZKQ;<br>

Domain 0<br>
ora_mdw_0_domain_0  osbDomain<br>
ora_mdw_0_domain_0_deployments  FMW Welcome Page Application#11.1.0.0.0<br>
ora_mdw_0_domain_0_filestores FileStore;WseeFileStore;jmsModuleFilePersistence;<br>
ora_mdw_0_domain_0_jdbc wlsbjmsrpDataSource;hrDS;jmsDS;<br>
ora_mdw_0_domain_0_jdbcstores jmsModuleJdbcPersistence;<br>
ora_mdw_0_domain_0_jmsmodule_0_name WseeJmsModule<br>
ora_mdw_0_domain_0_jmsmodule_0_objects  WseeMessageQueue;WseeCallbackQueue;<br>
ora_mdw_0_domain_0_jmsmodule_0_subdeployments BEA_JMS_MODULE_SUBDEPLOYMENT_WSEEJMSServer;<br>
ora_mdw_0_domain_0_jmsmodule_1_name jmsResources<br>
ora_mdw_0_domain_0_jmsmodule_1_objects  wli.reporting.jmsprovider.ConnectionFactory<br>
ora_mdw_0_domain_0_jmsmodule_1_subdeployments weblogic.wlsb.jms.transporttask.QueueConnectionFactory;wlsbJMSServer;<br>
ora_mdw_0_domain_0_jmsmodule_2_name jmsModule<br>
ora_mdw_0_domain_0_jmsmodule_2_objects  cf;ErrorQueue;Queue1;Topic1;<br>
ora_mdw_0_domain_0_jmsmodule_2_subdeployments wlsServer;JmsServer;<br>
ora_mdw_0_domain_0_jmsmodule_cnt  3<br>
ora_mdw_0_domain_0_jmsmodules WseeJmsModule;jmsResources;jmsModule;<br>
ora_mdw_0_domain_0_jmsservers WseeJmsServer;jmsServer;jmsServer2;wlsbJMSServer;<br>
ora_mdw_0_domain_0_libraries  oracle.bi.jbips#11.1.1@0.1;oracle.bi.composer#11.1.1@0.1<br>
ora_mdw_0_domain_0_safagents  jmsModuleJdbcPersistence;<br>
ora_mdw_0_domain_0_server_0 AdminServer<br>
ora_mdw_0_domain_0_server_0_machine LocalMachine<br>
ora_mdw_0_domain_0_server_1 osb_server1<br>
ora_mdw_0_domain_0_server_1_machine LocalMachine<br>
ora_mdw_0_domain_0_server_1_port  8011<br>

Domains in first middleware home<br>
ora_mdw_0_domain_cnt  1<br>

Middleware home counts<br>
ora_mdw_cnt 1<br>
ora_mdw_homes /opt/oracle/wls/wls11g;<br>

Running node managers + WebLogic Servers<br>
ora_node_mgr_0  pid: 26113 port: 5556<br>
ora_wls_0 pid: 26198 name: AdminServer<br>



Example of my Files folder in the wls module
--------------------------------------------
oepe-indigo-all-in-one-11.1.1.8.0.201110211138-linux-gtk-x86_64.zip<br>
ofm_osb_generic_11.1.1.6.0_disk1_1of1.zip<br>
p13573621_1036_Generic.zip<br>
wls1036_generic.jar<br>
wls1211_generic.jar<br>

WebLogic configuration examples
-------------------------------


templates_app.pp
----------------

```
include wls

class application_osb {

   include wls1036osb, wls_osb_domain, wls_OSB_application_JDBC, wls_OSB_application_JMS, wls_OSB_application_jar
   Class['wls1036osb'] -> Class['wls_osb_domain'] -> Class['wls_OSB_application_JDBC'] -> Class['wls_OSB_application_JMS'] -> Class['wls_OSB_application_jar']
}

class application_wls12 {

   include wls12, wls12c_domain
   Class['wls12'] -> Class['wls12c_domain']
}


class wls_OSB_application_jar {

  if $groupId == undef {
    $groupId = "biemond"
  }

  if $artifactId == undef {
    $artifactId = "osb.all.projects"
  }

  if $version == undef {
    $version = "1.3.6"
  }


  if $jdkWls11gJDK == undef {
    $jdkWls11gJDK = 'jdk1.7.0_09'
  }

  $osbHome      = "/opt/oracle/wls/wls11g/Oracle_OSB1"
  $osWlHome     = "/opt/oracle/wls/wls11g/wlserver_10.3"
  $user         = "oracle"
  $group        = "dba"

  artifactory::artifact {"/tmp/${artifactId}-${version}.zip":
     ensure     => present,
     gav        => "${groupId}:${artifactId}:${version}",
     repository => "libs-release-local",
     packaging  => "zip",
     classifier => "bin", 
  }

  Exec { path      => "/usr/java/${fullJDKName}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:",
         user      => $user,
         group     => $group,
         logoutput => false,
  }

  exec { "extract OSBAllProjects":
          command => "unzip -j -o /tmp/${artifactId}-${version}.zip *.jar -d /tmp/OSBAllProjects",
          require => Artifactory::Artifact["/tmp/${artifactId}-${version}.zip"],
  }

  # default parameters for the wlst scripts
  Wls::Wlsdeploy {
    wlHome       => $osWlHome,
    osbHome      => $osbHome,
    fullJDKName  => $jdkWls11gJDK,  
    user         => $user,
    group        => $group,
    address      => "localhost",
    wlsUser      => "weblogic",
    password     => "weblogic1",
    port         => "7001",
  }


  # deploy OSB jar to the OSB server 
  wls::wlsdeploy { "deployOSBAllProjects":
      deployType => 'osb',
      artifact   => "/tmp/OSBAllProjects/${artifactId}-${version}.jar",
      customFile => "None",
      project    => "None",
      require    => Exec["extract OSBAllProjects"],
  }

  exec { "delete ${title} unzip folder ":
      command => "rm -R -f /tmp/OSBAllProjects",
      require => Wls::Wlsdeploy["deployOSBAllProjects"],
  }


}



class wls_OSB_application_JDBC{


  if $jdkWls11gJDK == undef {
    $jdkWls11gJDK = 'jdk1.7.0_09'
  }

  case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
       $osMdwHome    = "/opt/oracle/wls/wls11g"
       $osWlHome     = "/opt/oracle/wls/wls11g/wlserver_10.3"
       $osDomainPath = "/opt/oracle/wls/wls11g/admin"
       $user         = "oracle"
       $group        = "dba"
     }
     windows: { 
       $osMdwHome    = "c:/oracle/wls/wls11g"
       $osWlHome     = "c:/oracle/wls/wls11g/wlserver_10.3"
       $osDomainPath = "c:/oracle/wls/wls11g/admin"
       $user         = "Administrator"
       $group        = "Administrators"
       $serviceName  = "C_oracle_wls_wls11g_wlserver_10.3"
     }
  }

  # default parameters for the wlst scripts
  Wls::Wlstexec {
    wlsDomain    => "${osDomainPath}/osbDomain",
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls11gJDK,  
    user         => $user,
    group        => $group,
    address      => "localhost",
    wlsUser      => "weblogic",
    password     => "weblogic1",
    port         => "7001",
  }

  # create jdbc datasource for osb_server1 
  wls::wlstexec { 
  
    'createJdbcDatasourceHr':
     wlstype       => "jdbc",
     wlsObjectName => "hrDS",
     script        => 'createJdbcDatasource.py',
     params        => ["dsName                      = 'hrDS'",
                      "jdbcDatasourceTargets       = 'AdminServer,osb_server1'",
                      "dsJNDIName                  = 'jdbc/hrDS'",
                      "dsDriverName                = 'oracle.jdbc.xa.client.OracleXADataSource'",
                      "dsURL                       = 'jdbc:oracle:thin:@master.alfa.local:1521/XE'",
                      "dsUserName                  = 'hr'",
                      "dsPassword                  = 'hr'",
                      "datasourceTargetType        = 'Server'",
                      "globalTransactionsProtocol  = 'xxxx'"
                      ],
  }

}  




class wls_OSB_application_JMS{


  if $jdkWls11gJDK == undef {
    $jdkWls11gJDK = 'jdk1.7.0_09'
  }


  case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
       $osMdwHome    = "/opt/oracle/wls/wls11g"
       $osWlHome     = "/opt/oracle/wls/wls11g/wlserver_10.3"
       $osDomainPath = "/opt/oracle/wls/wls11g/admin"
       $user         = "oracle"
       $group        = "dba"
     }
     windows: { 
       $osMdwHome    = "c:/oracle/wls/wls11g"
       $osWlHome     = "c:/oracle/wls/wls11g/wlserver_10.3"
       $osDomainPath = "c:/oracle/wls/wls11g/admin"
       $user         = "Administrator"
       $group        = "Administrators"
       $serviceName  = "C_oracle_wls_wls11g_wlserver_10.3"
     }
  }

  # default parameters for the wlst scripts
  Wls::Wlstexec {
    wlsDomain    => "${osDomainPath}/osbDomain",
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls11gJDK,  
    user         => $user,
    group        => $group,
    address      => "localhost",
    wlsUser      => "weblogic",
    password     => "weblogic1",
    port         => "7001",
  }

  # create jdbc jms datasource for jms server 
  wls::wlstexec { 
  
    'createJdbcDatasourceJms':
     wlstype       => "jdbc",
     wlsObjectName => "jmsDS",
     script        => 'createJdbcDatasource.py',
     params        => ["dsName                      = 'jmsDS'",
                      "jdbcDatasourceTargets       = 'AdminServer,osb_server1'",
                      "dsJNDIName                  = 'jdbc/jmsDS'",
                      "dsDriverName                = 'oracle.jdbc.OracleDriver'",
                      "dsURL                       = 'jdbc:oracle:thin:@master.alfa.local:1521/XE'",
                      "dsUserName                  = 'jms'",
                      "dsPassword                  = 'jms'",
                      "datasourceTargetType        = 'Server'",
                      "globalTransactionsProtocol  = 'None'"
                      ],

  }

  # create jdbc persistence store for jmsmodule 
  wls::wlstexec { 
  
    'createJdbcPersistenceStoreOSBServer':
     wlstype       => "jdbcstore",
     wlsObjectName => "jmsModuleJdbcPersistence",
     script        => 'createJdbcPersistenceStore.py',
     params        => ["jdbcStoreName = 'jmsModuleJdbcPersistence'",
                      "serverTarget  = 'osb_server1'",
                      "prefix        = 'jms1'",
                      "datasource    = 'jmsDS'"
                      ],
     require     => Wls::Wlstexec['createJdbcDatasourceJms'];

  }


  # create file persistence store for osb_server1 
  wls::wlstexec { 
    'createFilePersistenceStoreOSBServer':
     wlstype       => "filestore",
     wlsObjectName => "jmsModuleFilePersistence",
     script        => 'createFilePersistenceStore.py',
     port          => $adminServerPort,
     params        =>  ["fileStoreName = 'jmsModuleFilePersistence'",
                      "serverTarget  = 'osb_server1'"],
     require       => Wls::Wlstexec['createJdbcPersistenceStoreOSBServer'];

  }
  
  # create jms server for osb_server1 
  wls::wlstexec { 
  
    'createJmsServerOSBServer':
     wlstype       => "jmsserver",
     wlsObjectName => "jmsServer",
     script      => 'createJmsServer.py',
     params      =>  ["storeName      = 'jmsModuleFilePersistence'",
                      "serverTarget   = 'osb_server1'",
                      "jmsServerName  = 'jmsServer'",
                      "storeType      = 'file'",
                      ],
     require     => Wls::Wlstexec['createFilePersistenceStoreOSBServer'];
  }

  # create jms server for osb_server1 
  wls::wlstexec { 
  
    'createJmsServerOSBServer2':
     wlstype       => "jmsserver",
     wlsObjectName => "jmsServer2",
     script      => 'createJmsServer.py',
     port        => $adminServerPort,
     params      =>  ["storeName      = 'jmsModuleJdbcPersistence'",
                      "serverTarget   = 'osb_server1'",
                      "jmsServerName  = 'jmsServer2'",
                      "storeType      = 'jdbc'",
                      ],
     require     => Wls::Wlstexec['createJmsServerOSBServer'];
  }

  # create jms module for osb_server1 
  wls::wlstexec { 
  
    'createJmsModuleOSBServer':
     wlstype       => "jmsmodule",
     wlsObjectName => "jmsModule",
     script      => 'createJmsModule.py',
     params      =>  ["target         = 'osb_server1'",
                      "jmsModuleName  = 'jmsModule'",
                      "targetType     = 'Server'",
                      ],
     require     => Wls::Wlstexec['createJmsServerOSBServer2'];
  }


  # create jms subdeployment for jms module 
  wls::wlstexec { 
    'createJmsSubDeploymentWLSforJmsModule':
     wlstype       => "jmssubdeployment",
     wlsObjectName => "jmsModule/wlsServer",
     script        => 'createJmsSubDeployment.py',
     params        => ["target         = 'osb_server1'",
                      "jmsModuleName  = 'jmsModule'",
                      "subName        = 'wlsServer'",
                      "targetType     = 'Server'"
                      ],
     require     => Wls::Wlstexec['createJmsModuleOSBServer'];
 }


  # create jms subdeployment for jms module 
  wls::wlstexec { 
    'createJmsSubDeploymentWLSforJmsModule2':
     wlstype       => "jmssubdeployment",
     wlsObjectName => "jmsModule/JmsServer",
     script      => 'createJmsSubDeployment.py',
     params      =>  ["target         = 'jmsServer'",
                      "jmsModuleName  = 'jmsModule'",
                      "subName        = 'JmsServer'",
                      "targetType     = 'JMSServer'"
                      ],
     require     => Wls::Wlstexec['createJmsSubDeploymentWLSforJmsModule'];
  }

  # create jms connection factory for jms module 
  wls::wlstexec { 
  
    'createJmsConnectionFactoryforJmsModule':
     wlstype       => "jmsobject",
     wlsObjectName => "cf",
     script        => 'createJmsConnectionFactory.py',
     params        => ["subDeploymentName = 'wlsServer'",
                      "jmsModuleName     = 'jmsModule'",
                      "cfName            = 'cf'",
                      "cfJNDIName        = 'jms/cf'",
                      "transacted        = 'false'",
                      "timeout           = 'xxxx'"
                      ],
     require     => Wls::Wlstexec['createJmsSubDeploymentWLSforJmsModule2'];
  }


  # create jms error Queue for jms module 
  wls::wlstexec { 
  
    'createJmsErrorQueueforJmsModule':
     wlstype       => "jmsobject",
     wlsObjectName => "ErrorQueue",
     script        => 'createJmsQueueOrTopic.py',
     params        => ["subDeploymentName = 'JmsServer'",
                      "jmsModuleName     = 'jmsModule'",
                      "jmsName           = 'ErrorQueue'",
                      "jmsJNDIName       = 'jms/ErrorQueue'",
                      "jmsType           = 'queue'",
                      "distributed       = 'false'",
                      "balancingPolicy   = 'xxxxx'",
                      "useRedirect       = 'false'",
                      "limit             = 'xxxxx'",
                      "policy            = 'xxxxx'",
                      "errorObject       = 'xxxxx'"
                      ],
     require     => Wls::Wlstexec['createJmsConnectionFactoryforJmsModule'];
  }

  # create jms Queue for jms module 
  wls::wlstexec { 
  
    'createJmsQueueforJmsModule':
     wlstype       => "jmsobject",
     wlsObjectName => "Queue1",
     script        => 'createJmsQueueOrTopic.py',
     params        => ["subDeploymentName   = 'JmsServer'",
                      "jmsModuleName       = 'jmsModule'",
                      "jmsName             = 'Queue1'",
                      "jmsJNDIName         = 'jms/Queue1'",
                      "jmsType             = 'queue'",
                      "distributed         = 'false'",
                      "balancingPolicy     = 'xxxxx'",
                      "useRedirect         = 'true'",
                      "limit               = '3'",
                      "policy              = 'Redirect'",
                      "errorObject         = 'ErrorQueue'"
                      ],
     require     => Wls::Wlstexec['createJmsErrorQueueforJmsModule'];
  }

  # create jms Topic for jms module 
  wls::wlstexec { 
    'createJmsTopicforJmsModule':
     wlstype       => "jmsobject",
     wlsObjectName => "Topic1",
     script        => 'createJmsQueueOrTopic.py',
     params        => ["subDeploymentName   = 'JmsServer'",
                      "jmsModuleName       = 'jmsModule'",
                      "jmsName             = 'Topic1'",
                      "jmsJNDIName         = 'jms/Topic1'",
                      "jmsType             = 'topic'",
                      "distributed         = 'false'",
                      "balancingPolicy     = 'xxxxx'",
                      "useRedirect         = 'false'",
                      "limit               = 'xxxxx'",
                      "policy              = 'xxxxx'",
                      "errorObject         = 'xxxxx'"
                      ],
     require     => Wls::Wlstexec['createJmsQueueforJmsModule'];
  }

}  






class wls_osb_domain{

  if $jdkWls11gVersion == undef {
    $jdkWls11gVersion = "7u9"
    notify {"wls11g jdkWls11gVersion not defined,use defaults":}
  }

  if $jdkWls11gJDK == undef {
    $jdkWls11gJDK = 'jdk1.7.0_09'
  }

  $wlsDomainName   = "osbDomain"
  $osTemplate      = "osb"
  $adminListenPort = "7001"
  $nodemanagerPort = "5556"
  $address         = "localhost"
  $wlsUser         = "weblogic"
  $password        = "weblogic1"
 
 
  case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
       $osMdwHome    = "/opt/oracle/wls/wls11g"
       $osWlHome     = "/opt/oracle/wls/wls11g/wlserver_10.3"
       $osDomainPath = "/opt/oracle/wls/wls11g/admin"
       $user         = "oracle"
       $group        = "dba"
     }
     windows: { 
       $osMdwHome    = "c:/oracle/wls/wls11g"
       $osWlHome     = "c:/oracle/wls/wls11g/wlserver_10.3"
       $osDomainPath = "c:/oracle/wls/wls11g/admin"
       $user         = "Administrator"
       $group        = "Administrators"
       $serviceName  = "C_oracle_wls_wls11g_wlserver_10.3"
     }
  }

  # set the defaults

  Wls::Wlsdomain {
    wlHome       => $osWlHome,
    mdwHome      => $osMdwHome,
    fullJDKName  => $jdkWls11gJDK,  
    user         => $user,
    group        => $group,    
  }



 # install OSB domain
 wls::wlsdomain{
 
   'osbDomain':
   wlsTemplate     => $osTemplate,
   domain          => $wlsDomainName,
   domainPath      => $osDomainPath,
   adminListenPort => $adminListenPort,
   nodemanagerPort => $nodemanagerPort,
   require         => Wls::Nodemanager['nodemanager11g'];
   
 }


  # default parameters for the wlst scripts
  Wls::Wlstexec {
    wlsDomain    => "${osDomainPath}/${wlsDomainName}",
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls11gJDK,  
    user         => $user,
    group        => $group,
    address      => $address,
    wlsUser      => $wlsUser,
    password     => $password,
  }
  
  # start AdminServers for configuration of WLS Domain
  wls::wlstexec { 
    'startOSBAdminServer':
     script      => 'startWlsServer.py',
     port        => $nodemanagerPort,
     params      =>  ["domain     = '${wlsDomainName}'",
                      "domainPath = '${osDomainPath}/${wlsDomainName}'",
                      "wlsServer  = 'AdminServer'"],
     require     => Wls::Wlsdomain['osbDomain'];
  }


}

class wls11g_domain{

  if $jdkWls11gVersion == undef {
    $jdkWls11gVersion = "7u9"
    notify {"wls11g jdkWls11gVersion not defined,use defaults":}
  }

  if $jdkWls11gJDK == undef {
    $jdkWls11gJDK = 'jdk1.7.0_09'
  }

  $wlsDomainName   = "stdDomain"
  $osTemplate      = "standard"
  $adminListenPort = "9001"
  $nodemanagerPort = "5556"
  $address         = "localhost"
  $wlsUser         = "weblogic"
  $password        = "weblogic1"
 
  case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
       $osMdwHome    = "/opt/oracle/wls/wls11g"
       $osWlHome     = "/opt/oracle/wls/wls11g/wlserver_10.3"
       $osDomainPath = "/opt/oracle/wls/wls11g/admin"
       $user         = "oracle"
       $group        = "dba"
     }
     windows: { 
       $osMdwHome    = "c:/oracle/wls/wls11g"
       $osWlHome     = "c:/oracle/wls/wls11g/wlserver_10.3"
       $osDomainPath = "c:/oracle/wls/wls11g/admin"
       $user         = "Administrator"
       $group        = "Administrators"
       $serviceName  = "C_oracle_wls_wls11g_wlserver_10.3"
     }
  }

  # set the defaults

  Wls::Wlsdomain {
    wlHome       => $osWlHome,
    mdwHome      => $osMdwHome,
    fullJDKName  => $jdkWls11gJDK,  
    user         => $user,
    group        => $group,    
  }



 # install domain
 wls::wlsdomain{
 
   'stdDomain':
   wlsTemplate     => $osTemplate,
   domain          => $wlsDomainName,
   domainPath      => $osDomainPath,
   adminListenPort => $adminListenPort,
   nodemanagerPort => $nodemanagerPort,
   require         => Wls::Nodemanager['nodemanager11g'];
   
 }


  # default parameters for the wlst scripts
  Wls::Wlstexec {
    wlsDomain    => "${osDomainPath}/${wlsDomainName}",
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls11gJDK,  
    user         => $user,
    group        => $group,
    address      => $address,
    wlsUser      => $wlsUser,
    password     => $password,
  }
  
  # start AdminServers for configuration of both domains myTestDomain
  wls::wlstexec { 
  
    'startWLSAdminServer':
     script      => 'startWlsServer.py',
     port        =>  $nodemanagerPort,
     params      =>  ["domain = '${wlsDomainName}'",
                      "domainPath = '${osDomainPath}/${wlsDomainName}'",
                      "wlsServer = 'AdminServer'"],
     require     => Wls::Wlsdomain['osbDomain'];

  }


}

class wls12c_domain{

  if $jdkWls12gVersion == undef {
    $jdkWls12gVersion = "7u9"
    notify {"wls12g jdkWls12gVersion not defined,use defaults":}
  }

  if $jdkWls12gJDK == undef {
    $jdkWls12gJDK = 'jdk1.7.0_09'
  }

  $wlsDomainName   = "stdDomain12c"
  $osTemplate      = "standard"
  $adminListenPort = "8001"
  $nodemanagerPort = "5656"
  $address         = "localhost"
  $wlsUser         = "weblogic"
  $password        = "weblogic1"
 
  case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
       $osMdwHome    = "/opt/oracle/wls/wls12c"
       $osWlHome     = "/opt/oracle/wls/wls12c/wlserver_12.1"
       $osDomainPath = "/opt/oracle/wls/wls12c/admin"
       $user         = "oracle"
       $group        = "dba"
     }
     windows: { 
       $osMdwHome    = "c:/oracle/wls/wls12c"
       $osWlHome     = "c:/oracle/wls/wls12c/wlserver_12.1"
       $osDomainPath = "c:/oracle/wls/wls12c/admin"
       $user         = "Administrator"
       $group        = "Administrators"
       $serviceName  = "C_oracle_wls_wls12g_wlserver_12.1"
     }
  }

  # set the defaults

  Wls::Wlsdomain {
    wlHome       => $osWlHome,
    mdwHome      => $osMdwHome,
    fullJDKName  => $jdkWls12gJDK,  
    user         => $user,
    group        => $group,    
  }



 # install domain
 wls::wlsdomain{
 
   'stdDomain12c':
   wlsTemplate     => $osTemplate,
   domain          => $wlsDomainName,
   domainPath      => $osDomainPath,
   adminListenPort => $adminListenPort,
   nodemanagerPort => $nodemanagerPort,
 }


  # default parameters for the wlst scripts
  Wls::Wlstexec {
    wlsDomain    => "${osDomainPath}/${wlsDomainName}",
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls12gJDK,  
    user         => $user,
    group        => $group,
    address      => $address,
    wlsUser      => $wlsUser,
    password     => $password,
  }
  
  # start AdminServers for configuration of both domains myTestDomain
  wls::wlstexec { 
  
    'startWLSAdminServer12c':
     script      => 'startWlsServer.py',
     port        =>  $nodemanagerPort,
     params      =>  ["domain = '${wlsDomainName}'",
                      "domainPath = '${osDomainPath}/${wlsDomainName}'",
                      "wlsServer = 'AdminServer'"],
     require     => Wls::Wlsdomain['stdDomain12c'];

  }


}
```


templates.pp
------------

```
include jdk7
include wls



class osb_oepe{

  if $jdkWls11gVersion == undef {
    $jdkWls11gVersion = "7u9"
    notify {"wls11g jdkWls11gVersion not defined,use defaults":}
  }

  if $jdkWls11gJDK == undef {
    $jdkWls11gJDK = 'jdk1.7.0_09'
  }

  if $wls11gVersion == undef {
    $wls11gVersion = "1036"
  }

  jdk7::install7{'jdk7_husdon':
    version => $jdkWls11gVersion,
    x64     => "true",
  }

  $osMdwHome    = "/opt/oracle/wls/wls11g"
  $osWlHome     = "/opt/oracle/wls/wls11g/wlserver_10.3"
  $user         = "oracle"
  $group        = "dba"

  $oepeFile     = "oepe-indigo-all-in-one-11.1.1.8.0.201110211138-linux-gtk-x86_64.zip"


  # set the defaults
  Wls::Installwls {
    version      => $wls11gVersion,
    versionJdk   => $jdkWls11gVersion,
    user         => $user,
    group        => $group,    
  }


  Wls::Installosb {
    mdwHome      => $osMdwHome,
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls11gJDK,  
    user         => $user,
    group        => $group,    
  }

  # install
  wls::installwls{'11gPS5_hudson':
    require      => Jdk7::Install7['jdk7_husdon'],
  }


  # download oepe to hudson server
  if ! defined(File["/install/${oepeFile}"]) {
    file { "/install/${oepeFile}":
       source  => "puppet:///modules/wls/${oepeFile}",
       require => Wls::Installwls['11gPS5_hudson'],
       ensure  => present,
       mode    => 0775,
    }
  }

  # extract oepe in middleware home
  if ! defined(Exec["extract ${oepeFile}"]) {
     exec { "extract ${oepeFile}":
          command   => "unzip -n /install/${oepeFile} -d ${osMdwHome}/oepe11.1.1.8",
          require   => File["/install/${oepeFile}"],
          creates   => "${osMdwHome}/oepe11.1.1.8",
          path      => "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:",
          user      => $user,
          group     => $group,
          logoutput => true,
         }
  }

  #install OSB with OEPE
  wls::installosb{'osbPS5_oepe':
    osbFile      => 'ofm_osb_generic_11.1.1.6.0_disk1_1of1.zip',
    oepeHome     => 'oepe11.1.1.8',
    require      => Exec["extract ${oepeFile}"],
  }


}



class wls1036osb{

  if $jdkWls11gVersion == undef {
    $jdkWls11gVersion = "7u9"
    notify {"wls11g jdkWls11gVersion not defined,use defaults":}
  }

  if $jdkWls11gJDK == undef {
    $jdkWls11gJDK = 'jdk1.7.0_09'
  }

  if $wls11gVersion == undef {
    $wls11gVersion = "1036"
  }


  jdk7::install7{'jdk7_2':
    version => $jdkWls11gVersion,
    x64     => "true",
  }
 
  case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
       $osMdwHome    = "/opt/oracle/wls/wls11g"
       $osWlHome     = "/opt/oracle/wls/wls11g/wlserver_10.3"
       $user         = "oracle"
       $group        = "dba"
     }
     windows: { 
       $osMdwHome    = "c:/oracle/wls/wls11g"
       $osWlHome     = "c:/oracle/wls/wls11g/wlserver_10.3"
       $user         = "Administrator"
       $group        = "Administrators"
       $serviceName  = "C_oracle_wls_wls11g_wlserver_10.3"
     }
  }

  # set the defaults
  Wls::Installwls {
    version      => $wls11gVersion,
    versionJdk   => $jdkWls11gVersion,
    user         => $user,
    group        => $group,    
  }

  Wls::Installosb {
    mdwHome      => $osMdwHome,
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls11gJDK,  
    user         => $user,
    group        => $group,    
  }
  
  Wls::Nodemanager {
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls11gJDK,  
    user         => $user,
    group        => $group,
    serviceName  => $serviceName,  
  }
  

  # install
  wls::installwls{'11gPS5':
    require      => Jdk7::Install7['jdk7_2'],
  }

  wls::installosb{'osbPS5':
    osbFile      => 'ofm_osb_generic_11.1.1.6.0_disk1_1of1.zip',
    require      => Wls::Installwls['11gPS5'],
  }

  wls::bsupatch{'p13573621':
    mdwHome      => $osMdwHome ,
    wlHome       => $osWlHome,
    fullJDKName  => $defaultFullJDK,
    patchId      => 'KZKQ', 
    patchFile    => 'p13573621_1036_Generic.zip', 
    user         => $user,
    group        => $group, 
    require      => Wls::Installosb['osbPS5'],
  }


 #nodemanager configuration and starting
 wls::nodemanager{'nodemanager11g':
   listenPort  => '5556',
   require     => Wls::Installosb['osbPS5'],
 }


}

class wls12{

  if $jdkWls12cVersion == undef {
    $jdkWls12cVersion = "7u9"
    notify {"wls12 jdkWls12cVersion not defined,use defaults":}
  }

  if $jdkWls12cJDK == undef {
    $jdkWls12cJDK = 'jdk1.7.0_09'
  }

  if $wls12cVersion == undef {
    $wls12cVersion = "1211"
  }

  jdk7::install7{'jdk7':
    version => $jdkWls12cVersion,
    x64     => "true",
  }
  
  case $operatingsystem {
     centos, redhat, OracleLinux, ubuntu, debian: { 
       $osWlHome     = "/opt/oracle/wls/wls12c/wlserver_12.1"
       $user         = "oracle"
       $group        = "dba"
     }
     windows: { 
       $osWlHome     = "c:/oracle/wls/wls12c/wlserver_12.1"
       $user         = "Administrator"
       $group        = "Administrators"
       $serviceName  = "C_oracle_wls_wls12c_wlserver_12.1"
     }
  }

  # set the defaults
  Wls::Installwls {
    version      => $wls12cVersion,
    versionJdk   => $jdkWls12cVersion,
    user         => $user,
    group        => $group,    
  }

  Wls::Nodemanager {
    wlHome       => $osWlHome,
    fullJDKName  => $jdkWls12cJDK,  
    user         => $user,
    group        => $group,
    serviceName  => $serviceName,  
  }
  
  # install
  wls::installwls{'wls12c':
    require      => Jdk7::Install7['jdk7'],
  }

  #nodemanager configuration and starting
  wls::nodemanager{'nodemanager':
    listenPort   => '5656',
    require      => Wls::Installwls['wls12c'],
  }

}
``` 