# frozen_string_literal: true

require 'bundler/setup'
require 'hanami/api'
require 'overpass_parser'
require 'json'
require_relative 'backends/postgres_osmosis/postgres_osmosis'
require_relative 'backends/duckdb_quackosm/duckdb_quackosm'

class App < Hanami::API
  def initialize
    super
    @@backend = Object::const_get(ENV['BACKEND']).new
  end

  helpers do
    def query
      query = params[:data]
      begin
        sql, result = @@backend.exec(query)
        # "timestamp_osm_base": "2024-04-08T20:16:26Z",
        # "timestamp_areas_base": "2024-04-08T16:33:59Z",
        json = "{
  \"version\": 0.6,
  \"generator\": \"underpass\",
  \"osm3s\": {
    \"backend\": \"#{@@backend.class.name}\",
    \"query\": \"#{sql.gsub("\n", '\\n').gsub('\\', '\\\\').gsub('"', '\\"')}\",
    \"copyright\": \"The data included in this document is from www.openstreetmap.org. The data is made available under ODbL.\"
  },
  \"elements\": [" + result.join(",\n") + ']}'
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Content-Type'] = 'application/json'
        body(json)
      rescue OverpassParser::ParsingError => e
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Content-Type'] = 'text/html'
        body("<html>
  <body>
  <p><strong style=\"color:#FF0000\">Error</strong>: #{e}</p>
  </body>
  </html>")
      end
    end
  end

  get '/interpreter' do
    query
  end

  post '/interpreter' do
    query
  end
end

run App.new
