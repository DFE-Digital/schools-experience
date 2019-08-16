def enable_feature(feature)
  existing_features = Rails.application.config.x.features.dup
  allow(Rails.application.config.x).to receive(:features) do
    existing_features << feature
  end
end
