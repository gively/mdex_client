require 'mdex_client/mdata/node'
require 'mdex_client/mdata/geocode'

module MDEXClient
  module MData
    class RangeFilter < Node
    	class UnknownFilterType < Exception
    		attr_accessor :filter_type
    		
    		def initialize(filter_type)
    			@filter_type = filter_type
    			super("Unknown filter type: #{filter_type}")
    		end
    	end
    
    	attr_accessor :attribute
    	
    	def initialize_from_element!
    		@attribute = element["Attribute"]
    	end
    	
    	def attribute_attr
    		{ "Attribute" => @attribute }
    	end
    	
    	def self.from_element(element)
    		case element.name
    		when "LessThanFilter"
    			LessThanFilter.new(element)
  			when "LessThanOrEqualFilter"
    			LessThanOrEqualFilter.new(element)
    		when "GreaterThanFilter"
    			GreaterThanFilter.new(element)
  			when "GreaterThanOrEqualFilter"
    			GreaterThanOrEqualFilter.new(element)
    		when "BetweenFilter"
    			BetweenFilter.new(element)
   			else
   				raise UnknownFilterType.new(element.name)
    		end
     	end
    	
    	module UpperBound
    	  attr_accessor :upper_bound
    	
    		def init_upper_bound_from_element!
    			@upper_bound = element["UpperBound"].to_f
    		end
    		
    		def upper_bound_attr
    			{ "UpperBound" => @upper_bound }
    		end
    	end
    	
    	module LowerBound
    	  attr_accessor :lower_bound
    	
    		def init_lower_bound_from_element!
    			@lower_bound = element["LowerBound"].to_f
    		end
    		
    		def lower_bound_attr
    			{ "LowerBound" => @lower_bound }
    		end
    	end
    	
    	module GeocodeReference
    	  attr_accessor :geocode_reference
    	  
    		def init_geocode_reference_from_element!
	    		gc = xpath("mdata:GeocodeReference")
    			@geocode_reference = Geocode.new(gc) if gc
    		end
    		
    		def write_geocode_reference!(xml)
    			return unless @geocode_reference
    			
    			xml.mdata :GeocodeReference, "Latitude" => @geocode_reference.latitude,
    				"Longitude" => @geocode_reference.longitude
    		end
    	end
    end
    
    class LessThanFilter < RangeFilter
    	include RangeFilter::UpperBound
    	include RangeFilter::GeocodeReference
    	
    	def initialize_from_element!
    		super
    		init_upper_bound_from_element!
    		init_geocode_reference_from_element!
    	end
    	
    	def write_xml!(xml)
    		xml.mdata :LessThanFilter, attribute_attr.merge(upper_bound_attr) do
    			write_geocode_reference! xml
    		end
    	end
    end
    
    class LessThanOrEqualFilter < RangeFilter
    	include RangeFilter::UpperBound
    	
    	def initialize_from_element!
    		super
    		init_upper_bound_from_element!
    	end
    	
    	def write_xml!(xml)
    		xml.mdata :LessThanOrEqualFilter, attribute_attr.merge(upper_bound_attr)
    	end
    end

    class GreaterThanFilter < RangeFilter
    	include RangeFilter::LowerBound
    	include RangeFilter::GeocodeReference
    	
    	def initialize_from_element!
    		super
    		init_lower_bound_from_element!
    		init_geocode_reference_from_element!
    	end
    	
    	def write_xml!(xml)
    		xml.mdata :GreaterThanFilter, attribute_attr.merge(lower_bound_attr) do
    			write_geocode_reference! xml
    		end
    	end
    end
    
    class GreaterThanOrEqualFilter < RangeFilter
    	include RangeFilter::LowerBound
    	
    	def initialize_from_element!
    		super
    		init_lower_bound_from_element!
    	end
    	
    	def write_xml!(xml)
    		xml.mdata :GreaterThanOrEqualFilter, attribute_attr.merge(lower_bound_attr)
    	end
    end
    
    class BetweenFilter < RangeFilter
    	include RangeFilter::UpperBound
    	include RangeFilter::LowerBound
    	include RangeFilter::GeocodeReference
    	
    	def initialize_from_element!
    		super
    		init_upper_bound_from_element!
    		init_lower_bound_from_element!
    		init_geocode_reference_from_element!
    	end
    	
    	def write_xml!(xml)
    		xml.mdata :BetweenFilter, attribute_attr.merge(lower_bound_attr).merge(upper_bound_attr) do
    			write_geocode_reference! xml
    		end
    	end
    end
  end
end
