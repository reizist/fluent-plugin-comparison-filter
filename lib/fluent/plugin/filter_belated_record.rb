require 'fluent/plugin/filter'

module Fluent
  module Plugin
    class BelatedRecordFilter < Filter
      class ConfigError < StandardError ; end
      Fluent::Plugin.register_filter('belated_record', self)

      helpers :extract, :storage
      config_param :comparison_key, :string, default: nil
      config_param :comparison_key_type, :enum, list: [:numeric, :time], default: :time

      DEFAULT_STORAGE_TYPE = 'local'

      def initialize
        super
      end

      def compare_by_time?
        @config_root_section[:comparison_key_type] == :time
      end

      def configure(conf)
        super
        if conf[:comparison_key_type] == :numeric && !conf[:comparison_key].has_key?
          raise ConfigError, "when comparison_key_type is numeric, comparison_key is necessary"
        end
        @storage = storage_create(usage: 'belated_record', conf: nil, type: DEFAULT_STORAGE_TYPE)
      end

      def filter(tag, time, record)
        result = nil
        last_recorded = fetch_comparison_key
        begin
          comparison_key = if compare_by_time?
            extract_time_from_record(record).to_i # treats time as unixtime
          else
            record[@config_root_section[:comparison_key]]
          end
          if last_recorded.nil? || last_recorded < comparison_key
            set_comparison_key(comparison_key)
            result = record
          end
        rescue => e
          log.warn "failed to filter records", error: e
          log.warn_backtrace
        end
        result
      end

      private

      def fetch_comparison_key
        @storage.get(:last_recorded)
      end

      def set_comparison_key(key)
        @storage.put(:last_recorded, key)
      end
    end
  end
end
