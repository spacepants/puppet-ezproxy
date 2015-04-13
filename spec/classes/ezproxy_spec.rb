require 'spec_helper'

describe 'ezproxy' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge( { :concat_basedir => '/var/lib/puppet/concat' } )
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

  context 'OS/arch specific default params' do
    let(:params) {{ }}
    context 'ezproxy class without any parameters on RedHat family systems' do
      let(:facts) {{
        :osfamily       => 'RedHat',
        :concat_basedir => '/var/lib/puppet/concat',
      }}

      it { is_expected.to contain_user('ezproxy').with_shell('/sbin/nologin') }

      context 'on 64 bit EL systems' do
        let(:facts) {{
          :osfamily       => 'RedHat',
          :architecture   => 'x86_64',
          :concat_basedir => '/var/lib/puppet/concat',
        }}

        it { is_expected.to contain_package('glibc.i686').with_ensure('installed') }
      end
    end

    context 'ezproxy class without any parameters on Debian family systems' do
      let(:facts) {{
        :osfamily       => 'Debian',
        :concat_basedir => '/var/lib/puppet/concat',
      }}

      it { is_expected.to contain_user('ezproxy').with_shell('/usr/sbin/nologin') }

      context 'on 64 bit Debian systems' do
        let(:facts) {{
          :osfamily        => 'Debian',
          :architecture    => 'amd64',
          :operatingsystem => 'Debian',
          :concat_basedir  => '/var/lib/puppet/concat',
        }}

        it { is_expected.to contain_package('ia32-libs').with_ensure('installed') }
      end

      context 'on 64 bit Ubuntu systems running 12.04' do
        let(:facts) {{
          :osfamily               => 'Debian',
          :architecture           => 'amd64',
          :operatingsystem        => 'Ubuntu',
          :operatingsystemrelease => '12.04',
          :concat_basedir         => '/var/lib/puppet/concat',
        }}

        it { is_expected.to contain_package('ia32-libs').with_ensure('installed') }
      end

      context 'on 64 bit Ubuntu systems running 14.04' do
        let(:facts) {{
          :osfamily               => 'Debian',
          :architecture           => 'amd64',
          :operatingsystem        => 'Ubuntu',
          :operatingsystemrelease => '14.04',
          :concat_basedir         => '/var/lib/puppet/concat',
        }}

        it { is_expected.to contain_package('lib32z1').with_ensure('installed') }
      end
    end
  end

  context "ezproxy class with parameter overrides" do
    let(:facts) {{
      :osfamily       => 'RedHat',
      :architecture   => 'x86_64',
      :concat_basedir => '/var/lib/puppet/concat',
    }}
    context 'ezproxy class with custom parameters' do
      let(:params) {{
        'ezproxy_group'     => 'custom_group',
        'ezproxy_user'      => 'custom_user',
        'install_path'      => '/custom/install/path',
        'ezproxy_url'       => 'my.ezproxy.url',
        'download_url'      => 'http://my.ezproxy.download/link',
        'dependencies'      => [ 'package1', 'package2' ],
        'first_port'        => 9001,
        'auto_login_ips'    => [ '1.0.0.0-1.255.255.255', '2.0.0.0-2.255.255.255' ],
        'include_ips'       => [ '3.0.0.0-3.255.255.255', '4.0.0.0-4.255.255.255' ],
        'exclude_ips'       => [ '5.0.0.0-5.255.255.255', '6.0.0.0-6.255.255.255' ],
        'login_port'        => '8080',
        'ssl'               => true,
        'https_login'       => true,
        'https_admin'       => true,
        'max_lifetime'      => '360',
        'max_sessions'      => '1000',
        'max_vhosts'        => '5000',
        'log_filters'       => [ '*.gif*', '*.jpg*' ],
        'log_format'        => '%t %h %l %u "%r" %s %b "%{Referer}i" "%{user-agent}i"',
        'log_file'          => '/var/log/ezproxy/ezproxy.log',
        'local_users'       => [ 'user1:supersecure:admin', 'user2:coolpass:admin' ],
        'default_stanzas'   => false,
        'service_name'      => 'custom-service',
        'service_status'    => 'stopped',
        'service_enable'    => false,
      }}

      it { is_expected.to contain_group('custom_group').with_ensure('present') }
      it { is_expected.to contain_user('custom_user').with_ensure('present') }
      it { is_expected.to contain_file('/custom/install/path').with_ensure('directory') }
      it { is_expected.to contain_package('package1').with_ensure('installed') }
      it { is_expected.to contain_package('package2').with_ensure('installed') }
      it { is_expected.to contain_exec('download ezproxy').with_creates('/custom/install/path/ezproxy') }
      it { is_expected.to contain_file('/custom/install/path/ezproxy').with_mode('0755') }
      it { is_expected.to contain_file('/custom/install/path/user.txt').with_content(/user1:supersecure:admin\nuser2:coolpass:admin/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/RunAs custom_user:custom_group/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/Name my.ezproxy.url/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/FirstPort 9001/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/A 1.0.0.0-1.255.255.255\nA 2.0.0.0-2.255.255.255/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/I 3.0.0.0-3.255.255.255\nI 4.0.0.0-4.255.255.255/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/E 5.0.0.0-5.255.255.255\nE 6.0.0.0-6.255.255.255/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/LoginPort 8080/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/LoginPortSSL 443\nOption ForceHTTPSLogin\nOption ForceHTTPSAdmin/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/MaxLifetime 360/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/MaxSessions 1000/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/MaxVirtualHosts 5000/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/LogFilter \*\.gif\*\nLogFilter \*\.jpg\*/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/LogFile \/var\/log\/ezproxy\/ezproxy\.log/) }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with_content(/LogFormat %t %h %l %u "%r" %s %b "%{Referer}i" "%{user-agent}i/) }
      it { is_expected.to contain_concat('ezproxy sites').with_path('/custom/install/path/sites.txt') }
      it { is_expected.not_to contain_concat__fragment('Worldcat.org').with_ensure('present') }
      it { is_expected.not_to contain_concat__fragment('WhatIsMyIP').with_ensure('present') }
      it { is_expected.not_to contain_concat__fragment('DOI System').with_ensure('present') }
      it { is_expected.to contain_file('/etc/init.d/custom-service').with_content(/su - custom_user "\$EZPROXY \$\*"$\n/) }
      it { is_expected.to contain_service('custom-service').with_ensure('stopped') }
    end

    context "ezproxy class with cas authentication" do
      let(:params) {{
        'cas'                      => true,
        'cas_login_url'            => 'https://my.cas.server/login',
        'cas_service_validate_url' => 'https://my.cas.server/serviceValidate',
        'admins'                   => [ 'casadmin1', 'casadmin2' ],
      }}

      it { is_expected.to contain_file('/usr/local/ezproxy/user.txt').with_content(/LoginURL https:\/\/my\.cas\.server\/login\nServiceValidateURL https:\/\/my\.cas\.server\/serviceValidate\nIfUser casadmin1; Admin\nIfUser casadmin2; Admin/) }
    end

    context "ezproxy class with ldap authentication" do
      let(:params) {{
        'ldap'         => true,
        'ldap_options' => [ 'BindUser CN=ezproxy,DC=mydomain,DC=edu', 'BindPassword supersecret' ],
        'ldap_url'     => 'ldap://ldap.mydomain.edu/dc=mydomain,dc=edu?uid',
        'admins'       => [ 'ldapadmin1', 'ldapadmin2' ],
      }}

      it { is_expected.to contain_file('/usr/local/ezproxy/user.txt').with_content(/::LDAP\nBindUser CN=ezproxy,DC=mydomain,DC=edu\nBindPassword supersecret\nURL ldap:\/\/ldap\.mydomain\.edu\/dc=mydomain,dc=edu\?uid\nIfUnauthenticated; Stop\nIfUser ldapadmin1; Admin\nIfUser ldapadmin2; Admin/) }
    end

    context "ezproxy class with with proxy_by_hostname enabled" do
      let(:params) {{
        'proxy_by_hostname' => true
      }}

      it { is_expected.to contain_file('/usr/local/ezproxy/config.txt').with_content(/Option ProxyByHostname/) }
      it { is_expected.not_to contain_file('/usr/local/ezproxy/config.txt').with_content(/FirstPort/) }
    end

    context "ezproxy class with with service management disabled" do
      let(:params) {{
        'manage_service' => false
      }}

      it { is_expected.not_to contain_service('ezproxy') }
    end
  end

  context 'unsupported operating system' do
    describe 'ezproxy class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_class('ezproxy') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
