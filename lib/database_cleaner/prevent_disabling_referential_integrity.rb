module PreventDisablingReferentialIntegrity
  def disable_referential_integrity
    yield
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter \
  .include PreventDisablingReferentialIntegrity
