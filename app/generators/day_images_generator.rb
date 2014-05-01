class DayImagesGenerator



  # DO NOT USE THIS METHOD. IT IS NOT WORKING CORRECTLY.
  def self.create_all_status_images
    existing_shift_combinations = Day.includes(:shifts => [:day, :shiftinfo => :saison] )
                                     .map{ |day| sorted_for_status_image(day.shifts) }
                                     .uniq{ |shifts| shifts.map(&:shiftinfo).map(&:saison_id) }
    existing_shift_combinations.each do |shifts|
      ShiftStatusVariations.new(shifts).each do |status_variation|
        create_status_image(status_variation)
      end
    end
    'Done.'
  end

  def self.create_status_image( shifts )
    img_path = Rails.root + 'app/assets/images/' + status_image_name(shifts)
    if File.exists?(img_path)
      p 'EXISTS ' + img_path.to_s
    else
      p 'CREATE ' + img_path.to_s
      create_status_image_stacked(shifts).write(img_path)
    end
  end

  def self.status_image_name( shifts )
    combined_status_str = sorted_for_status_image(shifts).collect(&:status_str).join
    "day_status_#{combined_status_str}.png"
  end

  # shift.free?        (shift.person_id)
  # shift.disabled?    (shift.enabled)
  # shift.saison.color
  def self.create_status_image_stacked( shifts )
    img_width, img_height = 1, 80  # synchronize height with css!
    result = Magick::Image.new(img_width, img_height) { background_color = 'transparent' }
    return result if shifts.none?

    shift_height = (img_height.to_f / shifts.count.to_f).round
    shift_offset = 1
    sorted_for_status_image(shifts).each{ |shift|
      src = Magick::Image.new(img_width, shift_height - 1) {
        background_color = shift.free? ? shift.saison.color : 'transparent'
        size = "#{img_width}x#{shift_height}+0+#{shift_offset}"
      }
      if shift.disabled?
        src = src.modulate(1.5, 0.5, 0.95)  # brightness, saturation, hue
      end
      result.composite!(src, 0, shift_offset, Magick::OverCompositeOp)
      shift_offset += shift_height
    }

    result
  end


  private

  def self.sorted_for_status_image(shifts)
    shifts.sort_by{ |s| [s.shiftinfo.saison_id, s.shiftinfo.begin_plus_offset] }
  end


  class StatusFaker < DelegateClass(Shift)
    def initialize(previous_shift, shift)
      super(shift)
      @status_index = 0
      __getobj__.person_id = (@status_index == 0) ? 42 : nil
      __getobj__.enabled = @status_index != 1

      @previous_shift = previous_shift
    end
    def increment!
      @status_index += 1
      __getobj__.person_id = (@status_index == 0) ? 42 : nil
      __getobj__.enabled = @status_index != 1

      if @status_index == Shift::STATUS_CHARS.size
        @status_index = 0
        __getobj__.person_id = (@status_index == 0) ? 42 : nil
        __getobj__.enabled = @status_index != 1

        @previous_shift && @previous_shift.increment!
      else
        true
      end
    end
    def to_s
      @previous_shift.to_s + status_char
    end
  end

  class ShiftStatusVariations
    def initialize(shifts)
      previous = nil
      @shifts = shifts.map{ |shift| previous = StatusFaker.new(previous, shift) }
    end
    def each
      begin
        yield @shifts
      end while @shifts.last.increment!
    end
  end

end
