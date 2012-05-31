# mdex_client: a Ruby client for Endeca MDEX

mdex_client is a client for the MDEX search engine from Oracle (nee Endeca).  The client speaks to MDEX using its XQuery API over SOAP, which is a low-level interface for constructing search queries.

## Compatibility, Status, and Support

mdex_client supports most of the XQuery SOAP API, but not all of it.  We're no longer actively maintaining mdex_client.  If you or your company is using Endeca MDEX with a Ruby application and would like to be the maintainer of this gem, please contact [Nat Budin](mailto:natbudin@gmail.com).

## Documentation and Test Suite

There really isn't any.  Sorry about that.  Here's a short piece of example code:

```ruby
client = MDEXClient::Client.new do
  # this is just a Savon configuration block, you can use whatever Savon params you need here

  wsdl.document = 'http://my-endeca-server/ws/mdex?wsdl'
  wsdl.endpoint = 'http://my-endeca-server/ws/mdex'
end

# MDEXClient::MData::NavigationQuery supports a lot of options.  
# Read it to find out about more.  They map pretty much exactly to the
# possible options listed in Endeca's XQuery guide.
result = client.navigation_query(:main_search_query => "merlot")

result.records.each do |record|
  id, name = record.attributes["id"], record.attributes["name"]
  puts "Wine number #{id}: #{name}"
end

# Or if you want to get fancy:
class Wine < ActiveRecord::Base
  include MDEXClient::ActiveRecord::Searchable
  
  self.mdex_field_mapping = {
	"id" => "id",
	"name" => "name",
	"vintage" => "vintage"
  }
end

Wine.mdex_client = client
query, result, wines = Wine.mdex_search(:main_search_query => "burgundy")
wines.each do |wine|
  puts "Wine number #{wine.id}: #{wine.name}"
end
```

## Licensing

mdex_client is released under the MIT license.  For more details, please see the LICENSE file.