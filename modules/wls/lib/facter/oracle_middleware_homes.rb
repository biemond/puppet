# oracle_middleware_homes.rb

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

# read middleware home in the oracle home folder
def get_domain(name)
  if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?Facter.value(:operatingsystem)
    if FileTest.exists?(name+'/admin')
      output = Facter::Util::Resolution.exec('/bin/ls '+name+'/admin')
      if output.nil?
        return nil
      else 
        return output.split(/\r?\n/)
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

# report all oracle homes / domains
unless get_homes.nil?
  get_homes.each_with_index do |mdw, i|
    Facter.add("ora_mdw_#{i}") do
      setcode do
        mdw
      end
    end
    unless get_domain(mdw).nil?
      get_domain(mdw).each_with_index do |domain, n|
        Facter.add("ora_mdw_#{i}_domain_#{n}") do
          setcode do
            domain
          end
        end
      end
    end
    Facter.add("ora_mdw_#{i}_domain_cnt") do
      setcode do
        if get_domain(mdw).nil?
          count = 0
        else        
          count = get_domain(mdw).count
        end
        count
      end
    end
  end 
end

# all homes on 1 row
Facter.add("ora_mdw_homes") do
  setcode do
    str = ""
    get_homes.each do |item|
      str += item + " -- "
    end
    str	
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


