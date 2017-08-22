require 'test_helper'
require 'fluent/test/driver/filter'
require 'pry-byebug'

class BehindFilterTest < Test::Unit::TestCase
  include Fluent

  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = nil)
    Test::FilterTestDriver.new(Plugin::BehindFilter).configure(conf)
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
    test 'execute filter' do
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
  end
end