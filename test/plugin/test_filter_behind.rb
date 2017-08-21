require 'test/unit'
require 'fluent/test/driver/filter'
require 'fluent/plugin/filter_behind'
require 'pry-byebug'

class BehindFilterTest < Test::Unit::TestCase
  include Fluent

  setup do
    Fluent::Test.setup
  end

  def create_driver(conf = nil)
    Test::FilterTestDriver.new(Plugin::BehindFilter).configure(conf)
  end

  sub_test_case 'filter' do
    def filter(conf, msgs)
      driver = create_driver(conf)
      driver.run do
        msgs.each do |msg|
          driver.feed(msg, time: Time.now)
        end
      end
    end

    test 'execute filter' do
      conf_file   = IO.read("#{File.expand_path('../../../example.conf', __FILE__)}")
      base_time   = Time.now
      future_time = base_time + 1
      past_time   = base_time - 1

      input = { time: base_time, message: "initial message" }
      es    = filter(conf_file, [input])
      binding.pry
      assert_equal(base_time, es.first['time'])

      input = { time: future_time, message: "initial message" }
      es    = filter(conf_file, [input])
      assert_equal(future_time, es.first['time'])


      input = { time: past_time, message: "initial message" }
      es    = filter(conf_file, [input])
      assert_not_equal(past_time, es.first[1]['time'])
    end
  end
end