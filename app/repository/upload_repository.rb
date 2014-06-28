require 'pg'

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
$upload_dir = 'uploads'

class UploadRepository

  def self.all
    select = <<-SQL
      SELECT *, up.type as uploadtype, up.id as upid
      FROM uploads up, users u
      WHERE up.userid = u.id
      SQL
    results = $conn.exec_params(select)
    UploadModelHelper.cast_upload_results results
  end

  def self.get_by_id(id)
    select =  <<-SQL
      SELECT *, up.type as uploadtype, up.id as upid
      FROM uploads up, users u
      WHERE up.id = $1
      AND up.userid = u.id
      SQL
    results = $conn.exec_params(select, [id])
    uploads = UploadModelHelper.cast_upload_results results
    if uploads.count == 1
      uploads[0]
    else
      false
    end
  end
  
  def self.alphabetic(search, number, type)
    select =  <<-SQL
      SELECT *, up.type as uploadtype, up.id as upid
      FROM uploads up, users u
      WHERE up.userid = u.id
      AND up.title like $1
      AND up.type like $2
      order by up.title asc
      LIMIT $3
      SQL
    search = '%' + search + '%'
    results = $conn.exec_params(select, [search, type, number])
    uploads = UploadModelHelper.cast_upload_results results
    uploads
  end
  
  def self.popular(search, number, type)
    select =  <<-SQL
      SELECT *, up.type as uploadtype, up.id as upid
      FROM uploads up, users u
      WHERE up.userid = u.id
      AND up.title like $1
      AND up.type like $2
      order by up.overallScore desc
      LIMIT $3
      SQL
    search = '%' + search + '%'
    results = $conn.exec_params(select, [search, type, number])
    uploads = UploadModelHelper.cast_upload_results results
    uploads
  end
  
  def self.recent(search, number, type)
    select =  <<-SQL
      SELECT *, up.type as uploadtype, up.id as upid
      FROM uploads up, users u
      WHERE up.userid = u.id
      AND up.title like $1
      AND up.type like $2
      order by up.upload_datetime desc
      LIMIT $3
      SQL
    search = '%' + search + '%'
    results = $conn.exec_params(select, [search, type, number])
    uploads = UploadModelHelper.cast_upload_results results
    uploads
  end
  
  def self.random(search, number, type)
    select =  <<-SQL
      SELECT *, up.type as uploadtype, up.id as upid
      FROM uploads up, users u
      WHERE up.userid = u.id
      AND up.title like $1
      AND up.type like $2
      order by up.upload_datetime desc
      SQL
    search = '%' + search + '%'
    results = $conn.exec_params(select, [search, type]).sample(number.to_i)
    uploads = UploadModelHelper.cast_upload_results results
    uploads
  end

  def self.save(upload)
    insert =  <<-SQL
      INSERT INTO uploads
      values (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      SQL
    #$db.execute(insert, upload.upload_datetime, upload.type, upload.file_name, upload.original_file_name, upload.userid, upload.overallScore, upload.numOfRatings, upload.averageScore , upload.title, upload.description)
    #upload_id = $db.last_insert_row_id()
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
