# TODO: remove this class once all user sessions have expired
class UserInfoDecorator < SimpleDelegator
  # The dfe-analytics gem expects current_user to respond
  # to `id`. Our `current_user` is an instance of the
  #  `OpenIDConnect::ResponseObject::UserInfo` which does not
  # respond to `id`, so we alias it to the `sub` attribute here.
  alias_attribute :id, :sub
end
