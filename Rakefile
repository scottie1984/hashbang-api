require 'sqlite3'
require 'grape'
require 'rspec/core/rake_task'

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
    HashBangDB.setup(SQLite3::Database.new('hashbang.db'))
    puts "Seeding database..."
    HashBangDB.seed_uploads(Parser.parse_uploads('db/local/uploads.csv', Uploadmodel), SQLite3::Database.new('hashbang.db'))
    HashBangDB.seed_tags(Parser.parse_tags('db/local/tags.csv', Tag), SQLite3::Database.new('hashbang.db'))
    HashBangDB.seed_tag_objects(Parser.parse_tag_objects('db/local/tag_objects.csv'), SQLite3::Database.new('hashbang.db'))
    puts "Done"
  end

  desc "Drop the databases"
  task :drop do
    puts "Deleting the database..."
    rm_f 'hashbang.db'
  end

  desc 'Prepare testing database'
  task :testprep do
    puts "Deleting old test db... if it exits"
    rm_f 'hashbang_test.db'
    puts "Creating test db... "
    HashBangDB.setup(SQLite3::Database.new('hashbang_test.db'))
    puts "Seeding database..."
    HashBangDB.seed_uploads(Parser.parse_uploads('db/uploads.csv', Uploadmodel), SQLite3::Database.new('hashbang_test.db'))
    HashBangDB.seed_tags(Parser.parse_tags('db/tags.csv', Tag), SQLite3::Database.new('hashbang_test.db'))
    HashBangDB.seed_tag_objects(Parser.parse_tag_objects('db/tag_objects.csv'), SQLite3::Database.new('hashbang_test.db'))
    puts "Done"
  end

end

desc "Run the specs"
task :spec do
  Rake::Task['db:testprep'].invoke
  RSpec::Core::RakeTask.new(:spec)
end











