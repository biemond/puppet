# restart the puppetmaster when changed
module Puppet::Parser::Functions
  newfunction(:wls_exists, :type => :rvalue) do |args|
    
    wls_exists = false

    # check the middleware home
    mdw_count = lookupvar('ora_mdw_cnt')
    if mdw_count.nil?
      return art_exists
    else
      # check the all mdw home
      i = 0
      while ( i < mdw_count.to_i) 
        mdw = lookupvar('ora_mdw_'+i.to_s)
        unless mdw.nil?
          mdw = mdw.strip
          if mdw == args[0].strip
            return true
          end
        end 
        i += 1
      end
    end
    return wls_exists
  end
end

