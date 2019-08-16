def enable_feature(feature)
  existing_features = Rails.application.config.x.features.dup
  Rails.application.config.x.features << feature
  yield
ensure
  Rails.application.config.x.features = existing_features
end

Around '@dbs_requirement_feature' do |scenario, block|
  enable_feature :dbs_requirement, &block
end
