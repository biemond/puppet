# oracle_middleware_homes.rb



if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?Facter.value(:operatingsystem)
  if FileTest.exists?("/home/oracle/bea/beahomelist")
    output = File.read("/home/oracle/bea/beahomelist")
    output.split(/;/).each_with_index do |item, i|
      Facter.add("oracle_middleware_homes_#{i}") do
        setcode do
          "#{item}"
        end
      end
    end  
  end
end


Facter.add("oracle_middleware_homes") do
  confine :kernel => :linux
  setcode do
    if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?Facter.value(:operatingsystem)
      if FileTest.exists?("/home/oracle/bea/beahomelist")
        output = File.read("/home/oracle/bea/beahomelist")
      else
        "not found"
      end
    end 
  end
end

Facter.add("oracle_middleware_homes_count") do
  confine :kernel => :linux
  setcode do
    count = 0
    if ["centos", "redhat","OracleLinux","ubuntu","debian"].include?Facter.value(:operatingsystem)
      if FileTest.exists?("/home/oracle/bea/beahomelist")
        output = File.read("/home/oracle/bea/beahomelist")
        count = output.split(/;/).count
      end
    end 
    count
  end
end
