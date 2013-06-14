require 'RMagick'
include Magick

class AssetGenerator
  BADI = 'b'
  KIOSK = 'k'

  COLORS = {
    BADI  + Shift::STATUS_CHARS[:taken]    => 'transparent',
    BADI  + Shift::STATUS_CHARS[:free]     => 'rgba( 38, 158, 0, 0.6)',
    BADI  + Shift::STATUS_CHARS[:disabled] => 'rgba( 38, 158, 0, 0.3)',
    KIOSK + Shift::STATUS_CHARS[:taken]    => 'transparent',
    KIOSK + Shift::STATUS_CHARS[:free]     => 'rgba(255, 255, 0, 0.6)',
    KIOSK + Shift::STATUS_CHARS[:disabled] => 'rgba(255, 255, 0, 0.3)',
  }

  def self.create_all_day_images
    digit =        n = Digit.new( BADI )
    n.next_digit = n = Digit.new( BADI )
    n.next_digit = n = Digit.new( BADI )
    n.next_digit = n = Digit.new( BADI )
    n.next_digit = n = Digit.new( KIOSK )
    n.next_digit = n = Digit.new( KIOSK )

    images = {}
    begin
      images[digit.to_s] = digit.to_img(100, 80, COLORS)
    end while digit.increment

    target_dir = Rails.root.join 'app','assets','images'
    images.each{ |key, img|
      file = File.new( target_dir.join("day_status_#{key}.png"), 'w' )
      img.write(file.path)
      file.close
    }
    
    "Done. Created  #{images.size}  images in  #{target_dir}"
  end
end


class Digit
  attr_accessor :next_digit

  def initialize(saison_char)
    @states = Shift::STATUS_CHARS.values.collect{|state_char| saison_char + state_char}
    @index = 0
  end

  def increment()
    if @index + 1 < @states.size
      @index += 1
      true
    elsif next_digit && next_digit.increment
      @index = 0
      true
    else
      false
    end
  end

  def state
    @states[@index]
  end

  def to_s
    rest = next_digit ? next_digit.to_s : ""
    state + rest
  end

  def to_img(width, height, color_map = {})
    nof_digits = count_digits
    nof_spacers = nof_digits - 1
    spacer_height = 1
    total_spacer_height = nof_spacers * spacer_height
    digit_height = ((height - total_spacer_height).to_f / nof_digits.to_f).floor
    digit_offset = 1

    result = Image.new(width, height) { self.background_color = "transparent" }

    digit = self
    begin
      digit_img = Image.new(width, digit_height) {
        self.background_color = color_map[digit.state]
        self.size = "#{width}x#{digit_height}+0+#{digit_offset}" # superfluous?
      }
      result.composite!(digit_img, 0, digit_offset, Magick::OverCompositeOp)
      digit_offset += digit_height + spacer_height
    end while digit = digit.next_digit

    result
  end

  def count_digits
    next_digit ? next_digit.count_digits + 1 : 1
  end
end
