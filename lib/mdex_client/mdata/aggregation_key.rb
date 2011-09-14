require 'mdex_client/mdata/node'

module MDEXClient
  module MData
    class AggregationKey < Node
      attr_accessor :name, :records_per_aggregate_record
      
      def initialize_from_element!
        @name = element.text
        @records_per_aggregate_record = element["RecordsPerAggregateRecord"].to_i
      end
      
      def write_xml!(xml)
        xml.mdata :AggregationKey, "RecordsPerAggregateRecord" => records_per_aggregate_record,
          name
      end
    end
  end
end
