require 'csv'
require 'sqlite3'
require 'grape'
require 'json'

require_relative '../app/model/uploadmodel'
require_relative '../app/model/tag'
require_relative '../db/parser'
require_relative '../db/hashbang_db_setup'

@backend_url = 'localhost:9292'
@frontend_url = 'localhost:8000'