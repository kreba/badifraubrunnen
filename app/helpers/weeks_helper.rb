require 'memoist'

module WeeksHelper

  def phone_str( person, options = {} )
    options.reverse_merge! delimiter: ', '
    [person.phone, person.phone2].compact.reject(&:blank?).join(options[:delimiter]).html_safe
  end
  def day_td( day )
    content_tag(:td,
      link_to( day.date.strftime( "%d.%m." ), day, style: "color:inherit;" ),
      day_td_html_options(day)
    )
  end
  def day_td_html_options( day )
    options = {
      class:       "weeks_table_td",
      onmouseover: "xstooltip_show('#{tooltip_id(day)}', '#{week_html_id(day.week)}', -8, -8);",
      onmouseout:  "xstooltip_hide('#{tooltip_id(day)}');"
    }

    if day.timely_active?
      begin
        options.merge background: image_path(day.status_image_name)
      rescue Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError
        options.merge background: image_path('attention-icon.png')
      end
      # do something with an image_tag instead? (enables browser-side caching)
    else
      options.merge style: "background-color:#dddddd; color:#ffffff;"
    end
  end
  def week_html_id( week )
    "week_#{week.number}"
  end
  def cell_link_to( text, target = {}, padding = "5px 3px" )
      link_to(
        content_tag(:span,
          text, {style: "width: 100%; height: inherit; margin: #{padding};"}),
        target, {style: "width: #{WeekPlanDisplayData::DAY_WIDTH}px; height: inherit; display: table-cell; vertical-align: middle;", class: 'noprint'} )
  end

  class WeekPlanDisplayData
    extend Memoist

    HOUR_HEIGHT   = 30
    HEADER_HEIGHT = 35
    DAY_WIDTH     = 125
    TIME_HEIGHT   = 20  #css: height=17px + border=2*1px
    TIME_WIDTH    = 50 + 5

    attr_accessor :week


    def self.for( week )
      instance = new
      instance.week = week
      return instance
    end

    def day_name( wday )
      I18n.translate('date.abbr_day_names')[wday]
    end
    def h_offset( wday )
      index = (wday - 1) % 7  # Monday..Sunday -> 0..6
      h_offset_day_count(index)
    end
    def h_offset_times
      {
        left:  0,
        right: h_offset_day_count(7)
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
       height:   #{HEADER_HEIGHT + day_height(saison)}px;
       margin:   2em 0em;"
    end
    def style_for_day_header( day )
      "position: absolute;
       left:     #{h_offset(day.date.wday)}px;
       width:    #{DAY_WIDTH}px;
       top:      0px;
       height:   #{HEADER_HEIGHT - 3}px;
       text-align: center;"
    end
    def style_for_day_body( day )
      "position: absolute;
       left:     #{h_offset(day.date.wday)}px;
       width:    #{DAY_WIDTH}px;
       top:      #{HEADER_HEIGHT}px; "
    end
    def style_for_shift( shift )
      si = shift.shiftinfo
      v_offset = v_offset_begin(si)

      top    = v_offset                    - 1 #border
      height = time2pixels(shift.duration) - 1 #border
      bg_color = shift.free? ? shift.saison.color : "#eeeeee"

      "top:        #{top}px;
       height:     #{height}px;
       background: #{bg_color};"
    end


    def times( saison, side )
      shifts_by(saison, side).map do |shift|
        si = shift.shiftinfo
        begin_top  = HEADER_HEIGHT + v_offset_begin(si) - 1
        end_top    = HEADER_HEIGHT + v_offset_end(si) - TIME_HEIGHT
        [si.begin, begin_top, si.end, end_top]
      end
    end
    def shifts_by( saison, side )
      day = case side
            when :left  then week.days.first
            when :right then week.days.last
            else raise('No such side. Use :left or :right.')
            end
      day.find_shifts_by_saison(saison)
    end
    memoize :times, :shifts_by

    def day_height( saison )
      shiftinfos = Shiftinfo.for_week_and_saison(week, saison)
      min = earliest_second(shiftinfos)
      max = latest_second(shiftinfos)
      time2pixels(max - min)
    end
    memoize :day_height


    # Disable the default constructor.
    private_class_method :new

    private

    def time2pixels( seconds )
      (HOUR_HEIGHT * seconds.to_f/1.hour.to_f).round
    end

    def h_offset_day_count( number_of_days )
      TIME_WIDTH + number_of_days * (DAY_WIDTH + 5)
    end
    memoize :h_offset_day_count

    def v_offset_begin( shiftinfo )
      v_offset(shiftinfo.saison, shiftinfo.begin_plus_offset)
    end
    def v_offset_end( shiftinfo )
      v_offset(shiftinfo.saison, shiftinfo.end_plus_offset)
    end
    def v_offset( saison, time_in_seconds )
      shiftinfos = Shiftinfo.for_week_and_saison(week, saison)
      time2pixels(time_in_seconds - earliest_second(shiftinfos))
    end

    def earliest_second(shiftinfos)
      shiftinfos.map(&:begin_plus_offset).min
    end
    def latest_second(shiftinfos)
      shiftinfos.map(&:end_plus_offset).max
    end
    memoize :earliest_second, :latest_second

  end
end
