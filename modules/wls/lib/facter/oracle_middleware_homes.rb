# oracle_middleware_homes.rb
require 'rexml/document' 


# read middleware home in the oracle home folder
def get_homes()
  if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?Facter.value(:operatingsystem)
    if FileTest.exists?("/home/oracle/bea/beahomelist")
      output = File.read("/home/oracle/bea/beahomelist")
      return output.split(/;/)
    else
      return nil
    end
  end
end

# read weblogic domains in the admin  folder of the middleware home
def get_domain(name,i)
  if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?Facter.value(:operatingsystem)
    if FileTest.exists?(name+'/admin')
      output = Facter::Util::Resolution.exec('/bin/ls '+name+'/admin')
      if output.nil?
        return nil
      else
        l = 0
        domains = Array.new 
        output.split(/\r?\n/).each_with_index do |domain, n|
          if FileTest.exists?(name+'/admin/'+domain+"/config/config.xml")
            file = File.read( name+'/admin/'+domain+"/config/config.xml" )
            doc = REXML::Document.new file
            software = ""
            root = doc.root

            Facter.add("ora_mdw_#{i}_domain_#{n}") do
              setcode do
                root.elements['name'].text
              end
            end

            software += "domain: "+root.elements['name'].text + "\n"
            software += " version: " + root.elements['configuration-version'].text + "\n"

            k = 0
            root.elements.each("server") do |server| 
              Facter.add("ora_mdw_#{i}_domain_#{n}_server_#{k}") do
                setcode do
                  server.elements['name'].text
                end
              end
              Facter.add("ora_mdw_#{i}_domain_#{n}_server_#{k}_port") do
                setcode do
                   server.elements['listen-port'].text
                end
              end
              Facter.add("ora_mdw_#{i}_domain_#{n}_server_#{k}_machine") do
                setcode do
                   server.elements['machine'].text 
                end
              end
              software += "  server: " + server.elements['name'].text + 
                          " port: " + server.elements['listen-port'].text + 
                          " machine: " + server.elements['machine'].text + "\n"
              k += 1            
            end

            deployements = ""
            root.elements.each("app-deployment[module-type = 'ear']") do |apps|
            	deployements += apps.elements['name'].text + ";"
              software += "   deployment: " + apps.elements['name'].text + 
                          " targets " + apps.elements['target'].text + "\n"
            end
            Facter.add("ora_mdw_#{i}_domain_#{n}_deployments") do
               setcode do
                  deployements
               end
            end


            root.elements.each("machine") do |machines| 
              software += "    machines: " + machines.elements['name'].text + "\n"
            end

            jmsserversstr = ""
            root.elements.each("jms-server") do |jmsservers| 
              jmsserversstr += jmsservers.elements['name'].text + ";"
              software += "     jmsserver: " + jmsservers.elements['name'].text + 
                                " targets:" + jmsservers.elements['target'].text +
                                " persistent-store: " + jmsservers.elements['persistent-store'].text +  "\n"
            end

            Facter.add("ora_mdw_#{i}_domain_#{n}_jmsservers") do
              setcode do
                jmsserversstr
               end
            end

            k = 0
            root.elements.each("jms-system-resource") do |jmsresource|
              jmsstr = "" 
              software += "      jmsmodule: " + jmsresource.elements['name'].text + 
                                " targets:" + jmsresource.elements['target'].text + 
                                " file: " + jmsresource.elements['descriptor-file-name'].text + "\n"
              subfile = File.read( name+'/admin/'+domain+"/config/" + jmsresource.elements['descriptor-file-name'].text )
              subdoc = REXML::Document.new subfile
              jmsroot = subdoc.root
              jmsroot.elements.each("connection-factory") do |cfs| 
                jmsstr +=  cfs.attributes["name"] + ";"
                software += "        conn factory: " + cfs.attributes["name"] + 
                                " jndi name:" + cfs.elements['jndi-name'].text + "\n"
              end
              jmsroot.elements.each("queue") do |queues| 
                jmsstr +=  queues.attributes["name"] + ";"
                software += "        queues: " + queues.attributes["name"] + 
                                " jndi name:" + queues.elements['jndi-name'].text + "\n"
              end
              jmsroot.elements.each("topic") do |topics| 
                jmsstr +=  topics.attributes["name"] + ";"
                software += "        topics: " + topics.attributes["name"] + 
                                " jndi name:" + topics.elements['jndi-name'].text + "\n"
              end
              Facter.add("ora_mdw_#{i}_domain_#{n}_jmsresource_#{k}_name") do
                setcode do
                  jmsresource.elements['name'].text
                end
              end
              Facter.add("ora_mdw_#{i}_domain_#{n}_jmsresource_#{k}_objects") do
                setcode do
                  jmsstr
                end
              end
              k += 1            
            end

            jdbcstr = ""
            root.elements.each("jdbc-system-resource") do |jdbcresource| 
              jdbcstr += jdbcresource.elements['name'].text + ";" 
              software += "       jdbc: " + jdbcresource.elements['name'].text + 
                                " targets:" + jdbcresource.elements['target'].text + "\n"
            end
            Facter.add("ora_mdw_#{i}_domain_#{n}_jdbc") do
              setcode do
                jdbcstr
              end
            end

            domains.push software
            l += 1
          end
          Facter.add("ora_mdw_#{i}_domain_cnt") do
            setcode do
              l
            end
          end
        end
        return domains
      end
    else
      return nil  
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
  if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?Facter.value(:operatingsystem)
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
      return nil
    end
  end
end

def get_orainst_products(path)
  if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?Facter.value(:operatingsystem)
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
  get_homes.each do |item|
    Facter.add("ora_mdw_homes") do
      setcode do
        str = ""
        get_homes.each do |item|
          str += item + ";"
        end 
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
unless get_orainst_loc.nil?
  Facter.add("ora_inst_products") do
    setcode do
      inventory = get_orainst_products(get_orainst_loc)
    end
  end
end
