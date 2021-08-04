class OverrideCsp
  def initialize(app, csp = :allow_all)
    @app = app
    @csp = policy[csp]
  end

  def call(env)
    status, headers, body = @app.call(env)
    [status, headers.merge('Content-Security-Policy' => @csp), body]
  end

  private

  def policy
    {
      allow_all: "default_src: *",
      flipper: "default-src 'self'; base-uri 'self'; connect-src 'self'; img-src 'self'; object-src 'none'; script-src 'self' https://code.jquery.com/jquery-3.2.1.slim.min.js https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js; style-src 'self' 'unsafe-inline' https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"
    }
  end
end
