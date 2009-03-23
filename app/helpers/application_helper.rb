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
end
