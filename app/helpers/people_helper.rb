module PeopleHelper

  def self.fetch_location_by_postal_code(zip)
    return nil unless zip.to_s.size == 4
    begin
      timeout(0.5) do
        response = Net::HTTP.get_response("map.search.ch", zip.to_s )
        return response.is_a?(Net::HTTPMovedPermanently) ? capitalized_location(response,zip.to_s) : nil
      end
    rescue TimeoutError
      Person.logger.warn("Timeout accessing http://map.search.ch/#{zip.to_s}: '#{$!}'  - Not updating the location field.")
      return nil
    end
  end

  private
  
    def self.capitalized_location(http_response, exclude="")
      location = http_response['location'].split('/').last  # e.g. "bueren-zum-hof"
      if location == "map.search.ch"
        return nil
      else  
        parts = location.split('-').reject {|part| part == exclude}
        parts.first.capitalize!
        parts.last.capitalize!
        location = parts.join(' ');                         # e.g. "Bueren zum Hof"
      end
    end

end