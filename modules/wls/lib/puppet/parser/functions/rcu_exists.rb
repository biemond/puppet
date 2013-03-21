#require "java"
#require "ojdbc6.jar"

module Puppet::Parser::Functions
  newfunction(:rcu_exists, :type => :rvalue) do |args|

		return false
#    Java::OracleJdbcDriver::OracleDriver
    
    rcu_exists = false
    url = "jdbc:oracle:thin:@puppetmaster:1521:XE"
    con = java.sql.DriverManager.getConnection(url, "hr", "hr");
    if con
      return true
    else
      return false
    end

  end
end

