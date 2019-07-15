class NotifyNonRetryableErroringClient
  def initialize(api_key = nil); end

  def send_email(*_args)
    raise Notifications::Client::RequestError,
      OpenStruct.new(body: 'Unauthorized', code: 401)
  end
end
