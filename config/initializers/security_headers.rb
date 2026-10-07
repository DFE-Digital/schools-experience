# Be sure to restart your server when you modify this file.

Rails.application.config.action_dispatch.default_headers.merge!(
  "Cross-Origin-Opener-Policy" => "same-origin",
  "Cross-Origin-Resource-Policy" => "same-origin",
  "Permissions-Policy" =>
    "camera=(), microphone=(), geolocation=(), gyroscope=(), usb=(), payment=(), fullscreen=(self)"
)
