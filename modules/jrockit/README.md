JRockit puppet module
=====================

Version updates
---------------
- 0.1.1 Bug fix
- 0.2.0 Support for local mount to avoid downloading the installer from the master

Installs the jdk and optionally the jre, demos etc.
---------------------------------------------------

Installs the jrockit jdk on linux and windows based systems with 64 or 32 bit architecture. The approriate installer must be copied to the files directory of the module; for example jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin

The module does the following:

- downloads the installer to the download folder of the puppet agent host
- performs a silent installation
- sets the java links in /usr/java ( latest and default ) 
- adds to alternatives for linux systems
- optionally sets JRockit as default java

The default settings are:

- Demos are not installed
- Source is not installed
- The jre is installed
- The installed version is set as the default

Required settings:

- Version - must match the version component of filename of the installer
- x64 - true for 64 bit and false for 32 bit (Solaris/SPARC is not currently supported)

Optional Settings:

- puppetMountDir - Specify local mountpoint for install files
- downloadDir    - Local directory for installer downloads
- installDemos   - Install demos (default=false)
- installSource  - Install source code (default=false)
- installJre     - Install JRE (default=true)
- setDefault     - Set the installation as default (default=true)

Example usage
-------------

	include jrockit

	jrockit::installrockit {'jrockit-1.6.0_45':
	    version       => '1.6.0_45-R28.2.7-4.1.0',
	    x64           => 'true',
		downloadDir   =>  "/install/",
		installSource =>  'true',
	}

