require 'spec_helper'

describe 'ezproxy::group', type: :define do
  let(:facts) {{
    osfamily:                  'RedHat',
    architecture:              'x86_64',
    operatingsystemmajrelease: '6',
  }}
  let(:title) { 'sample' }
  let(:pre_condition) { 'include ezproxy' }

  context 'passing the required params' do
    it { is_expected.to contain_concat('ezproxy group default').with(
      ensure: 'present',
      path: '/usr/local/ezproxy/group_default.txt',
      owner: 'ezproxy',
      group: 'ezproxy',
      )
    }
    it { is_expected.to contain_concat__fragment('default header').with(
      target: 'ezproxy group default',
      content: "Group default\n",
      order: '0',
      )
    }
    it { is_expected.to contain_concat__fragment('default load order').with(
      target: 'ezproxy groups',
      content: "IncludeFile group_default.txt\n",
      order: '999999',
      )
    }

    it { is_expected.to contain_concat('ezproxy group sample').with(
      ensure: 'present',
      path: '/usr/local/ezproxy/group_sample.txt',
      owner: 'ezproxy',
      group: 'ezproxy',
      )
    }
    it { is_expected.to contain_concat__fragment('sample header').with(
      target: 'ezproxy group sample',
      content: "Group sample\n",
      order: '0',
      )
    }
    it { is_expected.to contain_concat__fragment('sample load order').with(
      target: 'ezproxy groups',
      content: "IncludeFile group_sample.txt\n",
      order: '0',
      )
    }
  end

  context 'passing all params' do
    let(:params) {{
      'auto_login_ips' => ['1.0.0.0-1.255.255.255', '2.0.0.0-2.255.255.255'],
      'include_ips'    => ['3.0.0.0-3.255.255.255', '4.0.0.0-4.255.255.255'],
      'exclude_ips'    => ['5.0.0.0-5.255.255.255', '6.0.0.0-6.255.255.255'],
      'reject_ips'     => ['7.0.0.0-7.255.255.255', '8.0.0.0-8.255.255.255'],
    }}
    let(:spec_content) { 'Group sample
A 1.0.0.0-1.255.255.255
A 2.0.0.0-2.255.255.255
I 3.0.0.0-3.255.255.255
I 4.0.0.0-4.255.255.255
E 5.0.0.0-5.255.255.255
E 6.0.0.0-6.255.255.255
R 7.0.0.0-7.255.255.255
R 8.0.0.0-8.255.255.255
'
    }

    it { is_expected.to contain_concat('ezproxy group sample').with(
      ensure: 'present',
      path: '/usr/local/ezproxy/group_sample.txt',
      owner: 'ezproxy',
      group: 'ezproxy',
      )
    }
    it { is_expected.to contain_concat__fragment('sample header').with(
      target: 'ezproxy group sample',
      content: spec_content,
      order: '0',
      )
    }
    it { is_expected.to contain_concat__fragment('sample load order').with(
      target: 'ezproxy groups',
      content: "IncludeFile group_sample.txt\n",
      order: '0',
      )
    }
  end
end
