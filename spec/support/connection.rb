# frozen_string_literal: true

# HACK: PostgreSQL has exactly one test failing randomly because of a
# `PG::ConnectionBad` exception. We've tried several alternatives but none of
# them worked. So, instead, this piece of code will try the connection up again
# whenever this exception is catched on the `reconnect!` method. This will only
# be done once (i.e. one retry), since we don't want to loop forever or catch
# valid hiccups.
#
# This piece of code is heavily inspired in Gitlab's
# `config/initializers/connection_fix.rb`.

if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
  module ActiveRecord::ConnectionAdapters
    # Re-opening PostgreSQLAdapter to add the new reconnect! method.
    class PostgreSQLAdapter
      alias reconnect_without_retry! reconnect!

      attr_accessor :portus_retries

      def reconnect!(*args)
        reconnect_without_retry!(*args)
      rescue PG::ConnectionBad => e
        raise e unless e.message.match?(/connection is closed/i)

        # We don't want to try to reconnect forever.
        portus_retries = portus_retries.nil? ? 0 : portus_retries + 1
        if portus_retries > 1
          Rails.logger.warn "Too many reconnects attempted..."
          raise e
        end

        # For now a simple `connect` does the trick...
        Rails.logger.warn "PostgreSQL connection closed, trying to connect again"
        connect
        retry
      end
    end
  end

end
