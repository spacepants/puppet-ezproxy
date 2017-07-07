require 'spec_helper'

describe 'ezproxy::remote_config', type: :define do
  let(:facts) {{
    osfamily:                  'RedHat',
    architecture:              'x86_64',
    operatingsystemmajrelease: '6',
  }}
  let(:title) { 'sample' }
  let(:pre_condition) { " class { 'ezproxy': key => 'abc123' } " }

  context 'passing the required params' do
    let(:params) {{
      download_link: 'http://www.test.url/path/to/config',
      file_name: 'sample_config',
    }}

    it { is_expected.to contain_exec('download sample config').with(
      command: 'curl -o /usr/local/ezproxy/sample_config http://www.test.url/path/to/config',
      creates: '/usr/local/ezproxy/sample_config',
      path: '/sbin:/bin:/usr/sbin:/usr/bin',
      ).that_notifies('Exec[sanitize sample config]').that_requires('File[/usr/local/ezproxy]')
    }
    it { is_expected.to contain_exec('sanitize sample config').with(
      command: 'dos2unix /usr/local/ezproxy/sample_config',
      path: '/sbin:/bin:/usr/sbin:/usr/bin',
      refreshonly: true,
      )
    }
    it { is_expected.to contain_concat__fragment('sample').with(
      target: 'ezproxy group default',
      source: '/usr/local/ezproxy/sample_config',
      order: '1',
      ).that_requires('Exec[sanitize sample config]')
    }
  end

  context 'passing all params' do
    let(:params) {{
      download_link: 'http://www.test.url/path/to/config',
      file_name: 'sample_config',
      order: '2',
    }}

    it { is_expected.to contain_exec('download sample config').with(
      command: 'curl -o /usr/local/ezproxy/sample_config http://www.test.url/path/to/config',
      creates: '/usr/local/ezproxy/sample_config',
      path: '/sbin:/bin:/usr/sbin:/usr/bin',
      ).that_notifies('Exec[sanitize sample config]').that_requires('File[/usr/local/ezproxy]')
    }
    it { is_expected.to contain_concat__fragment('sample').with(
      target: 'ezproxy group default',
      source: '/usr/local/ezproxy/sample_config',
      order: '2',
      ).that_requires('Exec[sanitize sample config]')
    }
  end
end
