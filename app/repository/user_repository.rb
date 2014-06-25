require 'sqlite3'

$db = SQLite3::Database.open 'hashbang.db'

class UserRepository

  def self.getUsername(id)
    select =  <<-SQL
      select username from users
      where id = ?
      SQL
    row = $db.get_first_row(select, id)
    row[0]
  end
  
  def self.popular(number)
    select =  <<-SQL
      select "","",us.username, sum(up.overallScore), "user" as totalScore from uploads up, users us
      where up.userid = us.id
      group by up.userid
      order by totalScore desc
      limit ?
      SQL
    rows = $db.execute(select, number)
    rows
  end

end