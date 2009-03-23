module DaysHelper
  def sample_image
    require 'RMagick'
    
    # Demonstrate the GradientFill class
    
    rows = 100
    cols = 300
    
    start_color = "#900"
    end_color = "#000"
    
    fill = Magick::GradientFill.new(0, 0, 0, rows, start_color, end_color)
    img = Magick::Image.new(cols, rows, fill);
    
    # Annotate the filled image with the code that created the fill.
    
    ann = Magick::Draw.new
    ann.annotate(img, 0,0,0,0, "GradientFill.new(0, 0, 0, #{rows}, '#{start_color}', '#{end_color}')") {
        self.gravity = Magick::CenterGravity
        self.fill = 'white'
        self.stroke = 'transparent'
        self.pointsize = 14
        }
    
    #img.display
    img.write("/images/gradientfill.gif")
    #exit
  end
end
