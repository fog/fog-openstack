require 'spec_helper'
require_relative './shared_context'
require 'fog/openstack/monitoring/models/metric'
require 'time'

describe Fog::OpenStack::Monitoring do
  spec_data_folder = 'spec/fixtures/openstack/monitoring'

  before :all do
    openstack_vcr = OpenStackVCR.new(
      :vcr_directory => spec_data_folder,
      :service_class => Fog::OpenStack::Monitoring
    )
    @service      = openstack_vcr.service
    @timestamp    = 146_375_736_714_3
  end

  it 'metric crud tests' do
    VCR.use_cassette('metric_crud') do
      # create single metric
      metric_0 = @service.metrics.create(:name       => 'sample_metric_0',
                                         :timestamp  => @timestamp,
                                         :dimensions => {"key1" => "value1"},
                                         :value      => 42,
                                         :value_meta => {"meta_key1" => "meta_value1"})

      metric_0.wont_be_nil

      # create multiple metrics

      metric_1 = Fog::OpenStack::Monitoring::Metric.new(:name       => 'sample_metric_1',
                                                        :timestamp  => @timestamp,
                                                        :dimensions => {"key1" => "value1"},
                                                        :value      => 42,
                                                        :value_meta => {"meta_key1" => "meta_value1"})

      metric_2 = Fog::OpenStack::Monitoring::Metric.new(:name       => 'sample_metric_2',
                                                        :timestamp  => @timestamp,
                                                        :dimensions => {"key1" => "value1"},
                                                        :value      => 42,
                                                        :value_meta => {"meta_key1" => "meta_value1"})

      @service.metrics.create_metric_array([metric_1, metric_2])

      metric_0_identity = {:name       => 'sample_metric_0',
                           :dimensions => {"key1" => "value1"}}

      metric_1_identity = {:name       => 'sample_metric_1',
                           :dimensions => {"key1" => "value1"}}

      metric_2_identity = {:name       => 'sample_metric_2',
                           :dimensions => {"key1" => "value1"}}

      # list metrics filtered by name and search for previuosly created metrics by unique identifier of name,dimensions
      [metric_0_identity, metric_1_identity, metric_2_identity].each do |metric_identity|
        metrics_all = @service.metrics.all(:name => metric_identity[:name])
        metrics_all.wont_be_nil
        metrics_all.wont_be_empty
        metrics_all_identities = metrics_all.collect do |_metric|
          {:name       => metric_identity[:name],
           :dimensions => metric_identity[:dimensions]}
        end

        metrics_all_identities.must_include(metric_identity)
      end

      # list all metric names
      metrics_name_list = @service.metrics.list_metric_names

      metrics_name_list.wont_be_nil
      metrics_name_list.wont_be_empty

      # failure cases
      proc do
        @service.metrics.create(:name => "this won't be created due to insufficient args")
      end.must_raise ArgumentError

      proc do
        @service.metrics.create(:name => "this wont't be created due to invalid timestamp", :timestamp => 1234)
      end.must_raise ArgumentError
    end
  end

  it 'list measurements by name and start_time' do
    VCR.use_cassette('metric_measurement_list') do
      measurement_list = @service.measurements.find(:name          => 'cpu.user_perc',
                                                    :start_time    => '2016-04-01T14:43:00Z',
                                                    :merge_metrics => true)

      measurement_list.wont_be_nil
      measurement_list.wont_be_empty

      # should return an empty list
      measurement_list_empty = @service.measurements.find(:name       => 'non.existing.metric_name',
                                                          :start_time => '2016-04-01T14:43:00Z')

      measurement_list_empty.must_be_empty
    end
  end

  it 'find statistics specified by name, start_time and statistics' do
    VCR.use_cassette('statistics_list') do
      statistics_list = @service.statistics.all(:name          => 'cpu.system_perc',
                                                :start_time    => '2016-04-01T14:43:00Z',
                                                :statistics    => 'avg,min,max,sum,count',
                                                :merge_metrics => true)

      statistics_list.wont_be_nil
      statistics_list.wont_be_empty
    end
  end

  it 'notification methods crud test' do
    VCR.use_cassette('notification-methods_crud') do
      begin
        # create notification method
        notification_method      = @service.notification_methods.create(:name    => 'important notification',
                                                                        :type    => 'EMAIL',
                                                                        :address => 'admin@example.com',
                                                                        :period  => 0)

        # list all notification methods
        notification_methods_all = @service.notification_methods.all

        notification_methods_all.wont_be_nil
        notification_methods_all.wont_be_empty

        # find a notification method by id
        notification_method_by_id = @service.notification_methods.find_by_id(notification_method.id)

        notification_method.must_equal notification_method_by_id

        # update specific an existing notification
        notification_method.update(:name    => notification_method.name,
                                   :address => 'notification_methods@example.com',
                                   :type    => notification_method.type,
                                   :period  => 0)

        notification_method.address.must_equal 'notification_methods@example.com'
        notification_method.period.must_equal 0

        # Delete the notification method and make sure it is no longer found in the list
        notification_method.destroy
        (@service.notification_methods.all.include? notification_method).must_equal false
        notification_method = nil

        # failure cases
        proc do
          @service.notification_methods.create(:name => "this won't be created due to insufficient args")
        end.must_raise ArgumentError

        proc do
          @service.notification_methods.find_by_id('bogus_id')
        end.must_raise Fog::OpenStack::Monitoring::NotFound
      ensure
        notification_method.destroy if notification_method
      end
    end
  end

  it 'alarm definitions crud test' do
    VCR.use_cassette('alarm_definition_crud') do
      begin
        # create an alarm defintion
        alarm_definition = @service.alarm_definitions.create(
          :name        => 'average cpu usage in perc',
          :match_by    => ['hostname'],
          :expression  => '(avg(cpu.user_perc{hostname=devstack}) > 10)',
          :description => 'Definition for an important alarm'
        )

        # list all alarm definitions
        alarm_definitions_all = @service.alarm_definitions.all

        alarm_definitions_all.wont_be_nil
        alarm_definitions_all.wont_be_empty

        # find an alarm-definition by id
        alarm_definition_by_id = @service.alarm_definitions.find_by_id(alarm_definition.id)

        alarm_definition.id.must_equal alarm_definition_by_id.id
        alarm_definition.name.must_equal alarm_definition_by_id.name
        alarm_definition.expression.must_equal alarm_definition_by_id.expression
        alarm_definition.deterministic.must_equal false

        # create a notification method for the following test
        notification_method       = @service.notification_methods.create(:name    => 'important notification',
                                                                         :type    => 'EMAIL',
                                                                         :address => 'admin@example.com')

        # replace an alarm_definition
        alarm_definition_replaced = alarm_definition.update(
          :name                 => 'CPU percent greater than 15',
          :match_by             => ['hostname'],
          :description          => 'Replaced alarm-definition expression',
          :expression           => '(avg(cpu.user_perc{hostname=devstack}) > 15)',
          :severity             => 'LOW',
          :alarm_actions        => [notification_method.id],
          :ok_actions           => [notification_method.id],
          :undetermined_actions => [notification_method.id],
          :actions_enabled      => true
        )

        alarm_definition_replaced.id.must_equal alarm_definition.id
        alarm_definition_replaced.name.must_equal 'CPU percent greater than 15'
        alarm_definition_replaced.description.must_equal 'Replaced alarm-definition expression'
        alarm_definition_replaced.expression.must_equal '(avg(cpu.user_perc{hostname=devstack}) > 15)'
        #
        # patch specific attributes of alarm_definition
        alarm_definition_updated = alarm_definition.patch(:description => 'An updated alarm-definition.')

        alarm_definition.id.must_equal alarm_definition_updated.id
        alarm_definition_updated.description.must_equal 'An updated alarm-definition.'

        # delete alarm definition
        alarm_definition.destroy

        # ensure the alarm definition does not exist any more
        (@service.alarm_definitions.all.include? alarm_definition).must_equal false
        alarm_definition = nil

        # delete the notification method
        notification_method.destroy
        notification_method = nil

        # failure cases
        proc do
          @service.alarm_definitions.create(:name => "this won't be created due to insufficient args")
        end.must_raise ArgumentError
      ensure
        alarm_definition.destroy if alarm_definition
        notification_method.destroy if notification_method
      end
    end
  end

  it 'alarm crud test' do
    VCR.use_cassette('alarm_crud') do
      begin
        # create notification method
        notification_method = @service.notification_methods.create(:name    => 'another notification',
                                                                   :type    => 'EMAIL',
                                                                   :address => 'admin@example.com')

        # create an alarm definition which ensures an alarm is thrown
        alarm_definition = @service.alarm_definitions.create(:name        => 'avg cpu.user_per ge 0',
                                                             :expression  => '(avg(cpu.user_perc) >= 0)',
                                                             :description => 'ensure an alarm is thrown in crud test.')

        # list all alarms
        alarms_all = @service.alarms.all

        alarms_all.wont_be_nil
        alarms_all.wont_be_empty

        # list all alarms in ALARM state
        alarms_all_state_filter = @service.alarms.all(:state => 'OK')

        alarms_all_state_filter.wont_be_nil
        alarms_all_state_filter.wont_be_empty

        # get an alarm by name using list all alarms with filter
        alarm_list_by_name_filter = @service.alarms.all(:metric_name => 'cpu.idle_perc')
        alarm_by_name             = alarm_list_by_name_filter.first

        alarm_by_name.wont_be_nil

        # get the id of this alarm
        alarm_id    = alarm_by_name.id

        # find alarm by id
        alarm_by_id = @service.alarms.find_by_id(alarm_id)

        alarm_by_name.id.must_equal alarm_by_id.id
        alarm_by_name.state.must_equal alarm_by_id.state
        alarm_by_name.lifecycle_state.must_equal alarm_by_id.lifecycle_state

        # replace the entire state of the specified alarm
        alarm_by_id.update(:state           => 'ALARM',
                           :lifecycle_state => 'OPEN',
                           :link            => 'http://pagerduty.com/')

        alarm_by_id.state.must_equal 'ALARM'
        alarm_by_id.lifecycle_state.must_equal 'OPEN'
        alarm_by_id.link.must_equal 'http://pagerduty.com/'

        # check the link of an alarm before patching
        alarm_by_id.link.wont_equal 'http://somesite.com/this-alarm-info'

        # patch specific attributes of an existing alarm
        alarm_by_id.patch(:link => 'http://somesite.com/this-alarm-info')

        # check the link afterwards
        alarm_by_id.link.must_equal 'http://somesite.com/this-alarm-info'

        # list alarm state history for all alarms but limit history to 5
        alarm_state_history_all = @service.alarm_states.all(:limit => 5)

        alarm_state_history_all.wont_be_nil
        alarm_state_history_all.length.must_equal 5

        # list alarm state history
        alarm_state_history_for_alarm = @service.alarm_states.list_alarm_state_history(alarm_id)

        alarm_state_history_for_alarm.wont_be_nil
        alarm_state_history_for_alarm.wont_be_empty

        # delete an existing alarm
        alarm_by_id.destroy

        (@service.alarms.all.include? alarm_by_id).must_equal false

        alarm_definition    = nil
        notification_method = nil
      ensure
        # cleanup
        alarm_definition.destroy if alarm_definition
        notification_method.destroy if notification_method
      end
    end
  end

  it 'list alarm state history for all alarms' do
    VCR.use_cassette('alarm_state_history_all') do
      # get the alarm state history for all alarms
      alarm_state_history_all = @service.alarm_states.all

      alarm_state_history_all.wont_be_nil
      alarm_state_history_all.wont_be_empty

      # get an alarm by name using list all alarms with filter
      alarm_by_name = @service.alarms.all(:name => 'cpu.user_perc')

      # get the id of this alarm
      alarm_id      = alarm_by_name.first.id

      # find alarm by id
      @service.alarms.find_by_id(alarm_id)

      # get alarm state history for specific alarm
      alarm_state_history_for_alarm = @service.alarm_states.list_alarm_state_history(alarm_id)

      alarm_state_history_for_alarm.wont_be_nil
      alarm_state_history_for_alarm.wont_be_empty
    end
  end

  it 'list dimension values' do
    VCR.use_cassette('list_dimension_values') do
      # list dimension values
      dimension_values_by_key = @service.metrics.list_dimension_values('hostname').first

      dimension_values_by_key.wont_be_nil
      dimension_values_by_key.dimension_name.must_equal 'hostname'
      dimension_values_by_key.id.wont_be_nil
      dimension_values_by_key.values.wont_be_empty
    end
  end

  it 'list notification method types' do
    VCR.use_cassette('list_notification_method_types') do
      notification_method_types = @service.notification_methods.list_types

      notification_method_types.wont_be_nil
      notification_method_types.wont_be_empty

      notification_method_types.must_include :EMAIL
      notification_method_types.must_include :PAGERDUTY
      notification_method_types.must_include :WEBHOOK
    end
  end

  # FIXME: According to the API (https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md)
  # the response body should not contain a 'id'-element, but actually it does contain "id": "null".
  # it 'alarm count test' do
  #   VCR.use_cassette('alarm_crud') do
  #     # get alarm counts
  #     alarm_count = @service.alarm_counts.get(:metric_name => 'cpu.system_perc',
  #                                             :group_by    => 'state')
  #
  #     alarm_count.columns.wont_be_nil
  #     alarm_count.columns.wont_be_empty
  #     alarm_count.counts.wont_be_nil
  #     alarm_count.counts.wont_be_empty
  #   end
  # end
end
