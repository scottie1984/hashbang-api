require 'sqlite3'

require_relative './../model/rating'

$db = SQLite3::Database.open 'hashbang.db'

class RatingRepository

  def self.save(rating)
    insert =  <<-SQL
      INSERT INTO ratings
      values (NULL, datetime('now'), ?, ?, ?, ?)
      SQL
      $db.execute(insert, rating.againstTag, rating.objectId, rating.score, rating.userid)
  end
  
  def self.updateScore(objectId, score)
    update =  <<-SQL
      update uploads
      set overallScore = overallScore + ?, numOfRatings = numOfRatings + 1 
      where id = ?
      SQL
      $db.execute(update, score, objectId)
    updateAverageScore =  <<-SQL
        update uploads
        set averageScore = (overallScore * 1.0) / numOfRatings
        where id = ?
        SQL
        $db.execute(updateAverageScore, objectId)
  end

end
