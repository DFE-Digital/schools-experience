namespace :assets do
  desc "Symlink non digested versions of assets, for use by static error pages"
  task symlink_non_digested: :environment do
    # limit to stylesheets for the time being
    assets = Dir.glob(Rails.root.join('public/assets/**/*.{css,ico,png}'))

    regex = /(-{1}[a-z0-9]{32}*\.{1}){1}/
    assets.each do |file|
      next if File.directory?(file) || file !~ regex

      source = file.split('/')
      source.push(source.pop.gsub(regex, '.'))

      non_digested = File.join(source)
      FileUtils.symlink(file, non_digested)
    end
  end
end
