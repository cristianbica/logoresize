class LogoresizeController < ApplicationController

  def index
    render :index and return if params[:html].present? or params[:image].blank?
    
    
    initial_format = params[:image].split(".").last
    image = MiniMagick::Image.open params[:image]
    image.format 'png'
    
    #determine the most used color and use it as background
    img = ChunkyPNG::Image.from_file image.path
    bg_color = img.pixels.group_by(&:to_i).map{|k,v|[k,v.size]}.sort_by(&:last).last.first
    bg_color_hex = ChunkyPNG::Color.to_hex(bg_color)
    
    #crop the area with the logo
    min_x = min_y = 10**11
    max_x = max_y = 0
    img.height.times do |y|
      img.width.times do |x|
        if (bg_color-img[x,y]).abs>100
          min_x = [min_x,x].min
          min_y = [min_y,y].min
          max_x = [max_x,x].max
          max_y = [max_y,y].max
        end
      end
    end
    image.crop "#{max_x-min_x+1}x#{max_y-min_y+1}+#{min_x}+#{min_y}"
    
    #set the background
    image.background(bg_color_hex)
    
    #resize the logo using the width/height/padding params
    new_width = params[:width].to_i-params[:padding].to_i*2
    new_height = params[:height].to_i-params[:padding].to_i*2
    image.resize "#{new_width}x#{new_height}"
    
    #resize the image at the requested size
    image.combine_options do |c|
      c.fill bg_color_hex
      c.background bg_color_hex
      c.gravity "center"
      c.extent "#{params[:width]}x#{params[:height]}"
    end
    
    #set the initial format of the file and serve the image
    image.format initial_format
    send_file(image.path, :filename => params[:image].split("/").last, :type => image.mime_type, :disposition => 'inline')

  end

end
















