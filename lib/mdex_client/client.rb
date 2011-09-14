require 'mdex_client/mdata/navigation_result'
require 'mdex_client/mdata/navigation_query'

module MDEXClient
  class Client
    attr_reader :soap_client
    attr_accessor :login, :password

    NAMESPACES = {
      "env" => "http://schemas.xmlsoap.org/soap/envelope/",
      "mdata" => "http://www.endeca.com/MDEX/data/IR600"
    }
    
    def self.namespace_declarations
      NAMESPACES.inject({}) do |memo, (name, uri)|
        memo["xmlns:#{name}"] = uri
        memo
      end
    end
    
    def initialize(&block)
      @soap_client = Savon::Client.new do
        process 1, &block if block
      end
    end
    
    def xquery(xquery)
      response = @soap_client.request("Request") do
        soap.xml do |xml| 
          xml.env(:Envelope, MDEXClient::Client.namespace_declarations) do
            xml.env :Header
            xml.env(:Body) do
              xml.mdata :Request, xquery
            end
          end
        end
      end
      
      response_xml = Nokogiri::XML::Document.parse(response.to_xml)
      response_xml.xpath("/env:Envelope/env:Body/mdata:Response", NAMESPACES)
    end
    
    def dimension_value_id_from_path(path)
    	quoted_path = path.collect do |item|
    		"\"#{item}\""
    	end
    	
    	response = xquery("mdex:dimension-value-id-from-path((#{quoted_path.join(",")}))")
    	result = response.xpath("mdata:UntypedResult/mdata:Result", NAMESPACES)
    	result && result.text.to_i
    end
    
    def navigation_query(params=nil)
      query = case params
      when MData::NavigationQuery
        params
      else
        MData::NavigationQuery.new(params)
      end
      
      xml = Builder::XmlMarkup.new
      xml.mdata :Query do
        query.write_xml!(xml)
      end
      
      response = xquery("mdex:navigation-query(#{xml.target!})")
      MData::NavigationResult.new(response.xpath("mdata:TypedResult/mdata:NavigationResults", NAMESPACES))
    end
    
    def query_each(params)
      query = case params
      when MData::NavigationQuery
        params.dup
      else
        MData::NavigationQuery.new(params)
      end
      
      query.record_offset ||= 0
      
      while true
        result = navigation_query(query)
        result.records.each do |record|
          yield record
        end
        
        break if result.records_per_page + result.offset > result.total_record_count
        query.record_offset += result.records_per_page
      end
    end
  end
end
