Oracle Database Linux puppet module
=================================================

created by Edwin Biemond   
[biemond.blogspot.com](http://biemond.blogspot.com)    
[Github homepage](https://github.com/biemond/puppet)    

Should work for RedHat,CentOS ,Ubuntu, Debian or OracleLinux should work without any problems 

Oracle Database Features
---------------------------

- Oracle Database 11.2.0.3 installation  
- Apply OPatch

Coming in next release

- Create database instances
                                         
Files
-----
Download oracle database software from support.oracle.com  
Patch 10404530: 11.2.0.3.0 PATCH SET FOR ORACLE DATABASE SERVER  
and upload this to the files folder of the oradb puppet module  

# database files
1358454646 Mar  9 17:31 p10404530_112030_Linux-x86-64_1of7.zip  
1142195302 Mar  9 17:47 p10404530_112030_Linux-x86-64_2of7.zip  
 979195792 Mar  9 18:01 p10404530_112030_Linux-x86-64_3of7.zip  
 659229728 Mar  9 18:11 p10404530_112030_Linux-x86-64_4of7.zip  
 616473105 Mar  9 18:19 p10404530_112030_Linux-x86-64_5of7.zip  
 479890040 Mar  9 18:26 p10404530_112030_Linux-x86-64_6of7.zip  
 113915106 Mar  9 18:28 p10404530_112030_Linux-x86-64_7of7.zip  
# opatch database patch
  25556377 Mar 10 12:48 p14727310_112030_Linux-x86-64.zip
# patches opatch
  32551315 Mar 10 13:10 p6880880_112000_Linux-x86-64.zip

important support node
[ID 1441282.1] Requirements for Installing Oracle 11gR2 RDBMS on RHEL6 or OL6 64-bit (x86-64)  


Oracle Database Facter
-------------------
Contains Oracle Facter which displays the following 
- Oracle Software
- Opatch patches

### Example of the Oracle Database Facts 

    ora_inst_loc_data /oracle/oraInventory
    ora_inst_patches_oracle_product_11.2_db Patches;14727310;
    ora_inst_products /oracle/product/11.2/db;

templates.pp
------------

The databaseType value should contain only one of these choices.        
- EE     : Enterprise Edition                                
- SE     : Standard Edition                                  
- SEONE  : Standard Edition One

     class { 'oradb::installdb':
              file         => 'p10404530_112030_Linux-x86-64',
              databaseType => 'SE',
              oracleBase   => '/oracle',
              oracleHome   => '/oracle/product/11.2/db',
              user         => 'oracle',
              group        => 'dba',
              downloadDir  => '/install/',  
           }
  
     #for this example patch, the OPatch utility must be upgraded (6880880)
     oradb::opatch{'14727310_db_patch':
       oracleProductHome => '/oracle/product/11.2/db' ,
       patchId           => '14727310', 
       patchFile         => 'p14727310_112030_Linux-x86-64.zip',  
       user              => 'oracle',
       group             => 'dba',
       downloadDir       => '/install/',   
       require           => Class['oradb::installdb'],
     }
  

site.pp
-------

install the following module to set the database kernel parameters  
*puppet module install fiddyspence-sysctl*  

install the following module to set the database user limits parameters
puppet module install erwbgy-limits

     
     node database {
     
       # Controls the default maxmimum size of a mesage queue
       sysctl { 'kernel.msgmnb':
         ensure    => 'present',
         permanent => 'yes',
         value     => '65536',
       }
     
       # Controls the maximum size of a message, in bytes
       sysctl { 'kernel.msgmax':
         ensure    => 'present',
         permanent => 'yes',
         value     => '65536',
       }
     
       # Controls the maximum number of shared memory segments, in pages
       sysctl { 'kernel.shmmax':
         ensure    => 'present',
         permanent => 'yes',
         value     => '2147483648',
       }
     
       # Controls the maximum shared segment size, in bytes
       sysctl { 'kernel.shmall':
         ensure    => 'present',
         permanent => 'yes',
         value     => '2097152',
       }
     
       sysctl { 'fs.file-max':
         ensure    => 'present',
         permanent => 'yes',
         value     => '6815744',
       }
     
       sysctl { 'kernel.shmmni':
         ensure    => 'present',
         permanent => 'yes',
         value     => '4096',
       }
     
       sysctl { 'fs.aio-max-nr':
         ensure    => 'present',
         permanent => 'yes',
         value     => '1048576',
       }
       sysctl { 'kernel.sem':
         ensure    => 'present',
         permanent => 'yes',
         value     => '250 32000 100 128',
       }
     
     
       # The interval between the last data packet sent (simple ACKs are not considered data) and the first keepalive probe
       sysctl { 'net.ipv4.tcp_keepalive_time':
         ensure    => 'present',
         permanent => 'yes',
         value     => '1800',
       }
     
       # The interval between subsequential keepalive probes, regardless of what the connection has exchanged in the meantime
       sysctl { 'net.ipv4.tcp_keepalive_intvl':
         ensure    => 'present',
         permanent => 'yes',
         value     => '30',
       }
     
       # The number of unacknowledged probes to send before considering the connection dead and notifying the application layer
       sysctl { 'net.ipv4.tcp_keepalive_probes':
         ensure    => 'present',
         permanent => 'yes',
         value     => '5',
       }
     
       # The time that must elapse before TCP/IP can release a closed connection and reuse its resources. During this TIME_WAIT state, reopening the connection to the client costs less than establishing a new connection. By reducing the value of this entry, TCP/IP can release closed connections faster, making more resources available for new connections.
       sysctl { 'net.ipv4.tcp_fin_timeout':
         ensure    => 'present',
         permanent => 'yes',
         value     => '30',
       }
     
       sysctl { 'net.ipv4.ip_local_port_range':
         ensure    => 'present',
         permanent => 'yes',
         value     => '9000 65500',
       }
     
       sysctl { 'net.core.rmem_default':
         ensure    => 'present',
         permanent => 'yes',
         value     => '262144',
       }
     
       sysctl { 'net.core.rmem_max':
         ensure    => 'present',
         permanent => 'yes',
         value     => '4194304',
       }
     
       sysctl { 'net.core.wmem_default':
         ensure    => 'present',
         permanent => 'yes',
         value     => '262144',
       }
     
       sysctl { 'net.core.wmem_max':
         ensure    => 'present',
         permanent => 'yes',
         value     => '1048576',
       }
     
     
       class { 'limits':
         config => {
                    '*'        => { 'nofile'  => { soft => '2048'   , hard => '8192',   },
                                  },
                    '@oracle'  => { 'nofile'  => { soft => '1024'   , hard => '65536',  },
                                    'nproc'   => { soft => '2048'   , hard => '16384',   },
                                    'stack'   => { soft => '10240'  ,},
                                  },
                    },
         use_hiera => false,
       }
     
     
       package { 'binutils.x86_64':
         ensure  => present,
       }
     
       package { 'compat-libstdc++-33.x86_64':
         ensure  => present,
       }
     
       package { 'glibc.x86_64':
         ensure  => present,
       }
       package { 'ksh.x86_64':
         ensure  => present,
       }
     
       package { 'libaio.x86_64':
         ensure  => present,
       }
     
       package { 'libgcc.x86_64':
         ensure  => present,
       }
     
       package { 'libstdc++.x86_64':
         ensure  => present,
       }
     
       package { 'make.x86_64':
         ensure  => present,
       }
     
       package { 'compat-libcap1.x86_64':
         ensure  => present,
       }
     
       package { 'gcc.x86_64':
         ensure  => present,
       }
       package { 'gcc-c++.x86_64':
         ensure  => present,
       }
     
       package { 'glibc-devel.x86_64':
         ensure  => present,
       }
     
       package { 'libaio-devel.x86_64':
         ensure  => present,
       }
     
       package { 'libstdc++-devel.x86_64':
         ensure  => present,
       }
     
       package { 'sysstat.x86_64':
         ensure  => present,
       }
     
     
     }
     
     node 'dbagent1.alfa.local' inherits database {
     }
     
