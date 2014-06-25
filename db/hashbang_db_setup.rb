$hashbang_db = SQLite3::Database.new 'hashbang.db'

module HashBangDB
  
  def self.setup(database)
    database.execute(
      <<-SQL
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username VARCHAR(50) NOT NULL,
        password VARCHAR(255) NOT NULL,
        email VARCHAR(50) NOT NULL,
        status VARCHAR(50) NOT NULL,
        loginAttempts INTEGER
        );
      SQL
    )
    database.execute(
      <<-SQL
      INSERT INTO users
      values (NULL, 'cat_lover1990', '$2a$10$Iv1tOac6mjL2.A2FiHmRquWf4MPuFBo59de1iMsSwzg8eUjBcIyb.', 'sommes.email@gmail.com', 'active', 0)
      SQL
    )
    database.execute(
      <<-SQL
      INSERT INTO users
      values (NULL, 'dog_lover1980', '$2a$10$Iv1tOac6mjL2.A2FiHmRquWf4MPuFBo59de1iMsSwzg8eUjBcIyb.', 'davethompson21@gmail.com', 'active', 0)
      SQL
    )
    database.execute(
      <<-SQL
      CREATE TABLE session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userid INTEGER NOT NULL,
        username VARCHAR(50) NOT NULL,
        expires DATETIME NOT NULL,
        token VARCHAR(255) NOT NULL 
        );
      SQL
    )
    database.execute(
      <<-SQL
      CREATE TABLE user_token (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userid INTEGER NOT NULL,
        expires DATETIME NOT NULL,
        token VARCHAR(255) NOT NULL
        );
      SQL
    )
    database.execute(
      <<-SQL
      CREATE TABLE uploads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    database.execute(
      <<-SQL
      CREATE TABLE ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rating_datetime DATETIME NOT NULL,
        againstTag VARCHAR(255) NOT NULL,
        object_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        userid INTEGER NOT NULL
        );
      SQL
    )  
    database.execute(
      <<-SQL
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagName VARCHAR(255) NOT NULL,
        userid INTEGER NOT NULL,
        tag_datetime DATETIME NOT NULL,
        numOfObjects INTEGER NOT NULL,
        type VARCHAR(20) NOT NULL
        );
      SQL
    )
    database.execute(
      <<-SQL
      CREATE TABLE tag_objects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        objectId INTEGER NOT NULL,
        tagId INTEGER NOT NULL,
        tag_datetime DATETIME NOT NULL
        );
      SQL
    )
    database.execute(
    <<-SQL
    CREATE TABLE comments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      comment_datetime DATETIME NOT NULL,
      object_id INTEGER NOT NULL,
      comment TEXT NOT NULL,
      userid INTEGER NOT NULL
      );
    SQL
    )
  end

  def self.seed_uploads(uploads, database)
    insert =  <<-SQL
      INSERT INTO uploads
      values (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      SQL
    uploads.each do |upload|
      database.execute(insert, upload.upload_datetime, upload.type, upload.file_name, upload.original_file_name, upload.userid, upload.overallScore, upload.numOfRatings, upload.averageScore , upload.title, upload.description)
    end
  end

  def self.seed_tags(tags, database)
    insert = <<-SQL
      INSERT INTO tags
      VALUES (NULL, ?, ?, ?, ?, ?)
      SQL
    tags.each do |tag|
      database.execute(insert, tag.tagName, tag.userId, tag.tag_datetime, tag.numOfObjects, tag.type)
    end
  end

  def self.seed_tag_objects(tag_objects, database)
    insert = <<-SQL
      INSERT INTO tag_objects
      VALUES (NULL, ?, ?, ?)
      SQL
    tag_objects.each do |tag_object|
      database.execute(insert, tag_object["objectid"], tag_object["tagid"], tag_object["tag_datetime"])
    end
  end
  
end
