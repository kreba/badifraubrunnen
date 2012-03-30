require 'RMagick'
include Magick

class AssetGenerator
  def self.create_all_day_images

    digit =        n = Digit.new %w(0 k K)
    n.next_digit = n = Digit.new %w(0 k K)
    n.next_digit = n = Digit.new %w(0 b B)
    n.next_digit = n = Digit.new %w(0 b B)
    n.next_digit = n = Digit.new %w(0 b B)
    n.next_digit = n = Digit.new %w(0 b B)
    # 4x Badi, 2x Kiosk

    colors = {
      '0' => 'transparent',
      'B' => 'rgba( 38, 158, 0, 0.6)',
      'K' => 'rgba(255, 255, 0, 0.6)',
      'b' => 'rgba( 38, 158, 0, 0.3)',
      'k' => 'rgba(255, 255, 0, 0.3)',
#      'b' => '#26269E9E0000',
#      'k' => '#FAFAFAFA0000'
    }

    images = {}
    begin
      images[digit.to_s] = digit.to_img(1, 80, colors)
    end while digit.increment

    target = Dir.new('/tmp/' + 'assets/images/')
    images.each{ |key, img| 
      img.write(target.path + "day_status_#{key}.png") 
    }
  end
end


    class Digit
      attr_accessor :next_digit

      def initialize(states = [])
        @states = states
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
        prefix = next_digit ? next_digit.to_s : ""
        prefix + state
      end

      def to_img(width, height, color_map = {})
        nof_digits = count_digits
        spacer_height = 1
        digit_height = ((height + spacer_height).to_f / nof_digits.to_f).round - spacer_height
        digit_offset = 0

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

        result.flip
      end

      def count_digits
        next_digit ? next_digit.count_digits + 1 : 1
      end
    end
