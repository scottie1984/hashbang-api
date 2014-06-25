#resize demo
require 'rmagick'

fname = '../../spec/uploads/cat.jpg'
newFileLarge = '../../spec/uploads/resize_large.jpg'
newFileMedium = '../../spec/uploads/resize_medium.jpg'
newFileThumb = '../../spec/uploads/resize_thumb.jpg'
newFileCropped = '../../spec/uploads/cropped.jpg'

Magick::Image::read(fname)[0].resize_to_fit(1200, 1200).write(newFileLarge){|f| f.quality = 0.7 }
Magick::Image::read(fname)[0].resize_to_fit(600, 600).write(newFileMedium){|f| f.quality = 0.7 }
Magick::Image::read(fname)[0].resize_to_fill(125, 125, Magick::CenterGravity).write(newFileThumb){|f| f.quality = 0.7 }

#get some details about the image
img = Magick::Image.read(fname).first
width = img.columns
height = img.rows
size = img.filesize
quality = img.quality
resolution = img.x_resolution

#print out details
puts "
	width = #{width}
	height = #{height}
	size = #{size}
	quality = #{quality}
	resolution = #{resolution}
	"

#crop thumbnail demo
x = 358
y = 91
cropWidth = 40
cropHeight = 40
scaleW = 555
scaleH = 416
thumbnailSize = 150
ratio = thumbnailSize.to_f / cropWidth.to_f 

#correct ratio to thumbnailSize
x *= ratio.to_f
y *= ratio.to_f
cropWidth *= ratio.to_f
cropHeight *= ratio.to_f
scaleW *= ratio.to_f
scaleH *= ratio.to_f

#do it
Magick::Image::read(fname)[0].resize(scaleW, scaleH).crop(x, y, cropWidth, cropHeight).write(newFileCropped){|f| f.quality = 0.7 }

#resize all in dir
#Dir.glob("*.*") do |fname|
#   Magick::Image.read(fname)[0].resize_to_fill(120, 90, Magick::CenterGravity).write("#{fname.split(".")[0]}_thumb.jpg")
#end 