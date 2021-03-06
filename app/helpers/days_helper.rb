module DaysHelper
  def sample_image
    require 'RMagick'

    # Demonstrate the GradientFill class # TODO: that does not belong here

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
    img.write(Rails.root+"app/assets/images/gradientfill.gif")
    #exit
  end

  def tooltip_div( day )
    tag.div(html_tooltip_for(day), id: tooltip_id(day),
      class: "xstooltip", style: "margin: 0px; padding: 0px;")
  end
  def tooltip_id( day )
    "tooltip_#{day.date_str("%Y-%m-%d")}"
  end
  def html_tooltip_for( day )
    all_shifts = day.shifts.sort_by{ |s| s.shiftinfo.begin_plus_offset }.group_by(&:saison)
    all_shifts.keys.sort.collect{ |saison|
      tag.div(style: "padding: 3px; background-color: #{saison.color};" ) do
        tag.strong(I18n.t("saisons.#{saison.name}")) + "<br />".html_safe +
        (day.enabled?(saison) ?
          html_tooltip_shifts(all_shifts[saison]) :
          tag.em { current_person.is_admin_for?(saison) ?
            I18n.t("shifts.no_sign_up_admin").html_safe :
            I18n.t("shifts.no_sign_up").html_safe
          }
        )
      end
    }.join.html_safe
  end
  def text_tooltip_for( day )
    day.shifts.sort_by{ |s| s.shiftinfo.begin_plus_offset }.group_by(&:saison).collect{ |saison, shifts|
      I18n.t("saisons.#{saison.name}") + ": " +
        shifts.sort_by{ |s| s.shiftinfo.begin }.collect{ |shift|
          " #{shift.shiftinfo.description}: #{shift.free? ? 'frei' : h(shift.person.name)}"
        }.join(' / ')
    }.join(' ||| ')
  end

  protected
  def html_tooltip_shifts( shifts )
    tag.table do
      shifts.collect{ |shift|
        tag.tr {
          tag.td( shift.shiftinfo.description.chars.first + ":" ) +
          tag.td { shift.free? ?
              (current_person.is_staff_for?(shift.saison) ? 'frei' : 'vakant') :
              person_with_brevet(shift.person)
          }
        }
      }.join.html_safe
    end
  end

end
