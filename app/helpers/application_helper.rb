# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def block_link_to( text, target = {}, padding = "0px" )
    content_tag(:span, 
      link_to( 
        content_tag(:span, 
           text, {:style => "width: inherit; height: inherit; margin: #{padding};"}),  #TODO: get rid of the offset
        target,  {:style => "width: inherit; height: inherit; display: block;"} ), 
      { :style =>           "width: inherit; height: inherit; padding: 0px" } ) 
      #html_options.merge({:style => (html_options[:style] || "")+"padding: 0px"}) )
  end
  def navigation_link(title, path)
    content_tag(:li, link_to(title, path) )
#      options[:prefix].to_s + link_to(title, path) + options[:postfix].to_s
  end
  def navigation_link_unless_current(title, path)
      content_tag(:li, link_to_unless_current(title, path) )
  end
  def render_saison_links( dynamic_links, ul_tags = {} )
    content_tag(:ul,
      (navigation_link_unless_current( t('weeks.index.title'), weeks_path ) +
      dynamic_links.to_s),
      ul_tags
    )
  end

  def images_url
    "#{Rails.configuration.action_controller.relative_url_root}/images/"
  end
end
