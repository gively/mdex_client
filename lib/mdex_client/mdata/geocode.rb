require 'mdex_client/mdata/node'

module MDEXClient
  module MData
    class Geocode < Node
      attr_accessor :latitude, :longitude
      
      def initialize_from_element!
        @latitude = element["Latitude"].to_f
        @longitude = element["Longitude"].to_f
      end
    end
  end
end
