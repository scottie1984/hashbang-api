require 'pg'



require_relative './../model/tag'
require_relative './../model/uploadmodel'
require_relative './../helpers/upload_model_helper'

db_parts = ENV['DATABASE_URL'].split(/\/|:|@/)
  username = db_parts[3]
  password = db_parts[4]
  host = db_parts[5]
  db = db_parts[7]
  $conn = PGconn.open(:host =>  host, :dbname => db, :user=> username, :password=> password)

class CommentRepository
  
  def self.save(objectId, comment, userId)
    insert =  <<-SQL
      INSERT INTO comments
      values (DEFAULT, now(), $1, $2, $3)
      SQL
      $conn.exec_params(insert, [objectId, comment, userId])
  end
  
  def self.find_by_object_id(object_id)
    conn = PGconn.open(:dbname => 'hashbang')
    select = <<-SQL
      SELECT c.id, us.username, c.comment, c.comment_datetime, us.email
      FROM comments c 
        join uploads u on c.object_id = u.id
        join users us on c.userid = us.id
      WHERE c.object_id = $1
      ORDER BY c.comment_datetime desc
      SQL
    results = $conn.exec_params(select, [object_id])
    results
  end
  
  def self.delete(id)
    conn = PGconn.open(:dbname => 'hashbang')
    delete =  <<-SQL
      DELETE FROM comments
      WHERE id = $1
      SQL
      $conn.exec_params(delete, [id])
  end


end