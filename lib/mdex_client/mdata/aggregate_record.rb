require 'mdex_client/mdata/node'

module MDEXClient
  module MData
    class AggregateRecord < Record
      attr_accessor :derived_properties, :constituent_records, :records_in_aggregate
    
      def initialize_from_element!
        @records_in_aggregate = @element["RecordsInAggregate"].to_i
        @derived_properties = property_list("mdata:DerivedProperties/mdata:Property")
        @constituent_records = record_list("mdata:ConstituentRecords")
      end
    end
  end
end
