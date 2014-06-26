require 'grape'

require_relative 'config/application.rb'

namespace :db do

  desc "Create the database"
  task :create do
    puts "Creating uploads folder with data"
    unless File.directory?('uploads')
      Dir.mkdir 'uploads'
    end
    FileUtils.copy_entry 'db/local/uploads', 'uploads'
    puts "Deleting old db... if it exits"
    rm_f 'hashbang.db'
    puts "Creating the hashbang database..."
    HashBangDB.setup()
    puts "Seeding database..."
    HashBangDB.seed_uploads(Parser.parse_uploads('db/local/uploads.csv', Uploadmodel))
    HashBangDB.seed_tags(Parser.parse_tags('db/local/tags.csv', Tag))
    HashBangDB.seed_tag_objects(Parser.parse_tag_objects('db/local/tag_objects.csv'))
    puts "Done"
  end

  desc "Drop the databases"
  task :drop do
    puts "Deleting the database..."
    rm_f 'hashbang.db'
  end

end











