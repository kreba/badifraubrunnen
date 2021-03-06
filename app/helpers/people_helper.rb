module PeopleHelper
  require 'net/http'

  def person_select_label( person )
    person_with_brevet(person)
  end

  def person_with_brevet(person)
    label = h person.name
    label << ' [B]' if person.brevet?
    label
  end

  def image_tag_brevet
    image_tag asset_path('brevet.jpg'), class: 'brevet', alt: '[B]', title: 'Hat ein Brevet'
  end

  def render_people_list( title, people )
    render( partial: 'list_people',
            locals: {
              title: title,
              people: people } )
  end

  def self.fetch_location_by_postal_code(zip)
    return nil unless zip.to_s.size == 4
    begin
      timeout(0.5) do
        response = Net::HTTP.get_response("map.search.ch", zip.to_s )
        puts response.to_yaml
        return response.is_a?(Net::HTTPMovedPermanently) ? capitalized_location(response, zip.to_s) : nil
      end
    rescue TimeoutError
      Person.logger.warn("Timeout accessing http://map.search.ch/#{zip.to_s}: '#{$!}'  - Not updating the location field.")
      return nil
    end
  end

  private
  def self.capitalized_location(http_response, exclude="")
    location = http_response['location'].split('/').last # e.g. "bueren-zum-hof"
    if location == "map.search.ch"
      return nil
    else
      parts = location.split('-').reject {|part| part == exclude}
      parts.first.capitalize!
      parts.last.capitalize!
      location = parts.join(' ');                        # e.g. "Bueren zum Hof"
    end
  end

end
