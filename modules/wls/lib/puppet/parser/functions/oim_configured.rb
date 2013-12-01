# restart the puppetmaster when changed
module Puppet::Parser::Functions
  newfunction(:oim_configured, :type => :rvalue) do |args|
    
    art_exists = "notfound"
    if args[0].nil?
      return art_exists
    else
      wlsDomain = args[0].strip.downcase
    end    
    
    prefix = "ora_mdw"
    
    
    # check the middleware home
    mdw_count = lookupWlsVar(prefix+'_cnt')
    if mdw_count == "empty"
      return art_exists
    else
      # check the all mdw home
      i = 0
      while ( i < mdw_count.to_i) 

          mdw = lookupWlsVar(prefix+'_'+i.to_s)
          mdw = mdw.strip.downcase
          os = lookupvar('operatingsystem')
          if os == "windows"
            mdw = mdw.gsub("\\","/")
            wlsDomain = wlsDomain.gsub("\\","/")
          end 
          

          # how many domains are there in this mdw home
          domain_count = lookupWlsVar(prefix+'_'+i.to_s+'_domain_cnt')
          n = 0
          while ( n < domain_count.to_i )

            # lookup up domain
              domain = lookupWlsVar(prefix+'_'+i.to_s+'_domain_'+n.to_s)  
              domain = domain.strip.downcase

              # do we found the right domain
              if domain == wlsDomain 
                return lookupWlsVar(prefix+'_'+i.to_s+'_domain_'+n.to_s+'_oim_configured')
              end # domain not nil           
            n += 1

          end  # while domain

        i += 1
      end # while mdw

    end # mdw count

    return art_exists
  end
end

def lookupWlsVar(name)
  #puts "lookup fact "+name
  if wlsVarExists(name)
    return lookupvar(name).to_s
  end
  #puts "return empty"
  return "empty"
end

def wlsVarExists(name)
  #puts "lookup fact "+name
  if lookupvar(name) != :undefined
    if lookupvar(name).nil?
      #puts "return false"
      return false
    end
    return true 
  end
  #puts "not found"
  return false 
end   
