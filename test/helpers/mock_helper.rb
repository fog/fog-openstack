# Use so you can run in mock mode from the command line
#
# FOG_MOCK=true fog

if ENV["FOG_MOCK"] == "true"
  Fog.mock!
end

# if in mocked mode, fill in some fake credentials for us
if Fog.mock?
  Fog.credentials = {
    :openstack_api_key  => 'openstack_api_key',
    :openstack_username => 'openstack_username',
    :openstack_tenant   => 'openstack_tenant',
    :openstack_auth_url => 'http://openstack:35357/v2.0/tokens',
  }.merge(Fog.credentials)
end
