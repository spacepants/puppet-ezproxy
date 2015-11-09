require 'spec_helper'

describe 'ezproxy::stanza', :type => :define do
  let(:facts) {{ :concat_basedir => '/var/lib/puppet/concat' }}
  let(:title) { 'sample' }

  context 'passing the required params' do
    let(:params) {{
      'urls' => ['http://www.test.url'],
    }}

    it { is_expected.to contain_concat__fragment('sample').with({
      'target'  => 'ezproxy group Default',
      'content' => /T sample\nU http:\/\/www\.test\.url/,
      'order'   => '2',
    }) }
  end

  context 'passing all params' do
    let(:params) {{
      'urls'      => ['http://www.test1.url', 'http://www.test2.url'],
      'prepends'  => ['Option DoAThing', 'Option DoAnotherThing'],
      'hosts'     => ['www.test1.url', 'www.test2.url'],
      'domains'   => ['test1.url','test2.url'],
      'domain_js' => ['test3.url', 'test4.url'],
      'host_js'   => ['js.test3.url', 'js.test4.url'],
      'appends'   => ['Option StopDoingAThing', 'Option StopDoingAnotherThing'],
      'order'     => '3',
    }}

    it { is_expected.to contain_concat__fragment('sample').with({
      'target'  => 'ezproxy group Default',
      'content' => /Option DoAThing\nOption DoAnotherThing\nT sample\nU http:\/\/www\.test1\.url\nU http:\/\/www\.test2\.url\nH www.test1.url\nH www.test2.url\nD test1.url\nD test2.url\nDJ test3.url\nDJ test4.url\nHJ js.test3.url\nHJ js.test4.url\nOption StopDoingAThing\nOption StopDoingAnotherThing/,
      'order'   => '3',
    }) }
  end
end
