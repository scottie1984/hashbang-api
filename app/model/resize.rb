require 'RMagick'
require 'aws-sdk'
require 'open-uri'
require 'yaml'

module SocialChallenges

	class ResizeImage

		attr_reader :fname, :maxWidthImage, :maxHeightImage, :maxWidthThumb, :maxHeightThumb, :maxWidthMedium, :maxHeightMedium, :resizeQuality
    
    CONFIG = YAML.load_file("./config/config.yml") unless defined? CONFIG

		def initialize(fname, maxWidthImage, maxHeightImage, maxWidthThumb, maxHeightThumb, maxWidthMedium, maxHeightMedium, resizeQuality)
			@fname= fname
			@maxWidthImage = maxWidthImage
			@maxHeightImage = maxHeightImage
			@maxWidthThumb = maxWidthThumb
			@maxHeightThumb = maxHeightThumb
			@maxWidthMedium = maxWidthMedium
			@maxHeightMedium = maxHeightMedium
			@resizeQuality = resizeQuality
		end

		def self.resize(fname, maxWidthImage, maxHeightImage, maxWidthThumb, maxHeightThumb, maxWidthMedium, maxHeightMedium, resizeQuality)
		newFileResized = fname
		newFileResizedThumb = fname[/[^.]+/]+'_thumb.jpg'
		newFileResizedMedium = fname[/[^.]+/]+'_medium.jpg'
    
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
    key = File.basename(newFileResized)
    key_thumb = File.basename(newFileResizedThumb)
    key_medium = File.basename(newFileResizedMedium)
    
    
      file = open(URI::encode("#{CONFIG['backend_url']}/#{fname}"),:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
    
      #s3.buckets[bucket_name].objects[file_name].write(:file => file.tempfile.path)
      #puts "Uploading file #{file_name} to bucket #{bucket_name}."
    
		  #path = 'uploads/'
      image = Magick::ImageList.new	
		  img = image.from_blob(file)
		  width = img.columns
			if width > maxWidthImage.to_i 
				  s3.buckets[bucket_name].objects[key].write(:file => StringIO.open(image.from_blob(file).resize_to_fit(maxWidthImage.to_i , maxHeightImage.to_i ){|f| f.quality = resizeQuality.to_i}.to_blob))
				  s3.buckets[bucket_name].objects[key_medium].write(:file => StringIO.open(image.from_blob(file).resize_to_fill(maxWidthMedium.to_i , maxHeightMedium.to_i , Magick::CenterGravity){|f| f.quality = resizeQuality.to_i}.to_blob))
				  s3.buckets[bucket_name].objects[key_thumb].write(:file => StringIO.open(image.from_blob(file).resize_to_fill(maxWidthThumb.to_i , maxHeightThumb.to_i , Magick::CenterGravity){|f| f.quality = resizeQuality.to_i}.to_blob))
			  else
				  s3.buckets[bucket_name].objects[key_medium].write(:file => StringIO.open(image.from_blob(file).resize_to_fill(maxWidthMedium.to_i , maxHeightMedium.to_i , Magick::CenterGravity){|f| f.quality = resizeQuality.to_i}.to_blob))
				  s3.buckets[bucket_name].objects[key_thumb].write(:file => StringIO.open(image.from_blob(file).resize_to_fill(maxWidthThumb.to_i , maxHeightThumb.to_i , Magick::CenterGravity){|f| f.quality = resizeQuality.to_i}.to_blob))
			end
    end
	end
end