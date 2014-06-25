require 'sqlite3'

require_relative './../helpers/upload_model_helper'

$db = SQLite3::Database.open 'hashbang.db'
$upload_dir = 'uploads'

class UploadRepository

  def self.all
    select = <<-SQL
      SELECT *
      FROM uploads up, users u
      WHERE up.userid = u.id
      SQL
    results = $db.execute(select)
    UploadModelHelper.cast_upload_results results
  end

  def self.get_by_id(id)
    select =  <<-SQL
      SELECT *
      FROM uploads up, users u
      WHERE up.id = ?
      AND up.userid = u.id
      SQL
    results = $db.execute(select, id)
    uploads = UploadModelHelper.cast_upload_results results
    if uploads.count == 1
      uploads[0]
    else
      false
    end
  end
  
  def self.alphabetic(search, number, type)
    select =  <<-SQL
      SELECT *
      FROM uploads up, users u
      WHERE up.userid = u.id
      AND up.title like ?
      AND up.type like ?
      order by up.title asc
      LIMIT ?
      SQL
    search = '%' + search + '%'
    results = $db.execute(select, search, type, number)
    uploads = UploadModelHelper.cast_upload_results results
    uploads
  end
  
  def self.popular(search, number, type)
    select =  <<-SQL
      SELECT *
      FROM uploads up, users u
      WHERE up.userid = u.id
      AND up.title like ?
      AND up.type like ?
      order by up.overallScore desc
      LIMIT ?
      SQL
    search = '%' + search + '%'
    results = $db.execute(select, search, type, number)
    uploads = UploadModelHelper.cast_upload_results results
    uploads
  end
  
  def self.recent(search, number, type)
    select =  <<-SQL
      SELECT *
      FROM uploads up, users u
      WHERE up.userid = u.id
      AND up.title like ?
      AND up.type like ?
      order by up.upload_datetime desc
      LIMIT ?
      SQL
    search = '%' + search + '%'
    results = $db.execute(select, search, type, number)
    uploads = UploadModelHelper.cast_upload_results results
    uploads
  end
  
  def self.random(search, number, type)
    select =  <<-SQL
      SELECT *
      FROM uploads up, users u
      WHERE up.userid = u.id
      AND up.title like ?
      AND up.type like ?
      order by up.upload_datetime desc
      SQL
    search = '%' + search + '%'
    results = $db.execute(select, search, type).sample(number.to_i)
    uploads = UploadModelHelper.cast_upload_results results
    uploads
  end

  def self.save(upload)
    insert =  <<-SQL
      INSERT INTO uploads
      values (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      SQL
    $db.execute(insert, upload.upload_datetime, upload.type, upload.file_name, upload.original_file_name, upload.userid, upload.overallScore, upload.numOfRatings, upload.averageScore , upload.title, upload.description)
    upload_id = $db.last_insert_row_id()
  end

  def self.transfer_file(file, file_name)
    FileUtils.cp(file.tempfile.path, self.get_file_path(file_name))
  end

  def self.get_file_path(file_name)
    "#{$upload_dir}/#{file_name}"
  end

  def self.get_file_path_thumb(file_name)
    "#{$upload_dir}/#{file_name.split(".")[0]}_thumb.jpg"
  end

  def self.get_file_path_medium(file_name)
    "#{$upload_dir}/#{file_name.split(".")[0]}_medium.jpg"
  end

  def self.get_video_path(file_name)
    "#{file_name}"
  end

end
