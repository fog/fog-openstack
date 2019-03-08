require "test_helper"

describe "Fog::OpenStack::DNS::V2 | quota requests" do
  before do
    @dns = Fog::OpenStack::DNS::V2.new

    @project_id = @dns.respond_to?(:current_tenant) ? @dns.current_tenant['id'] : Fog::Mock.random_numbers(6).to_s

    @quota_format = {
      "api_export_size"   => Integer,
      "recordset_records" => Integer,
      "zone_records"      => Integer,
      "zone_recordsets"   => Integer,
      "zones"             => Integer
    }
    @quota = @dns.get_quota(@project_id).body
  end

  describe "success" do
    it "#get_quota" do
      @quota.must_match_schema(@quota_format)
    end

    it "#update_quota" do
      new_values = @quota.merge(
        'recordset_records' => @quota['recordset_records'] + 1,
        'zones'             => @quota['zones'] + 2
      )

      @dns.update_quota(@project_id, new_values.clone).status.must_equal 200
      @dns.get_quota(@project_id).body.must_equal new_values
      # turn back
      @dns.update_quota(@project_id, @quota)
    end
  end
end
