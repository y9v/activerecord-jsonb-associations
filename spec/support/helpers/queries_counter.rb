module Helpers
  module QueriesCounter
    # rubocop:disable Metrics/MethodLength
    def count_queries(&block)
      count = 0

      counter_f = lambda do |_name, _started, _finished, _unique_id, payload|
        next if %w[CACHE SCHEMA].include?(payload[:name])
        count += 1
      end

      ActiveSupport::Notifications.subscribed(
        counter_f,
        'sql.active_record',
        &block
      )

      count
    end
    # rubocop:enable Metrics/MethodLength
  end
end
