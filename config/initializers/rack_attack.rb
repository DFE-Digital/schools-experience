module Rack
  class Attack
    FAIL2BAN_LIST = %w[
      /etc/passwd
      wp-admin
      wp-login
      wp-includes
      .php
    ].freeze

    FAIL2BAN_REGEX = Regexp.union(FAIL2BAN_LIST).freeze

    unless ENV["SKIP_REQ_LIMITS"].to_s.in? %w[true yes 1]
      # Throttle candidate feedback submissions by IP (5rpm)
      throttle("candidates/feedbacks req/ip", limit: 5, period: 1.minute) do |req|
        req.ip if req.post? && req.path == "/candidates/feedbacks"
      end

      # Throttle candidate registration submissions by IP (5rpm)
      throttle("registrations/confirmation_email req/ip", limit: 5, period: 1.minute) do |req|
        req.ip if req.post? && req.path.match?(/registrations\/confirmation_email/)
      end
    end

    if ENV["FAIL2BAN"].to_s.match? %r{\A\d+\z}
      FAIL2BAN_TIME = ENV["FAIL2BAN"].to_s.to_i.minutes.freeze

      blocklist("block hostile bots") do |req|
        Fail2Ban.filter("hostile-bots-#{req.ip}", maxretry: 0, findtime: 1.second, bantime: FAIL2BAN_TIME) do
          (
            FAIL2BAN_REGEX.match?(CGI.unescape(req.query_string)) ||
            FAIL2BAN_REGEX.match?(req.path)
          ).tap do |should_ban|
            if should_ban
              obscured_ip = req.ip.to_s.gsub(%r{\.\d+\.(\d+)\.}, ".***.***.")

              Rails.logger.info(
                <<~BAN_MESSAGE,
                  Banning IP: #{obscured_ip} for #{FAIL2BAN_TIME.to_i / 60} minutes
                  accessing #{req.path} with '#{req.query_string}'
                BAN_MESSAGE
              )
            end
          end
        end
      end
    end
  end

  # Redirect to custom response for throttled requests
  Rack::Attack.throttled_response = lambda do |_env|
    [301, { "Location" => '/429' }, []]
  end
end
