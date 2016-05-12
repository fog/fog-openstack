class OpenStack
  module Identity
    def self.get_tenant_id_old
      identity = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
      ENV['OPENSTACK_TENANT_NAME'] || identity.list_tenants.body['tenants'].first['id']
    end

    def self.get_user_id_old
      identity = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
      ENV['OPENSTACK_USER_ID'] || identity.list_users.body['users'].first['id']
    end

    def self.get_tenant_id
      'tenant_id'
    end

    def self.get_user_id
      'user_id'
    end
  end
end
