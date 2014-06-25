require 'grape'
require 'json'
require 'rack/contrib'

require_relative './../model/uploadmodel'
require_relative './../repository/upload_repository'
require_relative './../repository/tag_repository'
require_relative './../helpers/tag_helper'
require_relative './../model/error'
require_relative './../model/user'
require_relative './../model/resize'

module SocialChallenges

  class UploadAPI < Grape::API

    use Rack::JSONP
    format :json

    get :all do
      JSON.parse(UploadRepository.all.to_json)
    end

    get '/:id' do
      upload = UploadRepository.get_by_id(params[:id])
      if !upload then
        error! 'Upload not found', 404
      else
        upload.tags = TagRepository.find_by_object_id(upload.id)
        JSON.parse(upload.to_json)
      end
    end

    get '/:id/download' do
      upload = UploadRepository.get_by_id params[:id]
      if !upload then
        error! 'Upload not found', 404
      else
        if upload.type === 'image'
          file_path = UploadRepository.get_file_path upload.file_name
          data = File.open(file_path, 'rb').read
        end
        if upload.type === 'video'
          file_path = UploadRepository.get_video_path upload.file_name
          data = file_path
        end  
        content_type upload.type
        env['api.format'] = :binary
        present data
      end
    end

    get '/:id/download/thumb' do
      upload = UploadRepository.get_by_id params[:id]
      if !upload then
        error! 'Upload not found', 404
      else
        if upload.type === 'image'
          file_path = UploadRepository.get_file_path_thumb upload.file_name
          data = File.open(file_path, 'rb').read
        end
        content_type upload.type
        env['api.format'] = :binary
        present data
      end
    end

    get '/:id/download/medium' do
      upload = UploadRepository.get_by_id params[:id]
      if !upload then
        error! 'Upload not found', 404
      else
        if upload.type === 'image'
          file_path = UploadRepository.get_file_path_medium upload.file_name
          data = File.open(file_path, 'rb').read
        end
        content_type upload.type
        env['api.format'] = :binary
        present data
      end
    end

    post '/:id/resize' do
      upload = UploadRepository.get_by_id params[:id]
      if !upload then
        error! 'Upload not found', 404
      else
        fname = UploadRepository.get_file_path upload.file_name
        maxWidthImage = params[:maxWidthImage]
        maxHeightImage = params[:maxHeightImage]
        maxWidthThumb = params[:maxWidthThumb]
        maxHeightThumb = params[:maxHeightThumb]
        maxWidthMedium = params[:maxWidthMedium]
        maxHeightMedium = params[:maxHeightMedium]
        resizeQuality = params[:resizeQuality]
        ResizeImage.resize(fname, maxWidthImage, maxHeightImage, maxWidthThumb, maxHeightThumb, maxWidthMedium, maxHeightMedium, resizeQuality)
        {
          'status' => 'ok', 
          'maxWidthImage' => maxWidthImage,
          'maxHeightImage' => maxHeightImage,
          'maxWidthThumb' => maxWidthThumb,
          'maxHeightThumb' => maxHeightThumb,
          'maxWidthMedium' => maxWidthMedium,
          'maxHeightMedium' => maxHeightMedium,
          'resizeQuality' => resizeQuality,
          'filename' => fname
        }
      end  
    end  

    post '/add' do
      errors = Array.new
      user_token = params[:usertoken]
      errors << Error.new("user_token", "The userid field is required") if user_token.empty? || user_token == 'undefined'
      title = params[:title]
      errors << Error.new("title", "The title field is required") if title.empty? || title == 'undefined'
      tags_csv = params[:tags]
      errors << Error.new("tags", "At least one tag is required") if tags_csv.empty? || title == 'undefined'
      description = params[:description]
      type = params[:type]
      if params[:type] === 'image'
        if params[:image_file].nil?
          errors << Error.new("image_file", "Image upload is required")
        else
          original_file_name = params[:image_file].filename
          file = params[:image_file]
        end
      end 
      if params[:type] === 'video'
        original_file_name = params[:file]
        file = params[:file]
      end 
      error! JSON.parse(errors.to_json), 403 if errors.length > 0
      user = User.get(user_token)
      error! "Unauthorized", 401 unless user != nil
      if params[:type] === 'image'
        file_name = Time.now.strftime('%Y%m%d%H%M%S%L') + '_' + original_file_name
      end
      if params[:type] === 'video'
        file_name = original_file_name
      end
      upload = Uploadmodel.new type, file_name, original_file_name, user.id, title, description
      upload_id = UploadRepository.save upload
      if params[:type] === 'image'
        UploadRepository.transfer_file file, file_name
      end
      TagHelper.process_tags tags_csv, upload_id, user.id
      upload_id
    end
    
    get '/:type/:mode/:search/:number' do
      type = params[:type]
      if type == 'all' then type = '%%' end
      mode = params[:mode]
      search = params[:search]
      if search == 'all' then search = '' end
      number = params[:number]
      if number == 'all' then number = 300000 end
      case mode
      when "all"
        JSON.parse(UploadRepository.alphabetic(search, number, type).to_json)
      when "popular"
        JSON.parse(UploadRepository.popular(search, number, type).to_json)
      when "recent"
        JSON.parse(UploadRepository.recent(search, number, type).to_json)
      when "random"
        JSON.parse(UploadRepository.random(search, number, type).to_json)
      else
        { "mode" => "Mode not supported. Either: popular or recent." } 
      end
    end
  
  end

end