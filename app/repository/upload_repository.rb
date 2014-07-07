require 'pg'
require 'aws-sdk'

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
    results = $conn.exec_params(select, [search, type]).to_a.sample(number.to_i)
    uploads = UploadModelHelper.cast_upload_results results
    uploads
  end

  def self.save(upload)
    insert =  <<-SQL
      INSERT INTO uploads
      values (DEFAULT, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING id
      SQL
    upload_id = $conn.exec_params(insert, [upload.upload_datetime, upload.type, upload.file_name, upload.original_file_name, upload.userid, upload.overallScore, upload.numOfRatings, upload.averageScore , upload.title, upload.description])
    upload_id[0]['id']
  end
  
  def self.delete(id)
    delete =  <<-SQL
      DELETE FROM uploads
      WHERE id = $1
      SQL
      $conn.exec_params(delete, [id])
  end
  
  def self.delete_from_amazon(file_name)
		newFileResizedThumb = file_name[/[^.]+/]+'_thumb.jpg'
		newFileResizedMedium = file_name[/[^.]+/]+'_medium.jpg'
    
    key_thumb = File.basename(newFileResizedThumb)
    key_medium = File.basename(newFileResizedMedium)
    AWS.config({
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
      :region => 'eu-west-1',
    })
    bucket_name = 'hashbang'
    #file_name = '*** Provide file name ****'
    s3 = AWS::S3.new
    
    s3.buckets[bucket_name].objects[file_name].delete()
    s3.buckets[bucket_name].objects[key_thumb].delete()
    s3.buckets[bucket_name].objects[key_medium].delete()
  end

  def self.transfer_file(file, file_name)    
    AWS.config({
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
      :region => 'eu-west-1',
    })
    bucket_name = 'hashbang'
    #file_name = '*** Provide file name ****'

    # Get an instance of the S3 interface.
    s3 = AWS::S3.new

    # Upload a file.
    key = File.basename(file.tempfile.path)
    s3.buckets[bucket_name].objects[file_name].write(:file => file.tempfile.path)
    puts "Uploading file #{file_name} to bucket #{bucket_name}."
    #FileUtils.cp(file.tempfile.path, self.get_file_path(file_name))
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
