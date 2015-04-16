require 'spec_helper_acceptance'

describe 'ezproxy class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'ezproxy':
        service_status => stopped,
        service_enable => false,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe group('ezproxy') do
      it { is_expected.to exist }
    end
    describe user('ezproxy') do
      it { is_expected.to exist }
    end

    describe file('/usr/local/ezproxy/ezproxy') do
      it { is_expected.to be_executable }
    end
    describe file('/usr/local/ezproxy/config.txt') do
      it { is_expected.to be_file }
    end
    describe file('/usr/local/ezproxy/user.txt') do
      it { is_expected.to be_file }
    end
    describe file('/usr/local/ezproxy/sites.txt') do
      it { is_expected.to be_file }
    end

    # ezproxy requires a license on startup which we can't test ephemerally
    describe service('ezproxy') do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end
  end
end
