require "test_helper"

describe "Fog::OpenStack::DNS::V1 | quota requests" do
  before do
    @dns = Fog::OpenStack::DNS::V1.new

    @project_id = Fog::Mock.random_numbers(6).to_s

    @quota_format = {
      "api_export_size"   => Integer,
      "recordset_records" => Integer,
      "domain_records"    => Integer,
      "domain_recordsets" => Integer,
      "domains"           => Integer
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
        'domains'           => @quota['domains'] + 2
      )

      @dns.update_quota(@project_id, new_values.clone).status.must_equal 200
      @dns.get_quota(@project_id).body.must_equal new_values
    end
  end
end
