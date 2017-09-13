require 'test_helper'
require 'fluent/test/driver/filter'

class BelatedRecordFilterTest < Test::Unit::TestCase
  include Fluent

  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = nil)
    Test::FilterTestDriver.new(Plugin::BelatedRecordFilter).configure(conf)
  end

  def filter(conf, msgs)
    driver = create_driver(conf)
    driver.run do
      msgs.each do |msg|
        driver.filter(msg, "time" => Time.now)
      end
    end
    filtered = driver.filtered_as_array
    filtered
  end

  sub_test_case 'filter' do
    test 'execute filter by datetime string' do
      CONFIG = <<CONF
        type belated_record
        <extract>
          time_key time
        time_type string
        time_format %Y-%m-%d %H:%M:%S %z
        keep_time_key true

        </extract>
CONF
      base_time   = Time.now
      future_time = base_time + 1
      past_time   = base_time - 1

      d = create_driver(CONFIG)

      d.run do
        d.emit("time" => base_time.to_s, "message" => "initial message")
        d.emit("time" => future_time.to_s, "message" => "future message")
        d.emit("time" => past_time.to_s, "message" => "past message")
      end

      assert_equal(
        [{"time" => base_time.to_s, "message" => "initial message"}, {"time" => future_time.to_s, "message" => "future message"}].sort_by{|h| h["time"]},
        d.filtered.instance_variable_get(:@record_array).sort_by{|h| h["time"]}
      )
    end

    test 'execute filter by unixtime' do
      conf_file   = IO.read("#{File.expand_path('../../../example.conf', __FILE__)}")
      base_time   = Time.now.to_i
      future_time = base_time + 1
      past_time   = base_time - 1

      d = create_driver(conf_file)

      d.run do
        d.emit("time" => base_time, "message" => "initial message")
        d.emit("time" => future_time, "message" => "future message")
        d.emit("time" => past_time, "message" => "past message")
      end

      assert_equal(
        [{"time" => base_time, "message" => "initial message"}, {"time" => future_time, "message" => "future message"}].sort_by{|h| h["time"]},
        d.filtered.instance_variable_get(:@record_array).sort_by{|h| h["time"]}
      )
    end

    test 'execute filter by numeric' do
      CONFIG = <<CONF
        type belated_record
        comparison_key id
        comparison_key_type numeric
CONF

      d = create_driver(CONFIG)

      d.run do
        d.emit("id" => 1, "message" => "initial message")
        d.emit("id" => 5, "message" => "future message")
        d.emit("id" => 3, "message" => "past message")
      end

      assert_equal(
        [{"id" => 1, "message" => "initial message"}, {"id" => 5, "message" => "future message"}].sort_by{|h| h["id"]},
        d.filtered.instance_variable_get(:@record_array).sort_by{|h| h["id"]}
      )
    end
  end
end