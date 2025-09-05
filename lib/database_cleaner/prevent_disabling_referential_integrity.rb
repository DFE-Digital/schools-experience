module DatabaseCleaner
  module PreventDisablingReferentialIntegrity
    def disable_referential_integrity
      yield
    end
  end
end


ActiveRecord::ConnectionAdapters::PostgreSQLAdapter \
  .include DatabaseCleaner::PreventDisablingReferentialIntegrity
