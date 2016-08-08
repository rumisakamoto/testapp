# -*- encoding : utf-8 -*-
class Logger
  class Logger
    class Formatter
      def call(severity, time, progname, msg)
        format = "[%s #%d] %5s -- %s: %s\n"
        format % ["#{time.strftime('%Y-%m-%d %H:%M:%S')}.#{'%06d' % time.usec.to_s}",
          $$, severity, progname, msg2str(msg)]
      end
    end
  end
end
# configure logger
Rails.application.configure do
  config.logger = Logger.new(config.paths["log"].first, 'daily')
  config.logger.formatter = Logger::Formatter.new
  config.logger.datetime_format = "%Y-%m-%d %H:%M:%S"
  config.logger.level = Logger::DEBUG
  #config.colorize_logging = false
end
