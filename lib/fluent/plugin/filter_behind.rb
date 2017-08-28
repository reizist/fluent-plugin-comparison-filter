require 'fluent/plugin/filter'

module Fluent
  module Plugin
    class BehindFilter < Filter
      class ConfigError < StandardError ; end
      Fluent::Plugin.register_filter('behind', self)

      helpers :extract, :storage
      config_param :time_key, :string, default: nil
      DEFAULT_STORAGE_TYPE = 'local'

      def initialize
        super
      end

      def configure(conf)
        super
        @storage = storage_create(usage: 'behind', conf: nil, type: DEFAULT_STORAGE_TYPE)
      end

      def filter(tag, time, record)
        result = nil
        last_recorded = fetch_timestamp
        begin
          record_time = extract_time_from_record(record).to_i # treats time as unixtime
          if last_recorded.nil? || last_recorded < record_time
            set_timestamp(record_time)
            result = record
          end
        rescue => e
          log.warn "failed to filter records", error: e
          log.warn_backtrace
        end
        result
      end

      private

      def fetch_timestamp
        @storage.get(:last_recorded)
      end

      def set_timestamp(time)
        @storage.put(:last_recorded, time)
      end
    end
  end
end
