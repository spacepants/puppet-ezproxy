require 'spec_helper'

describe 'ezproxy::group', :type => :define do
  let(:facts) {{ :concat_basedir => '/var/lib/puppet/concat' }}
  let(:title) { 'sample' }

  context 'passing the required params' do
    it { is_expected.to contain_concat('ezproxy group sample').with({
      'ensure' => 'present',
      #'path'   => "${::ezproxy::install_path}/group_${name}.txt",
    }) }
    it { is_expected.to contain_concat__fragment('sample header').with({
      'target'  => 'ezproxy group sample',
      'content' => /Group sample/,
      'order'   => '0',
    }) }

  end

  context 'passing all params' do
    let(:params) {{
      'auto_login_ips' => [ '1.0.0.0-1.255.255.255', '2.0.0.0-2.255.255.255' ],
      'include_ips'    => [ '3.0.0.0-3.255.255.255', '4.0.0.0-4.255.255.255' ],
      'exclude_ips'    => [ '5.0.0.0-5.255.255.255', '6.0.0.0-6.255.255.255' ],
      'reject_ips'     => [ '7.0.0.0-7.255.255.255', '8.0.0.0-8.255.255.255' ],
    }}

    it { is_expected.to contain_concat('ezproxy group sample').with({
      'ensure' => 'present',
    }) }
    it { is_expected.to contain_concat__fragment('sample header').with({
      'target'  => 'ezproxy group sample',
      'content' => /A 1.0.0.0-1.255.255.255\nA 2.0.0.0-2.255.255.255/,
      'order'   => '0',
    }) }
  end
end
