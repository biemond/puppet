# restart the puppetmaster when changed
module Puppet::Parser::Functions
  newfunction(:oracle_exists, :type => :rvalue) do |args|
    
    ora_exists = false

    ora = lookupvar('ora_inst_products')
    unless ora.nil?
      if ora.include? args[0]
        return true
      end
    end
    return ora_exists
  end
end

