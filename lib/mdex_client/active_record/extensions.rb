module MDEXClient
  module ActiveRecord
    module Searchable
      extend ActiveSupport::Concern
      
      module ClassMethods
        def mdex_field_mapping=(mapping)
          @@mdex_field_mapping = mapping
        end
        
        def mdex_field_mapping
          @@mdex_field_mapping ||= { "id" => "id" }
        end
        
        def mdex_additional_record_attributes=(attributes)
          @@mdex_additional_record_attributes = Set.new(attributes)
        end
        
        def mdex_additional_record_attributes
          @@mdex_additional_record_attributes ||= Set.new
        end
        
        def mdex_client=(client)
          @@mdex_client = client
        end
        
        def mdex_client
          @@mdex_client
        end
        
        def mdex_included_record_attributes
          mdex_additional_record_attributes | mdex_field_mapping.keys
        end
        
        def new_from_record(record)
          obj = new
          obj.mdex_attributes = record.attributes
          obj
        end

        def mdex_navigation_query(params={})
          query = MDEXClient::MData::NavigationQuery.new(params)
          query.included_record_attributes = mdex_included_record_attributes
          query.expose_all_refinements = true
          
          return query
        end
        
        def mdex_find(params={})
          query = mdex_navigation_query(params)
          result = mdex_client.navigation_query(query)
          shim_objects = result.records.collect { |record| new_from_record(record) }
          
          return query, result, shim_objects
        end
      end
      
      module InstanceMethods
        def mdex_attributes=(attributes)
          mapping = self.class.mdex_field_mapping
          unmapped_attributes = self.class.mdex_additional_record_attributes
          
          attributes.each do |key, value|
            next if unmapped_attributes.include? key
            
            unless mapping[key]
              logger.warn "No MDEX field mapping for #{key} in #{self.class.name}, skipping"
              next
            end
            
            send("#{mapping[key]}=", value)
          end
        end
      end
    end
  end
end
