namespace :assets do
  desc "Symlink production packs for use in test environments"
  task symlink_packs: :environment do
    production_packs = Rails.root.join('public', 'packs')
    test_packs = Rails.root.join('public', 'packs-test')

    File.symlink production_packs, test_packs
  end
end
