require 'spec_helper'

describe 'jdk7::urandomfix' , :type => :class do

  it { should contain_package('rng-tools').with_ensure('present') }

  describe "Windows" do
    let(:facts) {{ :kernel          => 'Windows',
                   :operatingsystem => 'Windows'}}
    it do
      expect { should contain_exec('set urandom /etc/sysconfig/rngd')
             }.to raise_error(Puppet::Error, /Unrecognized operating system/)
    end       
  end
  describe "SunOS" do
    let(:facts) {{ :kernel          => 'SunOS',
                   :operatingsystem => 'Solaris'}}
    it do
      expect { should contain_exec('set urandom /etc/sysconfig/rngd')
             }.to raise_error(Puppet::Error, /Unrecognized operating system/)
    end       
  end

  describe "CentOS" do
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}
    
    describe "on operatingsystem CentOS" do
      it do 
        should contain_exec('set urandom /etc/sysconfig/rngd').with({
            'user'  => 'root',
          })    
      end
      it do
        should contain_service('start rngd service').with({
            'ensure'     => true,
            'enable'     => true,
          })
      end
      it do 
        should contain_exec('chkconfig rngd').with({
            'user'    => 'root',
            'command' => "chkconfig --add rngd",
          })    
      end
    end

  end


  ['Ubuntu','Debian','SLES'].each do |system|
    let(:facts) {{ :operatingsystem => system , 
                   :kernel          => 'Linux',
                   :osfamily        => 'Debian' }}

    describe "on operatingsystem #{system}" do
      it do 
        should contain_exec('set urandom /etc/default/rng-tools').with({
            'user'  => 'root',
          })
      end
      it do
        should contain_service('start rng-tools service').with({
            'ensure'     => true,
            'enable'     => true,
          })
      end
    end
  end

end
