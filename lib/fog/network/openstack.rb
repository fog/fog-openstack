module Fog
  module Network
    class OpenStack < Fog::Service
      SUPPORTED_VERSIONS = /v2(\.0)*/

      requires :openstack_auth_url
      recognizes :openstack_auth_token, :openstack_management_url,
                 :persistent, :openstack_service_type, :openstack_service_name,
                 :openstack_tenant, :openstack_tenant_id,
                 :openstack_api_key, :openstack_username, :openstack_identity_endpoint,
                 :current_user, :current_tenant, :openstack_region,
                 :openstack_endpoint_type, :openstack_cache_ttl,
                 :openstack_project_name, :openstack_project_id,
                 :openstack_project_domain, :openstack_user_domain, :openstack_domain_name,
                 :openstack_project_domain_id, :openstack_user_domain_id, :openstack_domain_id,
                 :openstack_identity_prefix

      ## MODELS
      #
      model_path 'fog/network/openstack/models'
      model       :extension
      collection  :extensions
      model       :network
      collection  :networks
      model       :port
      collection  :ports
      model       :subnet
      collection  :subnets
      model       :subnet_pool
      collection  :subnet_pools
      model       :floating_ip
      collection  :floating_ips
      model       :router
      collection  :routers
      model       :lb_pool
      collection  :lb_pools
      model       :lb_member
      collection  :lb_members
      model       :lb_health_monitor
      collection  :lb_health_monitors
      model       :lb_vip
      collection  :lb_vips
      model       :vpn_service
      collection  :vpn_services
      model       :ike_policy
      collection  :ike_policies
      model       :ipsec_policy
      collection  :ipsec_policies
      model       :ipsec_site_connection
      collection  :ipsec_site_connections
      model       :rbac_policy
      collection  :rbac_policies
      model       :security_group
      collection  :security_groups
      model       :security_group_rule
      collection  :security_group_rules
      model       :network_ip_availability
      collection  :network_ip_availabilities

      ## REQUESTS
      #
      request_path 'fog/network/openstack/requests'

      # Neutron Extensions
      request :list_extensions
      request :get_extension

      # IP Availability
      request :get_network_ip_availability
      request :list_network_ip_availabilities

      # Network CRUD
      request :list_networks
      request :create_network
      request :delete_network
      request :get_network
      request :update_network

      # Port CRUD
      request :list_ports
      request :create_port
      request :delete_port
      request :get_port
      request :update_port

      # Subnet CRUD
      request :list_subnets
      request :create_subnet
      request :delete_subnet
      request :get_subnet
      request :update_subnet

      # Subnet Pools CRUD
      request :list_subnet_pools
      request :create_subnet_pool
      request :delete_subnet_pool
      request :get_subnet_pool
      request :update_subnet_pool

      # FloatingIp CRUD
      request :list_floating_ips
      request :create_floating_ip
      request :delete_floating_ip
      request :get_floating_ip
      request :associate_floating_ip
      request :disassociate_floating_ip

      # Router CRUD
      request :list_routers
      request :create_router
      request :delete_router
      request :get_router
      request :update_router
      request :add_router_interface
      request :remove_router_interface

      #
      # LBaaS V1
      #

      # LBaaS Pool CRUD
      request :list_lb_pools
      request :create_lb_pool
      request :delete_lb_pool
      request :get_lb_pool
      request :get_lb_pool_stats
      request :update_lb_pool

      # LBaaS Member CRUD
      request :list_lb_members
      request :create_lb_member
      request :delete_lb_member
      request :get_lb_member
      request :update_lb_member

      # LBaaS Health Monitor CRUD
      request :list_lb_health_monitors
      request :create_lb_health_monitor
      request :delete_lb_health_monitor
      request :get_lb_health_monitor
      request :update_lb_health_monitor
      request :associate_lb_health_monitor
      request :disassociate_lb_health_monitor

      # LBaaS VIP CRUD
      request :list_lb_vips
      request :create_lb_vip
      request :delete_lb_vip
      request :get_lb_vip
      request :update_lb_vip

      #
      # LBaaS V2
      #

      # LBaaS V2 Loadbanacer
      request :list_lbaas_loadbalancers
      request :create_lbaas_loadbalancer
      request :delete_lbaas_loadbalancer
      request :get_lbaas_loadbalancer
      request :update_lbaas_loadbalancer

      # LBaaS V2 Listener
      request :list_lbaas_listeners
      request :create_lbaas_listener
      request :delete_lbaas_listener
      request :get_lbaas_listener
      request :update_lbaas_listener

      # LBaaS V2 Pool
      request :list_lbaas_pools
      request :create_lbaas_pool
      request :delete_lbaas_pool
      request :get_lbaas_pool
      request :update_lbaas_pool

      # LBaaS V2 Pool_Member
      request :list_lbaas_pool_members
      request :create_lbaas_pool_member
      request :delete_lbaas_pool_member
      request :get_lbaas_pool_member
      request :update_lbaas_pool_member

      # LBaaS V2 Healthmonitor
      request :list_lbaas_healthmonitors
      request :create_lbaas_healthmonitor
      request :delete_lbaas_healthmonitor
      request :get_lbaas_healthmonitor
      request :update_lbaas_healthmonitor

      # LBaaS V2 L7Policy
      request :list_lbaas_l7policies
      request :create_lbaas_l7policy
      request :delete_lbaas_l7policy
      request :get_lbaas_l7policy
      request :update_lbaas_l7policy

      # LBaaS V2 L7Rule
      request :list_lbaas_l7rules
      request :create_lbaas_l7rule
      request :delete_lbaas_l7rule
      request :get_lbaas_l7rule
      request :update_lbaas_l7rule

      # VPNaaS VPN Service CRUD
      request :list_vpn_services
      request :create_vpn_service
      request :delete_vpn_service
      request :get_vpn_service
      request :update_vpn_service

      # VPNaaS VPN IKE Policy CRUD
      request :list_ike_policies
      request :create_ike_policy
      request :delete_ike_policy
      request :get_ike_policy
      request :update_ike_policy

      # VPNaaS VPN IPSec Policy CRUD
      request :list_ipsec_policies
      request :create_ipsec_policy
      request :delete_ipsec_policy
      request :get_ipsec_policy
      request :update_ipsec_policy

      # VPNaaS VPN IPSec Site Connection CRUD
      request :list_ipsec_site_connections
      request :create_ipsec_site_connection
      request :delete_ipsec_site_connection
      request :get_ipsec_site_connection
      request :update_ipsec_site_connection

      # RBAC Policy CRUD
      request :list_rbac_policies
      request :create_rbac_policy
      request :delete_rbac_policy
      request :get_rbac_policy
      request :update_rbac_policy

      # Security Group
      request :create_security_group
      request :delete_security_group
      request :get_security_group
      request :list_security_groups
      request :update_security_group

      # Security Group Rules
      request :create_security_group_rule
      request :delete_security_group_rule
      request :get_security_group_rule
      request :list_security_group_rules

      # Tenant
      request :set_tenant

      # Quota
      request :get_quotas
      request :get_quota
      request :update_quota
      request :delete_quota

      class Real
        include Fog::OpenStack::Core

        def self.not_found_class
          Fog::Network::OpenStack::NotFound
        end

        def initialize(options = {})
          initialize_identity options

          @openstack_service_type = options[:openstack_service_type] || ['network']
          @openstack_service_name = options[:openstack_service_name]

          @connection_options     = options[:connection_options] || {}

          authenticate
          set_api_path

          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        def set_api_path
          @path.sub!(%r{/$}, '')
          unless @path.match(SUPPORTED_VERSIONS)
            @path = Fog::OpenStack.get_supported_version_path(SUPPORTED_VERSIONS,
                                                              @openstack_management_uri,
                                                              @auth_token,
                                                              @connection_options)
          end
        end
      end
    end
  end
end
