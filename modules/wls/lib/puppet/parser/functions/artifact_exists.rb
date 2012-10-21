# restart the puppetmaster when changed
module Puppet::Parser::Functions
  newfunction(:artifact_exists, :type => :rvalue) do |args|
    
    art_exists = false
    mdwArg = args[0].strip.downcase

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
          mdw = mdw.strip.downcase
          os = lookupvar('operatingsystem')
          if os == "windows"
            mdw = mdw.gsub("\\","/")
            mdwArg = mdwArg.gsub("\\","/")
          end 
          

          # how many domains are there in this mdw home
          domain_count = lookupvar('ora_mdw_'+i.to_s+'_domain_cnt')
          n = 0
          while ( n < domain_count.to_i )

            # lookup up domain
            domain = lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s)
            unless domain.nil?
              domain = domain.strip.downcase
              
              domain_path = mdw + "/admin/" + domain

              # do we found the right domain
              if domain_path == mdwArg 
                
                type = args[1].strip
                
                # check jdbc datasources
                if type == 'jdbc'
                  if lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jdbc') != :undefined
                    jdbc =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jdbc')
                    unless jdbc.nil?
                      if jdbc.include? args[2]
                        return true
                      end
                    end
                  end
                elsif type == 'deployments'
                  if lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_deployments') != :undefined
                    deployments =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_deployments')
                    unless deployments.nil?
                      if deployments.include? args[2]
                        return true
                      end
                    end
                  end
                elsif type == 'filestore'
                  if lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_filestores') != :undefined
                    filestores =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_filestores')
                    unless filestores.nil?
                      if filestores.include? args[2]
                        return true
                      end
                    end
                  end
                elsif type == 'jdbcstore'
                  if lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jdbcstores') != :undefined
                    jdbcstores =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jdbcstores')
                    unless jdbcstores.nil?
                      if jdbcstores.include? args[2]
                        return true
                      end
                    end
                  end
                elsif type == 'safagent'
                  if lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jdbc') != :undefined
                    safagents =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_safagents')
                    unless safagents.nil?
                      if safagents.include? args[2]
                        return true
                      end
                    end
                  end
                elsif type == 'jmsserver'
                  if lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jmsservers') != :undefined
                    jmsservers =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jmsservers')
                    unless jmsservers.nil?
                      if jmsservers.include? args[2]
                        return true
                      end
                    end
                  end
                elsif type == 'jmsmodule'
                  if lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jmsmodules') != :undefined
                    jmsmodules =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jmsmodules')
                    unless jmsmodules.nil?
                      if jmsmodules.include? args[2]
                        return true
                      end
                    end
                  end

                elsif type == 'jmsobject'

                  if lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jmsmodule_cnt') != :undefined
                    jms_count =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jmsmodule_cnt')
                    unless jms_count.nil?
  
                      l = 0
                      while ( l < jms_count.to_i )
                        jmsobjects =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jmsmodule_'+l.to_s+'_objects')
                        unless jmsobjects.nil?
                          if jmsobjects.include? args[2]
                            return true
                          end
                        end
                        l += 1
                      end
                    end  
                  end

                elsif type == 'jmssubdeployment'
                  if lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jmsmodule_cnt') != :undefined
                    jms_count =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jmsmodule_cnt')
                    unless jms_count.nil?
  
                      l = 0
                      while ( l < jms_count.to_i )
                        jmssubobjects =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jmsmodule_'+l.to_s+'_subdeployments')
                        jmsmodule     =  lookupvar('ora_mdw_'+i.to_s+'_domain_'+n.to_s+'_jmsmodule_'+l.to_s+'_name')
                        if args[2].include? jmsmodule
                          unless jmssubobjects.nil?
                            pattern = "\/(.*)"
                            sub_string = args[2].match pattern
                            if jmssubobjects.include? sub_string[1]
                              return true
                            end
                          end
                        end
                        l += 1
                      end
  
                    end
                  end 


                end # if type               
              end  # domain_path equal 
            end # domain not nil           
            n += 1

          end  # while domain

        end 
        i += 1
      end # while mdw

    end # mdw count

    return art_exists
  end
end

