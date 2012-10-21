# oracle_middleware_homes.rb
require 'rexml/document' 


# read middleware home in the oracle home folder
def get_homes()

  os = Facter.value(:operatingsystem)

  if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?os
    beafile = "/home/oracle/bea/beahomelist"

  elsif ["windows"].include?os 
    beafile = "c:/bea/beahomelist"

  else
    return nil 
  end

  if FileTest.exists?(beafile)
    output = File.read(beafile)
    if output.nil?
      return nil
    else  
      return output.split(/;/)
    end
  else
    return nil
  end

end

def get_bsu_patches(name)
  os = Facter.value(:operatingsystem)

  if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?os
   if FileTest.exists?(name+'/utils/bsu/patch-client.jar')
    output2 = Facter::Util::Resolution.exec('java -Xms256m -Xmx512m -jar '+ name+'/utils/bsu/patch-client.jar -report -bea_home='+name+' -output_format=xml')
    if output2.nil?
      return "empty"
    end
   else
    return nil
   end 
  elsif ["windows"].include?os
   if FileTest.exists?(name+'/utils/bsu/patch-client.jar')
    output2 = Facter::Util::Resolution.exec('java -Xms256m -Xmx512m -jar '+ name+'/utils/bsu/patch-client.jar -report -bea_home='+name+' -output_format=xml')
    if output2.nil?
      return nil
    end
   else
    return nil
   end 
  else
    return nil 
  end
  doc = REXML::Document.new output2

  root = doc.root
  patches = ""
  root.elements.each("//patchDesc") do |patch|
    patches += patch.elements['patchId'].text + ";"
  end
  return patches

end


# read weblogic domains in the admin  folder of the middleware home
def get_domain(name,i)

  os = Facter.value(:operatingsystem)

  if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?os

    if FileTest.exists?(name+'/admin')
      output2 = Facter::Util::Resolution.exec('/bin/ls '+name+'/admin')
      if output2.nil?
        Facter.add("ora_mdw_#{i}_domain_cnt") do
          setcode do
            0
          end
        end
        return nil
      end
    else
      Facter.add("ora_mdw_#{i}_domain_cnt") do
        setcode do
          0
        end
      end
      return nil
    end

  elsif ["windows"].include?os 
    if FileTest.exists?(name+'/admin')
      output2 = Facter::Util::Resolution.exec('C:\Windows\system32\cmd.exe /c dir /B '+name+'\admin')
      if output2.nil?
        Facter.add("ora_mdw_#{i}_domain_cnt") do
          setcode do
            0
          end
        end
        return nil
      end
    else
      Facter.add("ora_mdw_#{i}_domain_cnt") do
        setcode do
          0
        end
      end
      return nil
    end

  else
    return nil 
  end

  l = 0

  output2.split(/\r?\n/).each_with_index do |domain, n|

    if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?os
      domainfile = name+'/admin/'+domain+'/config/config.xml'

    elsif ["windows"].include?os 
      domainfile = name+'/admin/'+domain+'/config/config.xml'
    end

    if FileTest.exists?(domainfile)
      file = File.read( domainfile)
      doc = REXML::Document.new file

      root = doc.root

      Facter.add("ora_mdw_#{i}_domain_#{n}") do
        setcode do
          root.elements['name'].text
        end
      end

      k = 0
      root.elements.each("server") do |server| 
        Facter.add("ora_mdw_#{i}_domain_#{n}_server_#{k}") do
          setcode do
            server.elements['name'].text
          end
        end
        
        port = server.elements['listen-port']
        unless port.nil?
          Facter.add("ora_mdw_#{i}_domain_#{n}_server_#{k}_port") do
            setcode do
               port.text
            end
          end
        end
        machine = server.elements['machine']
        unless machine.nil?
          Facter.add("ora_mdw_#{i}_domain_#{n}_server_#{k}_machine") do
            setcode do
               machine.text 
            end
          end
        end
        k += 1            
      end

      deployements = ""
      root.elements.each("app-deployment[module-type = 'ear']") do |apps|
      	deployements += apps.elements['name'].text + ";"
      end
      Facter.add("ora_mdw_#{i}_domain_#{n}_deployments") do
         setcode do
            deployements
         end
      end

      libraries = ""
      root.elements.each("library") do |libs|
      	libraries += libs.elements['name'].text + ";"
      end
      Facter.add("ora_mdw_#{i}_domain_#{n}_libraries") do
         setcode do
            libraries
         end
      end

      filestores = ""
      root.elements.each("file-store") do |file|
      	filestores += file.elements['name'].text + ";"
      end
      Facter.add("ora_mdw_#{i}_domain_#{n}_filestores") do
         setcode do
            filestores
         end
      end

      jdbcstores = ""
      root.elements.each("jdbc-store") do |jdbc|
      	jdbcstores += jdbc.elements['name'].text + ";"
      end
      Facter.add("ora_mdw_#{i}_domain_#{n}_jdbcstores") do
         setcode do
            jdbcstores
         end
      end

      safagents = ""
      root.elements.each("jdbc-store") do |agent|
      	safagents += agent.elements['name'].text + ";"
      end
      Facter.add("ora_mdw_#{i}_domain_#{n}_safagents") do
         setcode do
            safagents
         end
      end

      jmsserversstr = ""
      root.elements.each("jms-server") do |jmsservers| 
        jmsserversstr += jmsservers.elements['name'].text + ";"
      end
      Facter.add("ora_mdw_#{i}_domain_#{n}_jmsservers") do
        setcode do
          jmsserversstr
         end
      end

      k = 0
      jmsmodulestr = "" 
      root.elements.each("jms-system-resource") do |jmsresource|
        jmsstr = "" 
        jmssubdeployments = ""
        jmsmodulestr += jmsresource.elements['name'].text + ";"

        jmsresource.elements.each("sub-deployment") do |sub| 
          jmssubdeployments +=  sub.elements['name'].text + ";"
        end
        Facter.add("ora_mdw_#{i}_domain_#{n}_jmsmodule_#{k}_subdeployments") do
          setcode do
            jmssubdeployments
          end
        end

        subfile = File.read( name+'/admin/'+domain+"/config/" + jmsresource.elements['descriptor-file-name'].text )
        subdoc = REXML::Document.new subfile

        jmsroot = subdoc.root
        jmsroot.elements.each("connection-factory") do |cfs| 
          jmsstr +=  cfs.attributes["name"] + ";"
        end

        jmsroot.elements.each("queue") do |queues| 
          jmsstr +=  queues.attributes["name"] + ";"
        end

        jmsroot.elements.each("topic") do |topics| 
          jmsstr +=  topics.attributes["name"] + ";"
        end
        Facter.add("ora_mdw_#{i}_domain_#{n}_jmsmodule_#{k}_name") do
          setcode do
            jmsresource.elements['name'].text
          end
        end
        Facter.add("ora_mdw_#{i}_domain_#{n}_jmsmodule_#{k}_objects") do
          setcode do
            jmsstr
          end
        end
        k += 1
      end
      Facter.add("ora_mdw_#{i}_domain_#{n}_jmsmodules") do
        setcode do
          jmsmodulestr
        end
      end
      Facter.add("ora_mdw_#{i}_domain_#{n}_jmsmodule_cnt") do
        setcode do
          k
        end
      end

      jdbcstr = ""
      root.elements.each("jdbc-system-resource") do |jdbcresource| 
        jdbcstr += jdbcresource.elements['name'].text + ";" 
      end
      Facter.add("ora_mdw_#{i}_domain_#{n}_jdbc") do
        setcode do
          jdbcstr
        end
      end


      l += 1
    end

  end 

  Facter.add("ora_mdw_#{i}_domain_cnt") do
    setcode do
      l
    end
  end
 
end

def get_nodemanagers()
  if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?Facter.value(:operatingsystem)
    output = Facter::Util::Resolution.exec("/bin/ps -eo pid,cmd | /bin/grep -i nodemanager.javahome | /bin/grep -v grep | awk ' {print \"pid:\", substr(\$0,0,5), \"port:\" , substr(\$0,index(\$0,\"-DListenPort\")+13,4) } '")
    if output.nil?
      return nil
    else 
      return output.split(/\r?\n/)
    end
  end
end

def get_wlsservers()
  if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?Facter.value(:operatingsystem)
    output = Facter::Util::Resolution.exec("/bin/ps -eo pid,cmd | /bin/grep -i weblogic.server | /bin/grep -v grep | awk ' {print \"pid:\", substr(\$0,0,5), \"name:\" ,substr(\$0,index(\$0,\"weblogic.Name\")+14,12) }'")
    if output.nil?
      return nil 
    else 
      return output.split(/\r?\n/)
    end
  end
end

def get_orainst_loc()
  os = Facter.value(:operatingsystem)
  if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?os
    if FileTest.exists?("/etc/oraInst.loc")
      str = ""
      output = File.read("/etc/oraInst.loc")
      output.split(/\r?\n/).each do |item|
        if item.match(/^inventory_loc/)
          str = item[14,50]
        end
      end
      return str
    else
      return "NotFound"
    end
  elsif ["windows"].include?os
    return "C:/Program Files/Oracle/Inventory"
  end
end

def get_orainst_products(path)
    if FileTest.exists?(path+"/ContentsXML/inventory.xml")
      file = File.read( path+"/ContentsXML/inventory.xml" )
      doc = REXML::Document.new file
      software =  ""
      doc.elements.each("/INVENTORY/HOME_LIST/HOME") do |element| 
        software += element.attributes["LOC"] + ";"
      end
      return software
    else
      return "NotFound"
    end
end

# report all oracle homes / domains
unless get_homes.nil?
  get_homes.each_with_index do |mdw, i|
    Facter.add("ora_mdw_#{i}") do
      setcode do
        mdw
      end
    end
    get_domain(mdw, i)
  end 
end


# all homes on 1 row
unless get_homes.nil?
  str = ""
  get_homes.each do |item|
    str += item + ";"
  end 
  Facter.add("ora_mdw_homes") do
    setcode do
      str
    end
  end 
end

# get bsu patches
unless get_homes.nil?
  get_homes.each_with_index do |mdw, i|
     Facter.add("ora_mdw_#{i}_bsu") do
      setcode do
        get_bsu_patches(mdw)
      end
    end
  end 
end



# all nodemanager 
unless get_nodemanagers.nil?
  get_nodemanagers.each_with_index do |node, a|
    Facter.add("ora_node_mgr_#{a}") do
      setcode do
        node
      end
    end
  end 
end

# report all weblogic servers
unless get_wlsservers.nil?
  get_wlsservers.each_with_index do |wls, i|
    Facter.add("ora_wls_#{i}") do
      setcode do
        wls
      end
    end
  end 
end

# all home counter
Facter.add("ora_mdw_cnt") do
  setcode do
    homes = get_homes
    if homes.nil?
      count = 0
    else
      count = homes.count
    end
  end
end

# get orainst loc data
Facter.add("ora_inst_loc_data") do
    setcode do
      inventory = get_orainst_loc
    end
end


# get orainst products
Facter.add("ora_inst_products") do
  setcode do
    inventory = get_orainst_products(get_orainst_loc)
  end
end