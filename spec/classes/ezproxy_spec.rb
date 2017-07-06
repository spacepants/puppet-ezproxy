require 'spec_helper'

describe 'ezproxy' do
  test_on = {
    hardwaremodels: ['i386', 'x86_64']
  }
  on_supported_os(test_on).each do |os, os_facts|
    context "with default parameters on #{os}" do
      let(:facts) { os_facts }
      let(:config_default) { '### MANAGED BY PUPPET
RunAs ezproxy:ezproxy
Name foo.example.com
FirstPort 5000
LoginPort 80
MaxLifetime 120
MaxSessions 500
MaxVirtualHosts 1000
Option SafariCookiePatch
Audit Most
AuditPurge 7
Option StatusUser
Option LogSession
IntruderIPAttempts -interval=5 -expires=15 20
IntruderUserAttempts -interval=5 -expires=15 10
UsageLimit -enforce -interval=15 -expires=120 -MB=200 Global
LogFile -strftime ezp%Y%m.log
LogFormat %h %l %u %t "%r" %s %b
IncludeFile groups.txt
'
      }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('ezproxy') }
      it { is_expected.to contain_class('ezproxy::params') }
      it { is_expected.to contain_class('ezproxy::install').that_comes_before('Class[ezproxy::config]') }
      it { is_expected.to contain_class('ezproxy::config') }
      it { is_expected.to contain_class('ezproxy::service').that_subscribes_to('Class[ezproxy::config]') }

      it { is_expected.to contain_group('ezproxy').with(
        ensure: 'present',
        system: true,
        )
      }
      case os_facts[:osfamily]
      when 'Debian'
        it { is_expected.to contain_user('ezproxy').with(
          ensure: 'present',
          system: true,
          home: '/usr/local/ezproxy',
          shell: '/usr/sbin/nologin',
          gid: 'ezproxy',
          ).that_requires('Group[ezproxy]')
        }
      when 'RedHat'
        it { is_expected.to contain_user('ezproxy').with(
          ensure: 'present',
          system: true,
          home: '/usr/local/ezproxy',
          shell: '/sbin/nologin',
          gid: 'ezproxy',
          ).that_requires('Group[ezproxy]')
        }
      end
      it { is_expected.to contain_file('/usr/local/ezproxy').with(
        ensure: 'directory',
        owner: 'ezproxy',
        group: 'ezproxy',
        ).that_requires('User[ezproxy]')
      }

      it { is_expected.to contain_exec('download ezproxy').with(
        command: 'curl -o /usr/local/ezproxy/ezproxy https://www.oclc.org/content/dam/support/ezproxy/documentation/download/binaries/5-7-44/ezproxy-linux.bin',
        creates: '/usr/local/ezproxy/ezproxy',
        path: '/sbin:/bin:/usr/sbin:/usr/bin',
        ).that_requires('File[/usr/local/ezproxy]')
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/ezproxy').with(
        ensure: 'present',
        mode: '0755',
        owner: 'ezproxy',
        group: 'ezproxy',
        ).that_requires('Exec[download ezproxy]').that_notifies('Exec[bootstrap ezproxy]')
      }

      it { is_expected.to contain_package('dos2unix').with(
        ensure: 'installed',
        ).that_notifies('Exec[bootstrap ezproxy]')
      }

      if os_facts[:osfamily] == 'RedHat' && os_facts[:architecture] == 'x86_64'
        it { is_expected.to contain_package('glibc.i686').with(
          ensure: 'installed',
          ).that_notifies('Exec[bootstrap ezproxy]')
        }
      end

      it { is_expected.to contain_exec('bootstrap ezproxy').with(
        command: '/usr/local/ezproxy/ezproxy -mg',
        refreshonly: true,
        returns: '1',
        )
      }

      it { is_expected.to contain_file('/usr/local/ezproxy/user.txt').with(
        ensure: 'file',
        owner: 'ezproxy',
        group: 'ezproxy',
        content: "## MANAGED BY PUPPET\n",
        )
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/config.txt').with(
        ensure: 'file',
        owner: 'ezproxy',
        group: 'ezproxy',
        content: config_default,
        )
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/license.txt').with(
        ensure: 'file',
        owner: 'ezproxy',
        group: 'ezproxy',
        )
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/mimetype').with(
        ensure: 'file',
        owner: 'ezproxy',
        group: 'ezproxy',
        )
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/docs').with(
        ensure: 'directory',
        owner: 'ezproxy',
        group: 'ezproxy',
        )
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/docs/cookie.htm').with(
        ensure: 'file',
        owner: 'ezproxy',
        group: 'ezproxy',
        )
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/docs/https.htm').with(
        ensure: 'file',
        owner: 'ezproxy',
        group: 'ezproxy',
        )
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/docs/login.htm').with(
        ensure: 'file',
        owner: 'ezproxy',
        group: 'ezproxy',
        )
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/docs/loginbu.htm').with(
        ensure: 'file',
        owner: 'ezproxy',
        group: 'ezproxy',
        )
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/docs/logout.htm').with(
        ensure: 'file',
        owner: 'ezproxy',
        group: 'ezproxy',
        )
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/docs/logup.htm').with(
        ensure: 'file',
        owner: 'ezproxy',
        group: 'ezproxy',
        )
      }
      it { is_expected.to contain_file('/usr/local/ezproxy/docs/menu.htm').with(
        ensure: 'file',
        owner: 'ezproxy',
        group: 'ezproxy',
        )
      }
      it { is_expected.to contain_concat('ezproxy groups').with(
        ensure: 'present',
        path: '/usr/local/ezproxy/groups.txt',
        owner: 'ezproxy',
        group: 'ezproxy',
        )
      }
      it { is_expected.to contain_ezproxy__group('default').with(
        auto_login_ips: [],
        include_ips: [],
        exclude_ips: [],
        reject_ips: [],
        group_order: '999999',
        )
      }
      it { is_expected.to contain_ezproxy__stanza('Worldcat.org').with(
        urls: ['http://worldcat.org'],
        domain_js: ['worldcat.org'],
        order: ['1'],
        group: 'default',
        )
      }
      it { is_expected.to contain_ezproxy__stanza('WhatIsMyIP').with(
        urls: ['http://whatismyip.com'],
        domain_js: ['whatismyip.com'],
        order: ['1'],
        group: 'default',
        )
      }
      it { is_expected.to contain_ezproxy__stanza('DOI System').with(
        urls: ['http://dx.doi.org'],
        domains: ['doi.org'],
        order: ['1'],
        group: 'default',
        hide: true,
        )
      }

      it { is_expected.to contain_file('/etc/init.d/ezproxy').with(
        ensure: 'file',
        mode: '0755',
        content: %r{/usr/local/ezproxy/ezproxy \$\*\n},
        )
      }
      it { is_expected.to contain_service('ezproxy').with(
        ensure: 'running',
        enable: true,
        hasstatus: true,
        hasrestart: true,
        ).that_requires('File[/etc/init.d/ezproxy]')
      }
    end
  end

  context 'on amd64 hardwaremodels' do
    test_on = {
      supported_os: [
        {
          'operatingsystem'        => 'Debian',
          'operatingsystemrelease' => ['6', '7', '8'],
        },
        {
          'operatingsystem'        => 'Ubuntu',
          'operatingsystemrelease' => ['12.04', '14.04', '16.04'],
        },
      ],
    }
    on_supported_os(test_on).each do |_os, os_facts|
      context "with default parameters on #{os_facts[:operatingsystem]}-#{os_facts[:operatingsystemrelease]}-amd64" do
        let(:facts) do
          os_facts.merge(architecture: 'amd64')
        end

        if os_facts[:operatingsystem] == 'Ubuntu' && os_facts[:operatingsystemrelease] == '12.04'
          it { is_expected.to contain_package('lib32z1').with(
            ensure: 'installed',
            ).that_notifies('Exec[bootstrap ezproxy]')
          }
        else
          it { is_expected.to contain_package('ia32-libs').with(
            ensure: 'installed',
            ).that_notifies('Exec[bootstrap ezproxy]')
          }
        end
      end
    end
  end

  context 'ezproxy class with parameter overrides' do
    let(:facts) {{
      osfamily:       'RedHat',
      architecture:   'x86_64',
    }}

    context 'ezproxy class with custom parameters' do
      let(:params) {{
        'ezproxy_group'     => 'custom_group',
        'ezproxy_user'      => 'custom_user',
        'install_path'      => '/custom/install/path',
        'ezproxy_url'       => 'my.ezproxy.url',
        'download_url'      => 'http://my.ezproxy.download/link',
        'dependencies'      => ['package1', 'package2'],
        'first_port'        => '9001',
        'auto_login_ips'    => ['1.0.0.0-1.255.255.255', '2.0.0.0-2.255.255.255'],
        'include_ips'       => ['3.0.0.0-3.255.255.255', '4.0.0.0-4.255.255.255'],
        'exclude_ips'       => ['5.0.0.0-5.255.255.255', '6.0.0.0-6.255.255.255'],
        'reject_ips'        => ['7.0.0.0-7.255.255.255', '8.0.0.0-8.255.255.255'],
        'login_port'        => '8080',
        'ssl'               => true,
        'https_login'       => true,
        'https_admin'       => true,
        'max_lifetime'      => '360',
        'max_sessions'      => '1000',
        'max_vhosts'        => '5000',
        'log_filters'       => ['*.gif*', '*.jpg*'],
        'log_format'        => '%t %h %l %u "%r" %s %b "%{Referer}i" "%{user-agent}i"',
        'log_file'          => '/var/log/ezproxy/ezproxy.log',
        'local_users'       => ['user1:supersecure:admin', 'user2:coolpass:admin'],
        'default_stanzas'   => false,
        'service_name'      => 'custom-service',
        'service_status'    => 'stopped',
        'service_enable'    => false,
      }}
      let(:custom_config) { '### MANAGED BY PUPPET
RunAs custom_user:custom_group
Name my.ezproxy.url
FirstPort 9001
LoginPort 8080
LoginPortSSL 443
Option ForceHTTPSLogin
Option ForceHTTPSAdmin
MaxLifetime 360
MaxSessions 1000
MaxVirtualHosts 5000
Option SafariCookiePatch
Audit Most
AuditPurge 7
Option StatusUser
Option LogSession
IntruderIPAttempts -interval=5 -expires=15 20
IntruderUserAttempts -interval=5 -expires=15 10
UsageLimit -enforce -interval=15 -expires=120 -MB=200 Global
LogFilter *.gif*
LogFilter *.jpg*
LogFile /var/log/ezproxy/ezproxy.log
LogFormat %t %h %l %u "%r" %s %b "%{Referer}i" "%{user-agent}i"
IncludeFile groups.txt
'
      }

      it { is_expected.to contain_group('custom_group').with(
        ensure: 'present',
        system: true,
        )
      }
      it { is_expected.to contain_user('custom_user').with(
        ensure: 'present',
        system: true,
        home: '/custom/install/path',
        shell: '/sbin/nologin',
        gid: 'custom_group',
        ).that_requires('Group[custom_group]')
      }
      it { is_expected.to contain_file('/custom/install/path').with(
        ensure: 'directory',
        owner: 'custom_user',
        group: 'custom_group',
        ).that_requires('User[custom_user]')
      }
      it { is_expected.to contain_package('package1').with_ensure('installed').that_notifies('Exec[bootstrap ezproxy]') }
      it { is_expected.to contain_package('package2').with_ensure('installed').that_notifies('Exec[bootstrap ezproxy]') }
      it { is_expected.to contain_exec('download ezproxy').with(
        command: 'curl -o /custom/install/path/ezproxy http://my.ezproxy.download/link/5-7-44/ezproxy-linux.bin',
        creates: '/custom/install/path/ezproxy',
        path: '/sbin:/bin:/usr/sbin:/usr/bin',
        ).that_requires('File[/custom/install/path]')
      }
      it { is_expected.to contain_file('/custom/install/path/ezproxy').with(
        ensure: 'present',
        mode: '0755',
        owner: 'custom_user',
        group: 'custom_group',
        ).that_requires('Exec[download ezproxy]').that_notifies('Exec[bootstrap ezproxy]')
      }
      it { is_expected.to contain_file('/custom/install/path/user.txt').with(
        ensure: 'file',
        owner: 'custom_user',
        group: 'custom_group',
        content: "## MANAGED BY PUPPET\nuser1:supersecure:admin\nuser2:coolpass:admin\n",
        )
      }
      it { is_expected.to contain_file('/custom/install/path/config.txt').with(
        ensure: 'file',
        owner: 'custom_user',
        group: 'custom_group',
        content: custom_config,
        )
      }
      it { is_expected.to contain_file('/custom/install/path/license.txt').with(
        ensure: 'file',
        owner: 'custom_user',
        group: 'custom_group',
        )
      }
      it { is_expected.to contain_file('/custom/install/path/mimetype').with(
        ensure: 'file',
        owner: 'custom_user',
        group: 'custom_group',
        )
      }
      it { is_expected.to contain_file('/custom/install/path/docs').with(
        ensure: 'directory',
        owner: 'custom_user',
        group: 'custom_group',
        )
      }
      it { is_expected.to contain_file('/custom/install/path/docs/cookie.htm').with(
        ensure: 'file',
        owner: 'custom_user',
        group: 'custom_group',
        )
      }
      it { is_expected.to contain_file('/custom/install/path/docs/https.htm').with(
        ensure: 'file',
        owner: 'custom_user',
        group: 'custom_group',
        )
      }
      it { is_expected.to contain_file('/custom/install/path/docs/login.htm').with(
        ensure: 'file',
        owner: 'custom_user',
        group: 'custom_group',
        )
      }
      it { is_expected.to contain_file('/custom/install/path/docs/loginbu.htm').with(
        ensure: 'file',
        owner: 'custom_user',
        group: 'custom_group',
        )
      }
      it { is_expected.to contain_file('/custom/install/path/docs/logout.htm').with(
        ensure: 'file',
        owner: 'custom_user',
        group: 'custom_group',
        )
      }
      it { is_expected.to contain_file('/custom/install/path/docs/logup.htm').with(
        ensure: 'file',
        owner: 'custom_user',
        group: 'custom_group',
        )
      }
      it { is_expected.to contain_file('/custom/install/path/docs/menu.htm').with(
        ensure: 'file',
        owner: 'custom_user',
        group: 'custom_group',
        )
      }

      it { is_expected.not_to contain_ezproxy__stanza('Worldcat.org') }
      it { is_expected.not_to contain_ezproxy__stanza('WhatIsMyIP') }
      it { is_expected.not_to contain_ezproxy__stanza('DOI System') }

      it { is_expected.to contain_file('/etc/init.d/custom-service').with(
        ensure: 'file',
        mode: '0755',
        content: %r{/custom/install/path/ezproxy \$\*\n},
        )
      }
      it { is_expected.to contain_service('custom-service').with(
        ensure: 'stopped',
        enable: false,
        hasstatus: true,
        hasrestart: true,
        )
      }
    end

    context 'ezproxy class with cas authentication' do
      let(:params) {{
        'cas'                      => true,
        'cas_login_url'            => 'https://my.cas.server/login',
        'cas_service_validate_url' => 'https://my.cas.server/serviceValidate',
        'admins'                   => ['casadmin1', 'casadmin2'],
      }}
      let(:cas_config) { '## MANAGED BY PUPPET
# CAS CONFIG
::CAS
LoginURL https://my.cas.server/login
ServiceValidateURL https://my.cas.server/serviceValidate
IfUser casadmin1; Admin
IfUser casadmin2; Admin
/CAS
'
      }

      it { is_expected.to contain_file('/usr/local/ezproxy/user.txt').with_content(cas_config) }
    end

    context 'ezproxy class with ldap authentication' do
      let(:params) {{
        'ldap'         => true,
        'ldap_options' => ['BindUser CN=ezproxy,DC=mydomain,DC=edu', 'BindPassword supersecret'],
        'ldap_url'     => 'ldap://ldap.mydomain.edu/dc=mydomain,dc=edu?uid',
        'admins'       => ['ldapadmin1', 'ldapadmin2'],
      }}
      let(:ldap_config) { '## MANAGED BY PUPPET
# LDAP CONFIG
::LDAP
BindUser CN=ezproxy,DC=mydomain,DC=edu
BindPassword supersecret
URL ldap://ldap.mydomain.edu/dc=mydomain,dc=edu?uid
IfUnauthenticated; Stop
IfUser ldapadmin1; Admin
IfUser ldapadmin2; Admin
/LDAP
'
      }

      it { is_expected.to contain_file('/usr/local/ezproxy/user.txt').with_content(ldap_config) }
    end

    context 'ezproxy class with with proxy_by_hostname enabled' do
      let(:params) {{
        'proxy_by_hostname' => true
      }}

      it { is_expected.to contain_file('/usr/local/ezproxy/config.txt').with_content(/Option ProxyByHostname/) }
      it { is_expected.not_to contain_file('/usr/local/ezproxy/config.txt').with_content(/FirstPort/) }
    end

    context 'ezproxy class with with service management disabled' do
      let(:params) {{
        'manage_service' => false
      }}

      it { is_expected.not_to contain_service('ezproxy') }
    end
  end

  context 'unsupported operating system' do
    describe 'ezproxy class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        osfamily:        'Solaris',
        operatingsystem: 'Nexenta',
      }}

      it { expect { is_expected.to contain_class('ezproxy') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
