# restart the puppetmaster when changed
module Puppet::Parser::Functions
  newfunction(:slash_replace, :type => :rvalue) do |args|
    
    newValue    = args[0].strip.gsub("/","\\")
    return newValue

  end
end
