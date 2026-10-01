# frozen_string_literal: true

# Ruby 4.0 (continuing the 3.5 `cgi` library slim-down) removed CGI.parse.
# CGI.escape / CGI.unescape remain, but the query-string parser is gone.
#
# prometheus-client 4.2.2 still calls CGI.parse to decode metric label sets in
# DirectFileStore#all_values (direct_file_store.rb:139), so GET /metrics raises
# `NoMethodError: undefined method 'parse' for class CGI` as soon as there is
# file-store data to aggregate.
#
# Restore the classic CGI.parse implementation as an interim fix.
#
# HOW TO REMOVE THIS SHIM:
#   prometheus-client 5.0.0 drops CGI entirely (it uses URI.encode_www_form /
#   URI.decode_www_form instead), which is Ruby 4.0-safe. The whole 4.x line,
#   including the latest 4.2.5, still calls CGI.parse, so an in-range bump does
#   NOT fix this -- only 5.0.0 does.
#
#   5.0.0 is currently blocked by yabeda-prometheus, which pins
#   `prometheus-client >= 3.0, < 5.0` (on its latest release 0.9.1 and on its
#   master branch, checked 2026-09-30). So this shim can be deleted once BOTH:
#     1. yabeda-prometheus releases a version allowing prometheus-client >= 5.0, and
#     2. this app is upgraded to prometheus-client >= 5.0.
#
#   Upstream cap to watch: https://github.com/yabeda-rb/yabeda-prometheus
require "cgi"

unless CGI.respond_to?(:parse)
  def CGI.parse(query)
    params = {}

    query.split(/[&;]/).each do |pairs|
      key, value = pairs.split("=", 2).collect { |v| CGI.unescape(v) }
      next unless key

      params[key] ||= []
      params[key].push(value) if value
    end

    params.default = [].freeze
    params
  end
end
