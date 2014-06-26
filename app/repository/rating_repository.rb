require 'pg'

require_relative './../model/rating'

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

class RatingRepository

  def self.save(rating)
    insert =  <<-SQL
      INSERT INTO ratings
      values (NULL, now(), $1, $2, $3, $4)
      SQL
      $conn.exec_params(insert, [rating.againstTag, rating.objectId, rating.score, rating.userid])
  end
  
  def self.updateScore(objectId, score)
    update =  <<-SQL
      update uploads
      set overallScore = overallScore + $1, numOfRatings = numOfRatings + 1 
      where id = $2
      SQL
      $conn.exec_params(update, [score, objectId])
    updateAverageScore =  <<-SQL
        update uploads
        set averageScore = (overallScore * 1.0) / numOfRatings
        where id = $1
        SQL
        $conn.exec_params(updateAverageScore, [objectId])
  end

end
