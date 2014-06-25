require 'sqlite3'

require_relative './../model/tag'
require_relative './../model/uploadmodel'
require_relative './../helpers/tag_helper'
require_relative './../helpers/upload_model_helper'

$db = SQLite3::Database.open 'hashbang.db'

class TagRepository

  def self.save(tag)
    insert =  <<-SQL
      INSERT INTO tags
      values (NULL, ?, ?, datetime('now'), 0, ?)
      SQL
      $db.execute(insert, tag.tagName, tag.userId, tag.type)
    tagId = $db.last_insert_row_id()
    tagId
  end
  
  def self.findByName(tagName)
    row = $db.get_first_row("select * from tags where tagName = ? and type='tag'", tagName)
    tagId = -1
    if row != nil
      tagId = row[0]
    end
    tagId
  end
  
  def self.findUserTagByName(tagName)
    row = $db.get_first_row("select * from tags where tagName = ? and type='user'", tagName)
    tagId = -1
    if row != nil
      tagId = row[0]
    end
    tagId
  end
  
  def self.tagObject(objectId, tagId)
    insert =  <<-SQL
      INSERT INTO tag_objects
      values (NULL, ?, ?, datetime('now'))
      SQL
    $db.execute(insert, objectId, tagId)
    update =  <<-SQL
      update tags
      set numOfObjects = numOfObjects + 1 
      where id = ?
      SQL
    $db.execute(update, tagId)
  end
  
  def self.all(type)
    results = $db.execute("select id, userid, tagName, numOfObjects from tags where type = ?", type)
  end
  
  def self.alphabetic(search, number, type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type, tag_datetime from tags
      where tagName like ? and type like ?
      order by tagName asc
      limit ? 
      SQL
      
      search = '%' + search + '%'
    results = $db.execute(select, search, type, number)
  end
  
  def self.popular(search, number, type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type, tag_datetime from tags
      where tagName like ? and type like ?
      order by numOfObjects desc
      limit ? 
      SQL
      
      search = '%' + search + '%'
    results = $db.execute(select, search, type, number)
  end
  
  def self.recent(search, number, type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type from tags
      where tagName like ? and type like ?
      order by tag_datetime desc
      limit ?
      SQL
      
      search = '%' + search + '%'
    results = $db.execute(select, search, type, number)
  end
  
  def self.random(search, number, type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type from tags
      where tagName like ? and type like ?
      order by tag_datetime desc
      SQL
      
      search = '%' + search + '%'
    results = $db.execute(select, search, type)
    results.sample(number.to_i)
  end
  
  def self.random_not_current(current, type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type from tags
      where tagName != ? and type like ?
      order by tag_datetime desc
      SQL
    results = $db.execute(select, current, type)
    results.sample(1)
  end

  def self.random_start(type)
    select = <<-SQL
      select id, userid, tagName, numOfObjects, type from tags
      where type like ?
      order by tag_datetime desc
      SQL
    results = $db.execute(select, type)
    results.sample(1)
  end

  def self.find_by_object_id(object_id)
    select = <<-SQL
      SELECT t.id, t.userid, t.tagName
      FROM tag_objects o join tags t on t.id = o.tagid
      WHERE o.objectid = ? and t.type = 'tag'
      SQL
    results = $db.execute(select, object_id)
    tags = TagHelper.cast_results results
  end

end
