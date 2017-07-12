require 'spec_helper'

describe 'ezproxy::stanza', type: :define do
  let(:facts) {{
    osfamily:                  'RedHat',
    architecture:              'x86_64',
    operatingsystemmajrelease: '6',
    puppetversion:             '4.10.4',
  }}
  let(:title) { 'sample' }
  let(:pre_condition) { " class { 'ezproxy': key => 'abc123' } " }

  context 'passing the required params' do
    let(:params) {{ urls: ['http://www.test.url'] }}

    it { is_expected.to contain_concat__fragment('Worldcat.org').with(
      target: 'ezproxy group default',
      content: "T Worldcat.org\nU http://worldcat.org\nDJ worldcat.org\n",
      order: '1',
      )
    }
    it { is_expected.to contain_concat__fragment('WhatIsMyIP').with(
      target: 'ezproxy group default',
      content: "T WhatIsMyIP\nU http://whatismyip.com\nDJ whatismyip.com\n",
      order: '1',
      )
    }
    it { is_expected.to contain_concat__fragment('DOI System').with(
      target: 'ezproxy group default',
      content: "T -hide DOI System\nU http://dx.doi.org\nD doi.org\n",
      order: '1',
      )
    }

    it { is_expected.to contain_concat__fragment('sample').with(
      target: 'ezproxy group default',
      content: "T sample\nU http://www.test.url\n",
      order: '2',
      )
    }
  end

  context 'passing all params' do
    let(:params) {{
      urls: ['http://www.test1.url', 'http://www.test2.url'],
      prepends: ['Option DoAThing', 'Option DoAnotherThing'],
      hosts: ['www.test1.url', 'www.test2.url'],
      domains: ['test1.url', 'test2.url'],
      domain_js: ['test3.url', 'test4.url'],
      host_js: ['js.test3.url', 'js.test4.url'],
      appends: ['Option StopDoingAThing', 'Option StopDoingAnotherThing'],
      order: '3',
    }}
    let(:spec_content) { 'Option DoAThing
Option DoAnotherThing
T sample
U http://www.test1.url
U http://www.test2.url
H www.test1.url
H www.test2.url
D test1.url
D test2.url
DJ test3.url
DJ test4.url
HJ js.test3.url
HJ js.test4.url
Option StopDoingAThing
Option StopDoingAnotherThing
'
    }

    it { is_expected.to contain_concat__fragment('sample').with(
      target: 'ezproxy group default',
      content: spec_content,
      order: '3',
      )
    }
  end
end
