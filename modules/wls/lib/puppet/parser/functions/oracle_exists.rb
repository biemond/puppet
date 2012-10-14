# restart the puppetmaster when changed
module Puppet::Parser::Functions
  newfunction(:oracle_exists, :type => :rvalue) do |args|
    
    ora_exists = false

    ora = lookupvar('ora_inst_products')
    unless ora.nil?

      software = args[0]
      os = lookupvar('operatingsystem')
      if os == "windows"
        software = software.gsub("/","\\")
      end 
      if ora.include? software
        return true
      end

    end
    return ora_exists
  end
end

