require 'mdex_client/mdata/node'

module MDEXClient
  module MData
    class Sort < Node
      attr_accessor :key, :direction, :reference_geocode
      
      def initialize_from_element!
        @key = element["Key"]
        @direction = element["Direction"]
        
        rgc = element.xpath("mdata:ReferenceGeocode").first
        @reference_geocode = Geocode.new(rgc) if rgc
      end
      
      def write_xml!(xml)
        xml.mdata :Sort, "Key" => key, "Direction" => direction do |xml|
          if reference_geocode
            xml.mdata :ReferenceGeocode, "Latitude" => reference_geocode.latitude,
              "Longitude" => reference_geocode.longitude
          end
        end
      end
    end
  end
end
