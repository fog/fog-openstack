require 'test_helper'

describe "Fog::OpenStack::Volume | backup requests" do
  before do
    @volume = Fog::OpenStack::Volume.new
    @backup_format = {
      'id'           => String,
      'volume_id'    => String,
      'status'       => String,
      'name'         => String,
      'size'         => Integer,
      'object_count' => Integer,
      'container'    => String
    }

    @backup = @volume.create_backup(:name => 'test_backup', :volume_id => '2').body['backup']
  end

  describe "success" do
    it "create_backup" do
      @backup.must_match_schema(@backup_format)
    end

    it "#get_backup_details" do
      @volume.get_backup_details(@backup['id']).body['backup'].
        must_match_schema(@backup_format)
    end

    it "#list_backups_detailed" do
      @volume.list_backups_detailed.body['backups'].
        must_match_schema([@backup_format])
    end

    it '#delete_backup' do
      @volume.delete_backup(@backup['id'])
    end
  end
end
