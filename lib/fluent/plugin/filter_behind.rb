require 'fluent/filter'

module Fluent
  module Plugin
    class BehindFilter < Filter
      class ConfigError < StandardError ; end
      Plugin.register_filter('behind', self)

      def initialize
        super
        @last_recorded = nil
      end

      config_section :time_key, param_name: :time_key do
        desc 'The column key to decide filter or not.'
        config_param :time_key, :string, default: nil
      end

      def filter(tag, time, record)
        result = nil
        last_recorded = @last_recorded
        time_key = conf[:time_key]
        begin
          if Time.parse(last_recorded).to_i <= Time.parse(record[time_key]).to_i
            last_recorded = record[time_key]
            reset_timer(last_recorded)
            result = record
          end
          reset_timer(last_recorded)
        rescue => e
          log.warn "failed to filter records", error: e
          log.warn_backtrace
        end
        result
      end

      private

      def reset_timer(time)
        @last_recorded = time
      end
    end
  end
end
