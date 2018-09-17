def set_dns_data
  @dns = Fog::OpenStack::DNS::V2.new

  @zone = @dns.create_zone('example.org', 'hostmaster@example.org')
  @zone_id = @zone.body['id']

  [@dns, @zone, @zone_id]
end
