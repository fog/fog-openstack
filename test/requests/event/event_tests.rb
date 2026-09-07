require "test_helper"

describe "Fog::OpenStack::Event | event requests" do
  before do
    @metering = Fog::OpenStack::Event.new
    @event_format = {
      'message_id' => String,
      'event_type' => String
    }
  end

  describe "success" do
    it "#list_events" do
      _(@metering.list_events.body).
        must_match_schema([@event_format])
    end

    it "#get_event" do
      _(@metering.get_event('test').body).
        must_match_schema(@event_format)
    end
  end
end
