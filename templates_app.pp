# templates_app.pp
#


include wls

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
  
  # start AdminServers for configuration of both domains myTestDomain
  wls::wlstexec { 
  
    'startOSBAdminServer':
     script      => 'startWlsServer.py',
     port        => $nodemanagerPort,
     params      =>  ["domain = '${wlsDomainName}'",
                      "domainPath = '${osDomainPath}/${wlsDomainName}'",
                      "wlsServer = 'AdminServer'"],
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

  if $jdkWls11gVersion == undef {
    $jdkWls11gVersion = "7u9"
    notify {"wls11g jdkWls11gVersion not defined,use defaults":}
  }

  if $jdkWls11gJDK == undef {
    $jdkWls11gJDK = 'jdk1.7.0_09'
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
    fullJDKName  => $jdkWls11gJDK,	
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
  
    'startWLSAdminServer12c':
     script      => 'startWlsServer.py',
     port        =>  $nodemanagerPort,
     params      =>  ["domain = '${wlsDomainName}'",
                      "domainPath = '${osDomainPath}/${wlsDomainName}'",
                      "wlsServer = 'AdminServer'"],
     require     => Wls::Wlsdomain['osbDomain'];

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
     require     => Wls::Wlstexec['startOSBAdminServer'];

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



