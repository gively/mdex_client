require 'webmock'

class FakeMDEX
  extend WebMock::API
  
  WSDL_FILE = File.expand_path("#{__FILE__}/../mdex.wsdl")
  NAVIGATION_RESULT_FILE = File.expand_path("#{__FILE__}/../mdex_response.xml")
  
  def self.setup_stubs!
    stub_request(:post, %r{^https://(.*:.*@)?mdex.gively.com/ws/mdex}).
      to_return(:body => File.new(NAVIGATION_RESULT_FILE), :status => 200)
    
    stub_request(:get, %r{^https://(.*:.*@)?mdex.gively.com/ws/mdex}).
      to_return(:body => File.new(WSDL_FILE), :status => 200)
  end
  
  def self.navigation_result
    xml = Nokogiri::XML.parse(File.new(NAVIGATION_RESULT_FILE))
    result = xml.xpath("/env:Envelope/env:Body/mdata:Response/mdata:TypedResult/mdata:NavigationResults",
      MDEXClient::Client::NAMESPACES)
    MDEXClient::MData::NavigationResult.new(result)
  end
end