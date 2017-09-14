require 'fluent/plugin/filter'

module Fluent
  module Plugin
    class BelatedRecordFilter < Filter
      class ConfigError < StandardError ; end
      Fluent::Plugin.register_filter('belated_record', self)
      helpers :storage

      config_section :comparison, required: true, multi: false, param_name: :comparison_config do
        config_param :column_key, :string, default: nil
        config_param :column_key_type, :enum, list: [:numeric, :time], default: :time

        config_param :time_type, :enum, list: [:float, :unixtime, :string], default: :float

        Fluent::TimeMixin::TIME_PARAMETERS.each do |name, type, opts|
          config_param name, type, opts
        end
      end

      DEFAULT_STORAGE_TYPE = 'local'

      def initialize
        super
        @column_key = nil
        @column_key_type = nil
        @time_type = nil
      end

      def configure(conf)
        super
        @column_key = @comparison_config.column_key
        @column_key_type = @comparison_config.column_key_type
        @time_type = @comparison_config.time_type

        if compare_by_time?
          @time_parser = case @time_type
            when :float then Fluent::NumericTimeParser.new(:float)
            when :unixtime then Fluent::NumericTimeParser.new(:unixtime)
            else
              localtime = @comparison_config.localtime && !@comparison_config.utc
              Fluent::TimeParser.new(@comparison_config.time_format, localtime, @comparison_config.timezone)
          end
        else
        end

        @storage = storage_create(usage: 'belated_record', conf: nil, type: DEFAULT_STORAGE_TYPE)
      end

      def filter(tag, time, record)
        result = nil
        last_recorded = fetch_comparison_key
        begin
          comparison_key = extract_comparison_column_from_record(record)
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

      def compare_by_time?
        @comparison_config.column_key_type == :time
      end

      def extract_comparison_column_from_record(record)

        if compare_by_time?
          if @column_key && record.has_key?(@column_key)
            return @time_parser.call(record[@column_key]).to_i # treats time as unixtime
          end
          nil
        else
          record[@column_key]
        end
      end
    end
  end
end
