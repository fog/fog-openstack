module Fog
  module Network
    class OpenStack < Fog::Service
      class Mock
        def self.data
          @data ||= Hash.new do |hash, key|
            qos_policy_id = Fog::UUID.uuid
            network_id   = Fog::UUID.uuid
            extension_id = Fog::UUID.uuid
            subnet_id    = Fog::UUID.uuid
            tenant_id    = Fog::Mock.random_hex(8)

            hash[key] = {
              :extensions             => {
                extension_id => {
                  'id'          => extension_id,
                  'alias'       => 'dvr',
                  'description' => 'Enables configuration of Distributed Virtual Routers.',
                  'links'       => [],
                  'name'        => 'Distributed Virtual Router'
                }
              },
              :networks               => {
                network_id                => {
                  'id'                    => network_id,
                  'name'                  => 'Public',
                  'subnets'               => [subnet_id],
                  'shared'                => true,
                  'status'                => 'ACTIVE',
                  'tenant_id'             => tenant_id,
                  'provider:network:type' => 'vlan',
                  'router:external'       => false,
                  'admin_state_up'        => true,
                  'qos_policy_id'         => qos_policy_id,
                  'port_security_enabled' => true
                },
                'e624a36d-762b-481f-9b50-4154ceb78bbb' => {
                  'id'                    => 'e624a36d-762b-481f-9b50-4154ceb78bbb',
                  'name'                  => 'network_1',
                  'subnets'               => ['2e4ec6a4-0150-47f5-8523-e899ac03026e'],
                  'shared'                => false,
                  'status'                => 'ACTIVE',
                  'tenant_id'             => 'f8b26a6032bc47718a7702233ac708b9',
                  'provider:network:type' => 'vlan',
                  'router:external'       => false,
                  'admin_state_up'        => true,
                  'qos_policy_id'         => qos_policy_id,
                  'port_security_enabled' => true
                }
              },
              :ports                  => {},
              :subnets                => {
                subnet_id => {
                  'id'               => subnet_id,
                  'name'             => "Public",
                  'network_id'       => network_id,
                  'cidr'             => "192.168.0.0/22",
                  'ip_version'       => 4,
                  'gateway_ip'       => Fog::Mock.random_ip,
                  'allocation_pools' => [],
                  'dns_nameservers'  => [Fog::Mock.random_ip, Fog::Mock.random_ip],
                  'host_routes'      => [Fog::Mock.random_ip],
                  'enable_dhcp'      => true,
                  'tenant_id'        => tenant_id,
                }
              },
              :subnet_pools           => {},
              :floating_ips           => {},
              :routers                => {},
              :lb_pools               => {},
              :lb_members             => {},
              :lb_health_monitors     => {},
              :lb_vips                => {},
              :lbaas_loadbalancers    => {},
              :lbaas_listeners        => {},
              :lbaas_pools            => {},
              :lbaas_pool_members     => {},
              :lbaas_health_monitorss => {},
              :lbaas_l7policies       => {},
              :lbaas_l7rules          => {},
              :vpn_services           => {},
              :ike_policies           => {},
              :ipsec_policies         => {},
              :ipsec_site_connections => {},
              :rbac_policies          => {},
              :quota                  => {
                "subnet"     => 10,
                "router"     => 10,
                "port"       => 50,
                "network"    => 10,
                "floatingip" => 50
              },
              :quotas                 => [
                {
                  "subnet"     => 10,
                  "network"    => 10,
                  "floatingip" => 50,
                  "tenant_id"  => tenant_id,
                  "router"     => 10,
                  "port"       => 30
                }
              ],
              :security_groups            => {},
              :security_group_rules       => {},
              :network_ip_availabilities  => [
                {
                  "network_id"              => "4cf895c9-c3d1-489e-b02e-59b5c8976809",
                  "network_name"            => "public",
                  "subnet_ip_availability"  => [
                    {
                      "cidr"          => "2001:db8::/64",
                      "ip_version"    => 6,
                      "subnet_id"     => "ca3f46c4-c6ff-4272-9be4-0466f84c6077",
                      "subnet_name"   => "ipv6-public-subnet",
                      "total_ips"     => 18446744073709552000,
                      "used_ips"      => 1
                    },
                    {
                      "cidr"          => "172.24.4.0/24",
                      "ip_version"    => 4,
                      "subnet_id"     => "cc02efc1-9d47-46bd-bab6-760919c836b5",
                      "subnet_name"   => "public-subnet",
                      "total_ips"     => 253,
                      "used_ips"      => 1
                    }
                  ],
                  "project_id"  => "1a02cc95f1734fcc9d3c753818f03002",
                  "tenant_id"   => "1a02cc95f1734fcc9d3c753818f03002",
                  "total_ips"   => 253,
                  "used_ips"    => 2
                },
                {
                  "network_id"              => "6801d9c8-20e6-4b27-945d-62499f00002e",
                  "network_name"            => "private",
                  "subnet_ip_availability"  => [
                    {
                      "cidr"        => "10.0.0.0/24",
                      "ip_version"  => 4,
                      "subnet_id"   => "44e70d00-80a2-4fb1-ab59-6190595ceb61",
                      "subnet_name" => "private-subnet",
                      "total_ips"   => 253,
                      "used_ips"    => 2
                    },
                    {
                      "ip_version"  => 6,
                      "cidr"        => "fdbf:ac66:9be8::/64",
                      "subnet_id"   => "a90623df-00e1-4902-a675-40674385d74c",
                      "subnet_name" => "ipv6-private-subnet",
                      "total_ips"   => 18446744073709552000,
                      "used_ips"    => 2
                    }
                  ],
                  "project_id"  => "d56d3b8dd6894a508cf41b96b522328c",
                  "tenant_id"   => "d56d3b8dd6894a508cf41b96b522328c",
                  "total_ips"   => 18446744073709552000,
                  "used_ips"    => 4
                }
              ]
            }
          end
        end

        def self.reset
          @data = nil
        end

        include Fog::OpenStack::Core

        def initialize(options = {})
          @auth_token = Fog::Mock.random_base64(64)
          @auth_token_expiration = (Time.now.utc + 86400).iso8601

          initialize_identity options
        end

        def data
          self.class.data["#{@openstack_username}-#{@openstack_tenant}"]
        end

        def reset_data
          self.class.data.delete("#{@openstack_username}-#{@openstack_tenant}")
        end
      end
    end
  end
end
