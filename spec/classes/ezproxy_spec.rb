require 'spec_helper'

describe 'ezproxy' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge({
            :concat_basedir  => '/var/lib/puppet/concat'
          })
        end

        context "ezproxy class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('ezproxy') }
          it { is_expected.to contain_class('ezproxy::params') }
          it { is_expected.to contain_class('ezproxy::install').that_comes_before('ezproxy::config') }
          it { is_expected.to contain_class('ezproxy::config') }
          it { is_expected.to contain_class('ezproxy::service').that_subscribes_to('ezproxy::config') }

          it { is_expected.to contain_group('ezproxy').with_ensure('present') }
          it { is_expected.to contain_user('ezproxy').with_ensure('present') }
          it { is_expected.to contain_file('/usr/local/ezproxy').with_ensure('directory') }
          it { is_expected.to contain_exec('download ezproxy').with_creates('/usr/local/ezproxy/ezproxy') }
          it { is_expected.to contain_file('/usr/local/ezproxy/ezproxy').with_mode('0755') }
          it { is_expected.to contain_exec('bootstrap ezproxy').with_refreshonly(true) }
          it { is_expected.to contain_file('/usr/local/ezproxy/user.txt').with_ensure('file') }
          it { is_expected.to contain_file('/usr/local/ezproxy/config.txt').with_ensure('file') }
          it { is_expected.to contain_file('ezproxy sites').with_ensure('present') }
          it { is_expected.to contain_ezproxy__stanza('Worldcat.org') }
          it { is_expected.to contain_ezproxy__stanza('WhatIsMyIP') }
          it { is_expected.to contain_ezproxy__stanza('DOI System').with_hide(true) }

          it { is_expected.to contain_file('/etc/init.d/ezproxy').with_content(/su - ezproxy "\$EZPROXY \$\*"\n$/) }
          it { is_expected.to contain_service('ezproxy').with_ensure('running') }

          it { is_expected.to contain_class('concat::setup') }
          it { is_expected.to contain_concat('ezproxy sites').with_path('/usr/local/ezproxy/sites.txt') }
          it { is_expected.to contain_concat__fragment('Worldcat.org').with_ensure('present') }
          it { is_expected.to contain_concat__fragment('WhatIsMyIP').with_ensure('present') }
          it { is_expected.to contain_concat__fragment('DOI System').with_ensure('present') }
          it { is_expected.to contain_exec('concat_ezproxy sites') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'ezproxy class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_service('ezproxy') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
