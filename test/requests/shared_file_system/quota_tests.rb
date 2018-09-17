require "test_helper"

describe "Fog::OpenStack::SharedFileSystem | quota requests" do
  before do
    @manila = Fog::OpenStack::SharedFileSystem.new

    @project_id = @manila.respond_to?(:current_tenant) ? @manila.current_tenant['id'] : Fog::Mock.random_numbers(6).to_s

    @quota_format = {
      "gigabytes"          => Integer,
      "shares"             => Integer,
      "snapshots"          => Integer,
      "snapshot_gigabytes" => Integer,
      "share_networks"     => Integer,
      "id"                 => String
    }
    @quota = @manila.get_quota(@project_id).body['quota_set']
  end

  describe "success" do
    it "#get_quota" do
      @quota.must_match_schema(@quota_format)
    end

    it "#update_quota" do
      new_values = @quota.merge(
        'shares'    => @quota['shares'] + 1,
        'snapshots' => @quota['snapshots'] + 2
      )

      @manila.update_quota(@project_id, new_values.clone).status.must_equal 200
      @manila.get_quota(@project_id).body['quota_set'].must_equal new_values
      # turn back
      @manila.update_quota(@project_id, @quota)
    end
  end
end
