require 'spec_helper_acceptance'

if ENV['VENDOR_TYPE'] == 'codership'

  # Debian 10 is currently not supported by Codership.
  describe 'galera', if: ((os[:family] == 'debian' && os[:release].to_i < 10) || (os[:family] != 'debian')) do
    describe 'with vendor codership enabled' do
      let(:pp) do
        <<-MANIFEST
        # Codership's MySQL service fails to start if apparmor is not installed.
        if ($facts['os']['name'] == 'Ubuntu') {
          ensure_packages('apparmor-utils')
        }

        class { 'galera':
          cluster_name          => 'testcluster',
          deb_sysmaint_password => 'sysmaint',
          configure_firewall    => false,
          galera_servers        => ['127.0.0.1'],
          galera_master         => $::fqdn,
          root_password         => 'root_password',
          status_password       => 'status_password',
          override_options      => {
            'mysqld' => {
              'bind_address' => '0.0.0.0',
            }
          },
          vendor_type           => 'codership',
          vendor_version        => '5.7'
        }
        MANIFEST
      end

      it 'runs successfully' do
        apply_manifest(pp, catch_failures: true)
      end

      describe port(3306) do
        it { is_expected.to be_listening.with('tcp') }
      end

      describe port(4567) do
        it { is_expected.to be_listening.with('tcp') }
      end
    end
  end

end
