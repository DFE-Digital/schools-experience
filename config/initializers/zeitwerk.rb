Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect \
    "api" => "API",
    "crm" => "CRM",
    "dbs_fee" => "DBSFee",
    "dfe_sign_in_api" => "DFESignInAPI",
    "dfe_authentication" => "DFEAuthentication"
end
