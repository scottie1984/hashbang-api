require 'pg'

$conn = PGconn.open(:dbname => 'hashbang')

class UserRepository

  def self.getUsername(id)
    select =  <<-SQL
      select username from users
      where id = $1
      SQL
    row = $conn.exec_params(select, [id])
    row[0]
  end
  
  def self.popular(number)
    select =  <<-SQL
      select ',',us.username, sum(up.overallScore), 'user' as totalScore from uploads up, users us
      where up.userid = us.id
      group by up.userid,us.username
      order by totalScore desc
      limit $1
      SQL
    rows = $conn.exec_params(select, [number])
    rows
  end

end