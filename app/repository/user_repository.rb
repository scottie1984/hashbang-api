require 'pg'

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

class UserRepository

  def self.getUsername(id)
    select =  <<-SQL
      select username from users
      where id = $1
      SQL
    row = $conn.exec_params(select, [id])
    row[0]['username']
  end
  
  def self.popular(number)
    select =  <<-SQL
      select ',',us.username as tagname, sum(up.overallScore) as numofobjects, 'user' as type from uploads up, users us
      where up.userid = us.id
      group by up.userid,us.username
      order by numofobjects desc
      limit $1
      SQL
    rows = $conn.exec_params(select, [number])
    rows
  end

end