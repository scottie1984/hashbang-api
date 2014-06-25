require 'rmagick'

module SocialChallenges

	class ResizeImage

		attr_reader :fname, :maxWidthImage, :maxHeightImage, :maxWidthThumb, :maxHeightThumb, :maxWidthMedium, :maxHeightMedium, :resizeQuality

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
		#path = 'uploads/'	
		img = Magick::Image.read(fname).first
		width = img.columns
			if width > maxWidthImage.to_i 
				Magick::Image::read(fname)[0].resize_to_fit(maxWidthImage.to_i , maxHeightImage.to_i ).write(newFileResized){|f| f.quality = resizeQuality.to_i}
				Magick::Image::read(fname)[0].resize_to_fill(maxWidthMedium.to_i , maxHeightMedium.to_i , Magick::CenterGravity).write(newFileResizedMedium){|f| f.quality = resizeQuality.to_i}
				Magick::Image::read(fname)[0].resize_to_fill(maxWidthThumb.to_i , maxHeightThumb.to_i , Magick::CenterGravity).write(newFileResizedThumb){|f| f.quality = resizeQuality.to_i}
			else
				Magick::Image::read(fname)[0].resize_to_fill(maxWidthMedium.to_i , maxHeightMedium.to_i , Magick::CenterGravity).write(newFileResizedMedium){|f| f.quality = resizeQuality.to_i}
				Magick::Image::read(fname)[0].resize_to_fill(maxWidthThumb.to_i , maxHeightThumb.to_i , Magick::CenterGravity).write(newFileResizedThumb){|f| f.quality = resizeQuality.to_i}
			end
		end
	end
end