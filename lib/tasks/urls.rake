namespace :urls do
  desc 'Recreate URL Mappings index'
  task recreate_index: :environment do
    UrlMapper.recreate_index
  end
end
