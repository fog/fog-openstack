require "test_helper"

describe "Fog::OpenStack::Baremetal | Baremetal chassis requests" do
  describe "success" do
    before do
      @baremetal = Fog::OpenStack::Baremetal.new

      @chassis_format = {
        'description' => String,
        'uuid'        => String,
        'links'       => Array
      }

      @detailed_chassis_format = {
        'description' => String,
        'uuid'        => String,
        'created_at'  => String,
        'updated_at'  => Fog::Nullable::String,
        'extra'       => Hash,
        'nodes'       => Array,
        'links'       => Array
      }

      chassis_attributes = {:description => 'description'}
      @instance = @baremetal.create_chassis(chassis_attributes).body
    end

    it "#list_chassis" do
      @baremetal.list_chassis.body.must_match_schema('chassis' => [@chassis_format])
    end

    it "#list_chassis_detailed" do
      @baremetal.list_chassis_detailed.body.must_match_schema('chassis' => [@detailed_chassis_format])
    end

    it "#create_chassis" do
      @instance.must_match_schema(@detailed_chassis_format)
    end

    it "#get_chassis" do
      @baremetal.get_chassis(@instance['uuid']).body.must_match_schema(@detailed_chassis_format)
    end

    it "#patch_chassis" do
      @baremetal.patch_chassis(
        @instance['uuid'],
        [{'op' => 'replace', 'path' => '/description', 'value' => 'new description'}]
      ).body.must_match_schema(@detailed_chassis_format)
    end

    it "#delete_chassis" do
      @baremetal.delete_chassis(@instance['uuid']).status.must_equal 200
    end
  end
end
