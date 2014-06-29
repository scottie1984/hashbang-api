require 'pg'

require_relative './../model/tag'
require_relative './../model/uploadmodel'
require_relative './../helpers/tag_helper'
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

class TagRepository

  def self.save(tag)
    insert =  <<-SQL
      INSERT INTO tags
      values (DEFAULT, $1, $2, now(), 0, $3)
      RETURNING id
      SQL
     tagId = $conn.exec_params(insert, [tag.tagName, tag.userId, tag.type])
    tagId[0]['id']
  end
  
  def self.findByName(tagName)
    row = $conn.exec_params("select * from tags where tagName = $1 and type='tag'", [tagName])
    tagId = -1
    if !row.num_tuples.zero?
      tagId = row[0]['id']
    end
    tagId
  end
  
  def self.findUserTagByName(tagName)
    row = $conn.exec_params("select * from tags where tagName = $1 and type='user'", [tagName])
    tagId = -1
    if !row.num_tuples.zero?
      tagId = row[0]['id']
    end
    tagId
  end
  
  def self.tagObject(objectId, tagId)
    insert =  <<-SQL
      INSERT INTO tag_objects
      values (DEFAULT, $1, $2, now())
      SQL
    $conn.exec_params(insert, [objectId, tagId])
    update =  <<-SQL
      update tags
      set numOfObjects = numOfObjects + 1 
      where id = $1
      SQL
    $conn.exec_params(update, [tagId])
  end
  
  def self.all(type)
    results = $conn.exec_params("select id, userid, tagName, numOfObjects from tags where type = $1", [type])
  end
  
  def self.alphabetic(search, number, type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type, tag_datetime from tags
      where tagName like $1 and type like $2
      order by tagName asc
      limit $3 
      SQL
      
      search = '%' + search + '%'
    results = $conn.exec_params(select, [search, type, number])
  end
  
  def self.popular(search, number, type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type, tag_datetime from tags
      where tagName like $1 and type like $2
      order by numOfObjects desc
      limit $3 
      SQL
      
      search = '%' + search + '%'
    results = $conn.exec_params(select, [search, type, number])
  end
  
  def self.recent(search, number, type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type from tags
      where tagName like $1 and type like $2
      order by tag_datetime desc
      limit $3
      SQL
      
      search = '%' + search + '%'
    results = $conn.exec_params(select, [search, type, number])
  end
  
  def self.random(search, number, type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type from tags
      where tagName like $1 and type like $2
      order by tag_datetime desc
      SQL
      
      search = '%' + search + '%'
    results = $conn.exec_params(select, [search, type])
    results.to_a.sample(number.to_i)
  end
  
  def self.random_not_current(current, type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type from tags
      where tagName != $1 and type like $2
      order by tag_datetime desc
      SQL
    results = $conn.exec_params(select, [current, type])
    results.to_a.sample(1)
  end

  def self.random_start(type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type from tags
      where type like $1
      order by tag_datetime desc
      SQL
    results = $conn.exec_params(select, [type])
    results.to_a.sample(1)
  end

  def self.find_by_object_id(object_id)
    select = <<-SQL
      SELECT t.id, t.userid, t.tagName
      FROM tag_objects o join tags t on t.id = o.tagid
      WHERE o.objectid = $1 and t.type = 'tag'
      SQL
    results = $conn.exec_params(select, [object_id])
    tags = TagHelper.cast_results results
  end

end
