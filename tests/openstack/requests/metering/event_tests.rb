Shindo.tests('Fog::Metering[:openstack] | event requests', ['openstack']) do

  @event_format = {
    'message_id' => String,
    'event_type' => String,
  }

  tests('success') do
    tests('#list_events').formats([@event_format]) do
      Fog::Metering[:openstack].list_events.body
    end

    tests('#get_event').formats(@event_format) do
      Fog::Metering[:openstack].get_event('test').body
    end
  end
end
