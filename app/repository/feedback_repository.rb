require 'pg'



require_relative './../model/tag'
require_relative './../model/uploadmodel'
require_relative './../helpers/upload_model_helper'

env = ENV['DATABASE_URL'] || 'localhost'

if env == 'localhost'
  $conn = PGconn.open(:dbname => 'hashbang', :user=> 'postgres')
else
  db_parts = ENV['DATABASE_URL'].split(/\/|:|@/)
  username = db_parts[3]
  password = db_parts[4]
  host = db_parts[5]
  db = db_parts[7]
  $conn = PGconn.open(:host =>  host, :dbname => db, :user=> username, :password=> password)
end

class FeedbackRepository
  
  def self.save(feedback)
    insert =  <<-SQL
      INSERT INTO feedback
      values (DEFAULT, now(), $1)
      SQL
      $conn.exec_params(insert, [feedback])
  end
  
  def self.all()
    results = $conn.exec("select * from feedback")
    results.to_a
  end


end