require 'pg'

module HashBangDB

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
  
  def self.setup()
    
    
    $conn.exec(
      <<-SQL
      CREATE TABLE users (
        id serial PRIMARY KEY,
        username VARCHAR(50) NOT NULL,
        password VARCHAR(255) NOT NULL,
        email VARCHAR(50) NOT NULL,
        status VARCHAR(50) NOT NULL,
        loginAttempts INTEGER
        );
      SQL
    )
    $conn.exec(
      <<-SQL
      INSERT INTO users
      values (DEFAULT, 'cat_lover1990', '$2a$10$Iv1tOac6mjL2.A2FiHmRquWf4MPuFBo59de1iMsSwzg8eUjBcIyb.', 'sommes.email@gmail.com', 'active', 0)
      SQL
    )
    $conn.exec(
      <<-SQL
      INSERT INTO users
      values (DEFAULT, 'dog_lover1980', '$2a$10$Iv1tOac6mjL2.A2FiHmRquWf4MPuFBo59de1iMsSwzg8eUjBcIyb.', 'davethompson21@gmail.com', 'active', 0)
      SQL
    )
    $conn.exec(
      <<-SQL
      CREATE TABLE session (
        id serial PRIMARY KEY,
        userid INTEGER NOT NULL,
        username VARCHAR(50) NOT NULL,
        expires timestamp NOT NULL,
        token VARCHAR(255) NOT NULL 
        );
      SQL
    )
    $conn.exec(
      <<-SQL
      CREATE TABLE user_token (
        id serial PRIMARY KEY,
        userid INTEGER NOT NULL,
        expires timestamp NOT NULL,
        token VARCHAR(255) NOT NULL
        );
      SQL
    )
    $conn.exec(
      <<-SQL
      CREATE TABLE uploads (
        id serial PRIMARY KEY,
        upload_datetime TEXT NOT NULL,
        type VARCHAR(255) NOT NULL,
        file_name VARCHAR(255) NOT NULL,
        original_file_name VARCHAR(255) NOT NULL,
        userid INTEGER NOT NULL,
        overallScore INTEGER,
        numOfRatings INTEGER,
        averageScore REAL NOT NULL,
        title VARCHAR(255) NOT NULL,
        description VARCHAR(255) NULL
        );
      SQL
    )
    $conn.exec(
      <<-SQL
      CREATE TABLE ratings (
        id serial PRIMARY KEY,
        rating_datetime timestamp NOT NULL,
        againstTag VARCHAR(255) NOT NULL,
        object_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        userid INTEGER NOT NULL
        );
      SQL
    )  
    $conn.exec(
      <<-SQL
      CREATE TABLE tags (
        id serial PRIMARY KEY,
        tagName VARCHAR(255) NOT NULL,
        userid INTEGER NOT NULL,
        tag_datetime timestamp NOT NULL,
        numOfObjects INTEGER NOT NULL,
        type VARCHAR(20) NOT NULL
        );
      SQL
    )
    $conn.exec(
      <<-SQL
      CREATE TABLE tag_objects (
        id serial PRIMARY KEY,
        objectId INTEGER NOT NULL,
        tagId INTEGER NOT NULL,
        tag_datetime DATE NOT NULL
        );
      SQL
    )
    $conn.exec(
    <<-SQL
    CREATE TABLE comments (
      id serial PRIMARY KEY,
      comment_datetime timestamp NOT NULL,
      object_id INTEGER NOT NULL,
      comment TEXT NOT NULL,
      userid INTEGER NOT NULL
      );
    SQL
    )
  end

  def self.seed_uploads(uploads)
    insert =  <<-SQL
      INSERT INTO uploads
      values (DEFAULT, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      SQL
    uploads.each do |upload|
      $conn.exec_params(insert, [upload.upload_datetime, upload.type, upload.file_name, upload.original_file_name, upload.userid, upload.overallScore, upload.numOfRatings, upload.averageScore , upload.title, upload.description])
    end
  end

  def self.seed_tags(tags)
    insert = <<-SQL
      INSERT INTO tags
      VALUES (DEFAULT, $1, $2, $3, $4, $5)
      SQL
    tags.each do |tag|
      $conn.exec_params(insert, [tag.tagName, tag.userId, tag.tag_datetime, tag.numOfObjects, tag.type])
    end
  end

  def self.seed_tag_objects(tag_objects)
    insert = <<-SQL
      INSERT INTO tag_objects
      VALUES (DEFAULT, $1, $2, $3)
      SQL
    tag_objects.each do |tag_object|
      $conn.exec_params(insert, [tag_object["objectid"], tag_object["tagid"], tag_object["tag_datetime"]])
    end
  end
  
  def self.drop()
    
    $conn.exec(
      <<-SQL
      DROP TABLE users cascade;
      SQL
    )
    $conn.exec(
      <<-SQL
      DROP TABLE session cascade;
      SQL
    )
    $conn.exec(
      <<-SQL
      DROP TABLE user_token cascade;
      SQL
    )
    $conn.exec(
      <<-SQL
      DROP TABLE uploads cascade;
      SQL
    )
    $conn.exec(
      <<-SQL
      DROP TABLE ratings cascade;
      SQL
    )  
    $conn.exec(
      <<-SQL
      DROP TABLE tags cascade;
      SQL
    )
    $conn.exec(
      <<-SQL
      DROP TABLE tag_objects cascade;
      SQL
    )
    $conn.exec(
    <<-SQL
    DROP TABLE comments cascade;
    SQL
    )
  end
  
end
