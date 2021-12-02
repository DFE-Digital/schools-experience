class NotifyRetryableErroringClient
  def initialize(api_key = nil); end

  def send_email(*_args)
    raise Notifications::Client::ServerError,
      OpenStruct.new(body: 'Missing template param', code: 500)
  end

  def send_sms(*_args)
    raise Notifications::Client::ServerError,
          OpenStruct.new(body: 'Missing template param', code: 500)
  end
end
