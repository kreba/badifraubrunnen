require 'memoist'

module WeeksHelper

  def phone_str( person, options = {} )
    options.reverse_merge! delimiter: ', '
    [person.phone, person.phone2].compact.reject(&:blank?).join(options[:delimiter]).html_safe
  end
  def day_td( day )
    tag.td(
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
      options.merge style: "background: #{DayStyle.status_background(day.shifts)}, #eeeeee;"
    else
      options.merge style: "background: #e0e0e0; color: #ffffff;"
    end
  end
  def week_html_id( week )
    "week_#{week.number}"
  end
  def cell_link_to( text, target = {}, padding = "5px 3px" )
      link_to(
        tag.span(text, {style: "width: 100%; height: inherit; margin: #{padding};"}),
        target, {style: "width: #{WeekPlanDisplayData::DAY_WIDTH}px; height: inherit; display: table-cell; vertical-align: middle;", class: 'noprint'} )
  end


  class DayStyle

    def self.status_background( shifts )
      if shifts.any?
        colors = sorted_for_status_image(shifts).map{ |s| color_for_shift(s) }
        status_background_gradient(colors)
      else
        'none'
      end
    end

    def self.status_background_gradient( colors )
      target_height_px = 80
      target_gap_height_px = 1

      gap_height = 100.0 * target_gap_height_px / target_height_px
      remaining_height = 100.0 - (colors.length - 1) * gap_height
      bar_height = remaining_height / colors.length

      segments = []

      pos = 0.0
      colors.each.with_index do |color, idx|
        pos0 = pos
        pos1 = pos + bar_height
        pos2 = pos + bar_height + gap_height
        pos = pos2

        bar_from_to = [color, pos0, pos1]
        segments << bar_from_to

        unless idx == colors.length - 1
          gap_from_to = ['transparent', pos1, pos2]
          segments << gap_from_to
        end
      end

      segments = segments.reduce([]) do |segments_dedup, s2|
        if segments_dedup.none?
          [s2]
        else
          s1 = segments_dedup.pop
          color1, from1, _to1 = s1
          color2, _from2, to2 = s2
          if color1 == color2
            segments_dedup << [color1, from1, to2]
          else
            segments_dedup << s1 << s2
          end
        end
      end

      segments = segments.flat_map{ |(color, posA, posB)| [[color, posA], [color, posB]] }
      segments = segments[1..-2] if segments.length > 2

      "linear-gradient(to bottom, #{segments.map{ |s| '%s %.1f%%' % s }.join(", ")})"
    end

    def self.color_for_shift(shift)
      case [shift.saison.name, shift.status]
      when [Saison.badi.name,  :taken   ] then 'transparent'
      when [Saison.badi.name,  :free    ] then 'rgba( 38, 158, 0, 0.6)'
      when [Saison.badi.name,  :disabled] then 'rgba( 38, 158, 0, 0.3)'
      when [Saison.kiosk.name, :taken   ] then 'transparent'
      when [Saison.kiosk.name, :free    ] then 'rgba(255, 255, 0, 0.6)'
      when [Saison.kiosk.name, :disabled] then 'rgba(255, 255, 0, 0.3)'
      else 'red'
      end
    end

    def self.sorted_for_status_image(shifts)
      shifts.sort_by{ |s| [s.shiftinfo.saison_id, s.shiftinfo.begin_plus_offset] }
    end

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

    def h_offset( cwday )
      index = cwday - 1  # Monday..Sunday -> 0..6
      h_offset_day_count(index)
    end
    def h_offset_times
      {
        left:  0,
        right: h_offset_day_count(7)
      }
    end
    memoize :h_offset, :h_offset_times

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
       left:     #{h_offset(day.date.cwday)}px;
       width:    #{DAY_WIDTH}px;
       top:      0px;
       height:   #{HEADER_HEIGHT - 3}px;
       text-align: center;"
    end
    def style_for_day_body( day )
      "position: absolute;
       left:     #{h_offset(day.date.cwday)}px;
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
