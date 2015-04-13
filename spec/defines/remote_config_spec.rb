require 'spec_helper'

describe 'ezproxy::remote_config', :type => :define do
  let(:facts) {{ :concat_basedir => '/var/lib/puppet/concat' }}
  let(:title) { 'sample' }

  context 'passing the required params' do
    let(:params) {{
      'download_link' => 'http://www.test.url/path/to/config',
      'file_name'     => 'sample_config',
    }}

    it { is_expected.to contain_exec('download sample config').with({
      'command' => 'curl -o /sample_config http://www.test.url/path/to/config',
      'creates' => '/sample_config',
    }) }
    it { is_expected.to contain_exec('sanitize sample config').with({
      'command' => 'dos2unix /sample_config',
    }) }
    it { is_expected.to contain_concat__fragment('sample').with({
      'ensure' => 'present',
      'target' => 'ezproxy sites',
      'source' => '/sample_config',
      'order'  => '1',
    }) }
  end

  context 'passing all params' do
    let(:params) {{
      'download_link' => 'http://www.test.url/path/to/config',
      'file_name'     => 'sample_config',
      'order'         => '2',
    }}

    it { is_expected.to contain_exec('download sample config').with({
      'command' => 'curl -o /sample_config http://www.test.url/path/to/config',
      'creates' => '/sample_config',
    }) }
    it { is_expected.to contain_concat__fragment('sample').with({
      'ensure' => 'present',
      'target' => 'ezproxy sites',
      'source' => '/sample_config',
      'order'  => '2',
    }) }
  end
end
