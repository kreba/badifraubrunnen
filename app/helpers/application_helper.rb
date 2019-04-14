# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def navigation_link(title, path, **opts)
    tag.li( link_to(title, path, opts) )
#      options[:prefix].to_s + link_to(title, path) + options[:postfix].to_s
  end
  def navigation_link_unless_current(title, path)
      tag.li( link_to_unless_current(title, path) )
  end
  def render_saison_links( dynamic_links, ul_tags = {} )
    tag.ul(
      (navigation_link_unless_current( t('weeks.index.title'), weeks_path ) +
      dynamic_links.to_s),
      ul_tags
    )
  end
end
