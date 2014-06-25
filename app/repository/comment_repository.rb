require 'sqlite3'

require_relative './../model/tag'
require_relative './../model/uploadmodel'
require_relative './../helpers/upload_model_helper'

$db = SQLite3::Database.open 'hashbang.db'

class CommentRepository
  
  def self.save(objectId, comment, userId)
    insert =  <<-SQL
      INSERT INTO comments
      values (NULL, datetime('now'), ?, ?, ?)
      SQL
      $db.execute(insert, objectId, comment, userId)
  end
  
  def self.find_by_object_id(object_id)
    select = <<-SQL
      SELECT c.id, us.username, c.comment, c.comment_datetime, us.email
      FROM comments c 
        join uploads u on c.object_id = u.id
        join users us on c.userid = us.id
      WHERE c.object_id = ?
      ORDER BY c.comment_datetime desc
      SQL
    results = $db.execute(select, object_id)
    results
  end
  
  def self.delete(id)
    delete =  <<-SQL
      DELETE FROM comments
      WHERE id = ?
      SQL
      $db.execute(delete, id)
  end


end