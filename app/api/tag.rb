require 'grape'
require 'json'
require 'rack/contrib'

require_relative './../model/tag'
require_relative './../repository/tag_repository'
require_relative './../repository/tag_upload_repository'
require_relative './../helpers/tag_helper'
require_relative './../helpers/tag_cloud'

module SocialChallenges

  class TagAPI < Grape::API

    use Rack::JSONP
    format :json
    
    get '/end/:type/:tagName/:previousId' do
      previousObject = UploadRepository.get_by_id params[:previousId]
      randomTag = TagRepository.random_not_current(params[:tagName], params[:type])
      nextObject = TagUploadRepository.get_random_object_bytagname randomTag[0][2], Array[-1], params[:type]
      if nextObject == false then 
        JSON.parse(Tag.returnJSONPreviousRandomTag(previousObject, randomTag[0][2]))  
      else
        JSON.parse(Tag.returnJSONPreviousRandomTagWithNext(previousObject, randomTag[0][2], nextObject)) 
      end
    end

    get '/start/:type' do
      randomTag = TagRepository.random_start(params[:type])
      { "random_tag" => randomTag[0][2]}     
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
        JSON.parse(TagCloud.tag_cloud(TagRepository.alphabetic(search, number, type)))
      when "popular"
        JSON.parse(TagCloud.tag_cloud(TagRepository.popular(search, number, type)))
      when "recent"
        JSON.parse(TagCloud.tag_cloud(TagRepository.recent(search, number, type)))
      when "random"
        JSON.parse(TagCloud.tag_cloud(TagRepository.random(search, number, type)))
      else
        { "mode" => "Mode not supported. Either: popular or recent." } 
      end
    end
    
    get '/:type/all' do
      JSON.parse(TagCloud.tag_cloud(TagRepository.all(params[:type])))
    end

    post '/add' do
      tagName = params[:tagName]
      userid = params[:userId]
      tag = Tag.new tagName, userid
      TagRepository.save tag
    end
    
    post '/add/:objectId' do      
      objectId = params[:objectId]
      tags = params[:tags]
      userid = params[:userId]
      
      tagArray = tags.split(" ")
      tagArray.each { |tag| 
        tagId = TagHelper.find_or_add_tag(tag, userid)
        TagRepository.tagObject objectId, tagId
      }
    end
    
    post '/:type/:tagName/:currentId/:previousId' do
      
      idstoignore = params[:ignoreIds]
      if params[:ignoreIds] == "" then
        idstoignore = Array[-1]
      else
        idstoignore = params[:ignoreIds].split(',').map { |s| s.to_i }
      end
      currentObject = UploadRepository.get_by_id params[:currentId]
      idstoignore.push(currentObject.id)
      previousObject = UploadRepository.get_by_id params[:previousId]
      idstoignore.push(previousObject.id)
      nextObject = TagUploadRepository.get_random_object_bytagname params[:tagName], idstoignore, params[:type]
      if !currentObject then
        error! 'Upload not found', 404
      else
        if currentObject.id == previousObject.id then
          if nextObject == false then 
            JSON.parse(Tag.returnJSONNoPreviousNoNext(currentObject))
          else
            JSON.parse(Tag.returnJSONNoPrevious(currentObject, nextObject))
          end
        elsif nextObject == false then
          JSON.parse(Tag.returnJSONNoNext(currentObject, previousObject))  
        else
          JSON.parse(Tag.returnJSON(currentObject, previousObject, nextObject))
        end 
      end 
    end    
    
    post '/:type/:tagName' do
      puts '***********'
      
      idstoignore = params[:ignoreIds]
      if params[:ignoreIds] == "" then
        idstoignore = Array[-1]
      else
        idstoignore = params[:ignoreIds].split(',').map { |s| s.to_i }
      end
      
      currentObject = TagUploadRepository.get_random_object_bytagname params[:tagName], idstoignore, params[:type]
      if currentObject == false then
        currentObject = TagUploadRepository.get_random_object_bytagname params[:tagName], Array[-1], params[:type]
      end
      idstoignore.push(currentObject.id) 
      nextObject = TagUploadRepository.get_random_object_bytagname params[:tagName], idstoignore, params[:type]
      if !currentObject then
        error! 'Upload not found', 404
      else
        if nextObject == false then
          JSON.parse(Tag.returnJSONNoPreviousNoNext(currentObject))  
        else
          JSON.parse(Tag.returnJSONNoPrevious(currentObject, nextObject))
        end
      end
    end

  end

end