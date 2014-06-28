require 'json'
require 'digest/md5'
require_relative './../helpers/comment_helper'
require 'yaml'

class Uploadmodel

  attr_accessor :tags
  attr_accessor :tags_with_rank
  attr_accessor :comments
  attr_reader :upload_datetime, :type, :file_name, :original_file_name, :userid, :title, :description, :overallScore, :numOfRatings, :averageScore, :id, :gravatar

  CONFIG = YAML.load_file("./config/config.yml") unless defined? CONFIG
  
  def initialize(type, file_name, original_file_name, userid, title, description, upload_datetime = Time.now.to_s, id = nil, overallScore = 0, numOfRatings = 0, averageScore = 0, gravatar = "")
    @type = type
    @file_name = file_name
    @original_file_name = original_file_name
    @userid = userid
    @title = title
    @description = description
    @upload_datetime = upload_datetime
    @id = id
    @overallScore = overallScore
    @numOfRatings = numOfRatings
    @averageScore = averageScore
    @gravatar = gravatar
  end

  def to_json(*a)
    md5gravatar = Digest::MD5.hexdigest(@gravatar)
    {"id" => @id, "type" => @type, "file_name" => @file_name, "original_file_name" => @original_file_name, "file_name" => "#{CONFIG['backend_url']}/#{@file_name.split(".")[0]}", 
    "file_name_thumb" => "#{CONFIG['backend_url']}/#{@file_name.split(".")[0]}_thump.jpg", "file_name_medium" => "#{CONFIG['backend_url']}/#{@file_name.split(".")[0]}_medium.jpg", "userid" => @userid, 
    "upload_datetime" => @upload_datetime, "overallScore" => @overallScore, "numOfRatings" => @numOfRatings, "title" => @title, "description" => @description, "tags" => JSON.parse(@tags.to_json), 
    "tags_with_rank" => JSON.parse(@tags_with_rank.to_json),"comments" => JSON.parse(CommentHelper.toJSON(@comments)), "gravatar" => md5gravatar}.to_json(*a)
  end

end
