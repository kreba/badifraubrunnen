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
    img.write(RAILS_ROOT+"/images/gradientfill.gif")
    #exit
  end

  def tooltip_div( day )
    content_tag(:div, html_tooltip_for(day), :id => tooltip_id(day),
      :class => "xstooltip", :style => "margin: 0px; padding: 0px;")
  end
  def tooltip_id( day )
    "tooltip_#{day.date_str("%Y-%m-%d")}"
  end
  def html_tooltip_for( day )
    all_shifts = day.shifts.group_by(&:saison)
    all_shifts.keys.sort.collect{ |saison|
      content_tag(:div, :style => "padding: 3px; background-color: #{saison.color};" ) do
        content_tag(:strong, I18n.t("saisons.#{saison.name}")) + "<br />" +
        (day.enabled?(saison) ? 
          html_tooltip_shifts(all_shifts[saison]) : 
          content_tag(:em) { current_person.is_admin_for?(saison) ?
            I18n.t("shifts.no_sign_up_admin") :
            I18n.t("shifts.no_sign_up")
          }
        )
      end
    }.join
  end
  def text_tooltip_for( day )
    day.shifts.group_by(&:saison).collect{ |saison, shifts|
      I18n.t("saisons.#{saison.name}") + ": " +
        shifts.sort_by{ |s| s.shiftinfo.begin }.collect{ |shift|
          " #{shift.shiftinfo.description}: #{shift.free? ? 'frei' : shift.person.name}"
        }.join(' / ')
    }.join(' ||| ')
  end

  protected
  def html_tooltip_shifts( shifts )
    content_tag(:table) do
      shifts.sort_by{ |s| s.shiftinfo.begin }.collect{ |shift|
        content_tag(:tr) {
          content_tag(:td, shift.shiftinfo.description.first + ":" ) +
          content_tag(:td) { shift.free? ?
              (current_person.is_staff_for?(shift.saison) ? 'frei' : 'vakant') :
              shift.person.name
          }
        }
      }.join
    end
  end
  
end
