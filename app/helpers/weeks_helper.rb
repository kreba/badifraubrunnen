module WeeksHelper

  def phone_str( person, options = {} )
    options.reverse_merge! :delimiter => ', '
    [person.phone, person.phone2].compact.reject(&:empty?).join(options[:delimiter]).html_safe
  end
  def day_td( day )
    content_tag(:td,
      link_to( day.date.strftime( "%d.%m." ), day,
               :style => "color:inherit;" ),
      self.day_td_html_options(day)
    )
  end
  def day_td_html_options( day )
    options = {
      :class       => "weeks_table_td",
#      :title       => text_tooltip_for(day)
      :onmouseover => "xstooltip_show('#{tooltip_id(day)}', '#{week_html_id(day.week)}', -8, -8);",
      :onmouseout  => "xstooltip_hide('#{tooltip_id(day)}');"
# the html tooltips appear and look nice, but they don't disappear any more!
    }

    if day.active?
      options.merge :background => images_url + day.status_image_name
      # do something with an image_tag instead? (enables browser-side caching)
    else
      options.merge :style => "background-color:#dddddd; color:#ffffff;"
    end
  end
  def week_html_id( week )
    "week_#{week.number}"
  end
  class WeekPlanDisplayData
    extend ActiveSupport::Memoizable ## TODO: deprecated. 
    # DEPRECATION WARNING: ActiveSupport::Memoizable is deprecated and will be removed in future releases,simply use Ruby memoization pattern instead.

    @@hour_height   = 24
    @@header_height = 35
    @@day_width     = 125
    @@time_height   = 20  #css: height=17px + 2*border=2px
    @@time_width    = 50 + 5
    
    attr_accessor :week


    def self.for( week )
      instance = self.new
      instance.week = week
      return instance
    end
    
    def day_name( wday )
      I18n.translate('date.abbr_day_names')[wday]
    end
    def h_offset( wday )
      index = (wday - 1) % 7  # Monday..Sunday -> 0..6
      self.h_offset_day_count(index)
    end
    def h_offset_times
      {
        :left  => 0,
        :right => h_offset_day_count(7)
      }
    end
    memoize :day_name, :h_offset, :h_offset_times

    def style_for_wnum
      "float:       left;
       font-size:   75px;
       line-height:  1em;
       margin:      -8px 16px 3px 3px;"
    end
    def style_for_day( saison )
      "position: relative; 
       height:   #{@@header_height + self.day_height(saison)}px;
       margin:   2em 0em;"
    end
    def style_for_day_header( day )
      "position: absolute; 
       left:     #{self.h_offset(day.date.wday)}px;
       width:    #{@@day_width}px;
       top:      0px;
       height:   #{@@header_height - 3}px;
       text-align: center;"
    end
    def style_for_day_body( day )
      "position: absolute; 
       left:     #{self.h_offset(day.date.wday)}px;
       width:    #{@@day_width}px;
       top:      #{@@header_height}px; "
    end
    def style_for_shift( shift )
      si = shift.shiftinfo
      v_offset = self.v_offset(si.description, si.begin)

      top    = v_offset                         - 1 #border
      height = self.time2pixels(shift.duration) - 1 #border
      bg_color = shift.free? ? shift.saison.color : "#eeeeee"

      "top:        #{top}px;
       height:     #{height}px;
       background: #{bg_color};"
    end


    def begin_times( saison, side )
      begin_times = (self.toptops(saison, side).reject {|time, top| self.toptops(saison, side).values.detect {|x| x - top > 0 and x - top < @@time_height } }).keys
      return begin_times.reject {|t| self.end_times(saison, side).detect {|x| x - t > 0 and x - t < @@time_height} }
    end
    def end_times( saison, side )
      end_times = (self.endtops(saison, side).reject {|time, top| self.endtops(saison, side).values.detect {|x| top - x > 0 and top - x < @@time_height } }).keys
      return end_times
    end
    def toptops( saison, side )
      toptops = {}
      self.shifts_by(saison, side).each {|shift|
          si = shift.shiftinfo
          toptops[si.begin] ||= @@header_height + self.v_offset(si.description, si.begin)
        } 
      toptops
    end
    def endtops( saison, side )
      endtops = {}
        self.shifts_by(saison, side).each{ |shift|
          si = shift.shiftinfo
          endtops[si.end] ||= @@header_height + self.v_offset(si.description, si.end) - @@time_height
        }
      endtops
    end
    def shifts_by( saison, side )
      day = side == :left ? self.week.days.first : (side == :right ? self.week.days.last : raise('no such side'))
      day.find_shifts_by_saison(saison)
    end
    memoize :begin_times, :end_times, :toptops, :endtops, :shifts_by

    protected
    def day_height( saison )
      case saison.name
      when "badi"
        17.5 * @@hour_height
      when "kiosk"
        10 * @@hour_height
      end
    end
    def h_offset_day_count( number_of_days )
      @@time_width + number_of_days * (@@day_width + 5)
    end
    def v_offset( shiftinfo_description , time )
      time_offset = self.time2pixels(time.seconds_since_midnight)
      pikett_offset = shiftinfo_description.eql?("Pikett") ? -0.5*@@hour_height : -9.5*@@hour_height
      time_offset + pikett_offset
    end
    def time2pixels( seconds )
      (@@hour_height * seconds.to_f/1.hour.to_f).round
    end
    memoize :day_height, :h_offset_day_count, :v_offset
    private  # disable the default constructor
    def self.new
      super
    end
  end
end
