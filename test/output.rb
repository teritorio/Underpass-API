require 'test/unit'
require 'net/http'
require 'json'

class OutputTest < Test::Unit::TestCase
  def test_output_format
    types = [
      {
        'node' => {
          'id' => 8_569_759_788,
          'geom' => {
            'geom' => {
              'skel' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286}]',
              'body' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286,"tags":{"access":"yes","amenity":"drinking_water","man_made":"water_tap"}}]',
              'tags' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286,"tags":{"access":"yes","amenity":"drinking_water","man_made":"water_tap"}}]',
              'meta' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286,"timestamp":"2024-03-22T17:29:02Z","version":2,"changeset":149024046,"user":"Mateusz Konieczny - bot account","uid":3199858,"tags":{"access":"yes","amenity":"drinking_water","man_made":"water_tap"}}]'
            },
            'center' => {
              'skel' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286}]',
              'body' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286,"tags":{"access":"yes","amenity":"drinking_water","man_made":"water_tap"}}]',
              'tags' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286,"tags":{"access":"yes","amenity":"drinking_water","man_made":"water_tap"}}]',
              'meta' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286,"timestamp":"2024-03-22T17:29:02Z","version":2,"changeset":149024046,"user":"Mateusz Konieczny - bot account","uid":3199858,"tags":{"access":"yes","amenity":"drinking_water","man_made":"water_tap"}}]'
            },
            'bb' => {
              'skel' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286}]',
              'body' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286,"tags":{"access":"yes","amenity":"drinking_water","man_made":"water_tap"}}]',
              'tags' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286,"tags":{"access":"yes","amenity":"drinking_water","man_made":"water_tap"}}]',
              'meta' => '[{"type":"node","id":8569759788,"lat":43.873428,"lon":-1.0709286,"timestamp":"2024-03-22T17:29:02Z","version":2,"changeset":149024046,"user":"Mateusz Konieczny - bot account","uid":3199858,"tags":{"access":"yes","amenity":"drinking_water","man_made":"water_tap"}}]'
            }
          }
        }
      },
      {
        'way' => {
          'id' => 1_002_056_963,
          'geom' => {
            'geom' => {
              'skel' => '[{"type":"way","id":1002056963,"bounds":{"minlat":43.8735184,"minlon":-1.072013,"maxlat":43.873526,"maxlon":-1.0718098},"nodes":[9248370351,9248492787],"geometry":[{"lat":43.873526,"lon":-1.0718098},{"lat":43.8735184,"lon":-1.072013}]}]',
              'body' => '[{"type":"way","id":1002056963,"bounds":{"minlat":43.8735184,"minlon":-1.072013,"maxlat":43.873526,"maxlon":-1.0718098},"nodes":[9248370351,9248492787],"geometry":[{"lat":43.873526,"lon":-1.0718098},{"lat":43.8735184,"lon":-1.072013}],"tags":{"highway":"service","service":"parking_aisle"}}]',
              'tags' => '[{"type":"way","id":1002056963,"bounds":{"minlat":43.8735184,"minlon":-1.072013,"maxlat":43.873526,"maxlon":-1.0718098},"geometry":[{"lat":43.873526,"lon":-1.0718098},{"lat":43.8735184,"lon":-1.072013}],"tags":{"highway":"service","service":"parking_aisle"}}]',
              'meta' => '[{"type":"way","id":1002056963,"timestamp":"2021-11-13T15:34:51Z","version":1,"changeset":113734823,"user":"Patchanka","uid":128938,"bounds":{"minlat":43.8735184,"minlon":-1.072013,"maxlat":43.873526,"maxlon":-1.0718098},"nodes":[9248370351,9248492787],"geometry":[{"lat":43.873526,"lon":-1.0718098},{"lat":43.8735184,"lon":-1.072013}],"tags":{"highway":"service","service":"parking_aisle"}}]'
            },
            'center' => {
              'skel' => '[{"type":"way","id":1002056963,"center":{"lat":43.8735222,"lon":-1.0719114},"nodes":[9248370351,9248492787]}]',
              'body' => '[{"type":"way","id":1002056963,"center":{"lat":43.8735222,"lon":-1.0719114},"nodes":[9248370351,9248492787],"tags":{"highway":"service","service":"parking_aisle"}}]',
              'tags' => '[{"type":"way","id":1002056963,"center":{"lat":43.8735222,"lon":-1.0719114},"tags":{"highway":"service","service":"parking_aisle"}}]',
              'meta' => '[{"type":"way","id":1002056963,"timestamp":"2021-11-13T15:34:51Z","version":1,"changeset":113734823,"user":"Patchanka","uid":128938,"center":{"lat":43.8735222,"lon":-1.0719114},"nodes":[9248370351,9248492787],"tags":{"highway":"service","service":"parking_aisle"}}]'
            },
            'bb' => {
              'skel' => '[{"type":"way","id":1002056963,"bounds":{"minlat":43.8735184,"minlon":-1.072013,"maxlat":43.873526,"maxlon":-1.0718098},"nodes":[9248370351,9248492787]}]',
              'body' => '[{"type":"way","id":1002056963,"bounds":{"minlat":43.8735184,"minlon":-1.072013,"maxlat":43.873526,"maxlon":-1.0718098},"nodes":[9248370351,9248492787],"tags":{"highway":"service","service":"parking_aisle"}}]',
              'tags' => '[{"type":"way","id":1002056963,"bounds":{"minlat":43.8735184,"minlon":-1.072013,"maxlat":43.873526,"maxlon":-1.0718098},"tags":{"highway":"service","service":"parking_aisle"}}]',
              'meta' => '[{"type":"way","id":1002056963,"timestamp":"2021-11-13T15:34:51Z","version":1,"changeset":113734823,"user":"Patchanka","uid":128938,"bounds":{"minlat":43.8735184,"minlon":-1.072013,"maxlat":43.873526,"maxlon":-1.0718098},"nodes":[9248370351,9248492787],"tags":{"highway":"service","service":"parking_aisle"}}]'
            }
          }
        }
      },
      {
        'relation' => {
          'id' => 1_980_843,
          'geom' => {
            'geom' => {
              'skel' => '[{"type":"relation","id":1980843,"bounds":{"minlat":43.710366,"minlon":-1.053076,"maxlat":43.710583,"maxlon":-1.052753},"members":[{"type":"way","ref":146743052,"role":"outer","geometry":[{"lat":43.710379,"lon":-1.053076},{"lat":43.710366,"lon":-1.052872},{"lat":43.71038,"lon":-1.052869},{"lat":43.710405,"lon":-1.052865},{"lat":43.710405,"lon":-1.05276},{"lat":43.710454,"lon":-1.052753},{"lat":43.710457,"lon":-1.05278},{"lat":43.710481,"lon":-1.052773},{"lat":43.710547,"lon":-1.052758},{"lat":43.710553,"lon":-1.052812},{"lat":43.71057,"lon":-1.052943},{"lat":43.710583,"lon":-1.053055},{"lat":43.7104407,"lon":-1.0530696},{"lat":43.710379,"lon":-1.053076}]},{"type":"way","ref":146758090,"role":"inner","geometry":[{"lat":43.71051,"lon":-1.052857},{"lat":43.7105,"lon":-1.052843},{"lat":43.710422,"lon":-1.052851},{"lat":43.710424,"lon":-1.052935},{"lat":43.710516,"lon":-1.052926},{"lat":43.71051,"lon":-1.052857}]}]}]',
              'body' => '[{"type":"relation","id":1980843,"bounds":{"minlat":43.710366,"minlon":-1.053076,"maxlat":43.710583,"maxlon":-1.052753},"members":[{"type":"way","ref":146743052,"role":"outer","geometry":[{"lat":43.710379,"lon":-1.053076},{"lat":43.710366,"lon":-1.052872},{"lat":43.71038,"lon":-1.052869},{"lat":43.710405,"lon":-1.052865},{"lat":43.710405,"lon":-1.05276},{"lat":43.710454,"lon":-1.052753},{"lat":43.710457,"lon":-1.05278},{"lat":43.710481,"lon":-1.052773},{"lat":43.710547,"lon":-1.052758},{"lat":43.710553,"lon":-1.052812},{"lat":43.71057,"lon":-1.052943},{"lat":43.710583,"lon":-1.053055},{"lat":43.7104407,"lon":-1.0530696},{"lat":43.710379,"lon":-1.053076}]},{"type":"way","ref":146758090,"role":"inner","geometry":[{"lat":43.71051,"lon":-1.052857},{"lat":43.7105,"lon":-1.052843},{"lat":43.710422,"lon":-1.052851},{"lat":43.710424,"lon":-1.052935},{"lat":43.710516,"lon":-1.052926},{"lat":43.71051,"lon":-1.052857}]}],"tags":{"building":"yes","type":"multipolygon"}}]',
              'tags' => '[{"type":"relation","id":1980843,"bounds":{"minlat":43.710366,"minlon":-1.053076,"maxlat":43.710583,"maxlon":-1.052753},"tags":{"building":"yes","type":"multipolygon"}}]',
              'meta' => '[{"type":"relation","id":1980843,"timestamp":"2017-04-18T21:56:07Z","version":2,"changeset":47919949,"user":"Heinz_V","uid":91490,"bounds":{"minlat":43.710366,"minlon":-1.053076,"maxlat":43.710583,"maxlon":-1.052753},"members":[{"type":"way","ref":146743052,"role":"outer","geometry":[{"lat":43.710379,"lon":-1.053076},{"lat":43.710366,"lon":-1.052872},{"lat":43.71038,"lon":-1.052869},{"lat":43.710405,"lon":-1.052865},{"lat":43.710405,"lon":-1.05276},{"lat":43.710454,"lon":-1.052753},{"lat":43.710457,"lon":-1.05278},{"lat":43.710481,"lon":-1.052773},{"lat":43.710547,"lon":-1.052758},{"lat":43.710553,"lon":-1.052812},{"lat":43.71057,"lon":-1.052943},{"lat":43.710583,"lon":-1.053055},{"lat":43.7104407,"lon":-1.0530696},{"lat":43.710379,"lon":-1.053076}]},{"type":"way","ref":146758090,"role":"inner","geometry":[{"lat":43.71051,"lon":-1.052857},{"lat":43.7105,"lon":-1.052843},{"lat":43.710422,"lon":-1.052851},{"lat":43.710424,"lon":-1.052935},{"lat":43.710516,"lon":-1.052926},{"lat":43.71051,"lon":-1.052857}]}],"tags":{"building":"yes","type":"multipolygon"}}]'
            },
            'center' => {
              'skel' => '[{"type":"relation","id":1980843,"center":{"lat":43.7104745,"lon":-1.0529145},"members":[{"type":"way","ref":146743052,"role":"outer"},{"type":"way","ref":146758090,"role":"inner"}]}]',
              'body' => '[{"type":"relation","id":1980843,"center":{"lat":43.7104745,"lon":-1.0529145},"members":[{"type":"way","ref":146743052,"role":"outer"},{"type":"way","ref":146758090,"role":"inner"}],"tags":{"building":"yes","type":"multipolygon"}}]',
              'tags' => '[{"type":"relation","id":1980843,"center":{"lat":43.7104745,"lon":-1.0529145},"tags":{"building":"yes","type":"multipolygon"}}]',
              'meta' => '[{"type":"relation","id":1980843,"timestamp":"2017-04-18T21:56:07Z","version":2,"changeset":47919949,"user":"Heinz_V","uid":91490,"center":{"lat":43.7104745,"lon":-1.0529145},"members":[{"type":"way","ref":146743052,"role":"outer"},{"type":"way","ref":146758090,"role":"inner"}],"tags":{"building":"yes","type":"multipolygon"}}]'
            },
            'bb' => {
              'skel' => '[{"type":"relation","id":1980843,"bounds":{"minlat":43.710366,"minlon":-1.053076,"maxlat":43.710583,"maxlon":-1.052753},"members":[{"type":"way","ref":146743052,"role":"outer"},{"type":"way","ref":146758090,"role":"inner"}]}]',
              'body' => '[{"type":"relation","id":1980843,"bounds":{"minlat":43.710366,"minlon":-1.053076,"maxlat":43.710583,"maxlon":-1.052753},"members":[{"type":"way","ref":146743052,"role":"outer"},{"type":"way","ref":146758090,"role":"inner"}],"tags":{"building":"yes","type":"multipolygon"}}]',
              'tags' => '[{"type":"relation","id":1980843,"bounds":{"minlat":43.710366,"minlon":-1.053076,"maxlat":43.710583,"maxlon":-1.052753},"tags":{"building":"yes","type":"multipolygon"}}]',
              'meta' => '[{"type":"relation","id":1980843,"timestamp":"2017-04-18T21:56:07Z","version":2,"changeset":47919949,"user":"Heinz_V","uid":91490,"bounds":{"minlat":43.710366,"minlon":-1.053076,"maxlat":43.710583,"maxlon":-1.052753},"members":[{"type":"way","ref":146743052,"role":"outer"},{"type":"way","ref":146758090,"role":"inner"}],"tags":{"building":"yes","type":"multipolygon"}}]'
            }
          }
        }
      },
      {
        'area' => {
          'id' => 115_529_988,
          'geom' => {
            'geom' => {
              'skel' => '[{"type":"way","id":115529988,"bounds":{"minlat":43.8733932,"minlon":-1.0708849,"maxlat":43.8734582,"maxlon":-1.0707889},"nodes":[1304971082,1304965190,1304967673,1304969110,1304965228,1304971082],"geometry":[{"lat":43.8734082,"lon":-1.0708849},{"lat":43.8733932,"lon":-1.0708079},{"lat":43.8734422,"lon":-1.0707889},{"lat":43.8734542,"lon":-1.0708439},{"lat":43.8734582,"lon":-1.0708659},{"lat":43.8734082,"lon":-1.0708849}]}]',
              'body' => '[{"type":"way","id":115529988,"bounds":{"minlat":43.8733932,"minlon":-1.0708849,"maxlat":43.8734582,"maxlon":-1.0707889},"nodes":[1304971082,1304965190,1304967673,1304969110,1304965228,1304971082],"geometry":[{"lat":43.8734082,"lon":-1.0708849},{"lat":43.8733932,"lon":-1.0708079},{"lat":43.8734422,"lon":-1.0707889},{"lat":43.8734542,"lon":-1.0708439},{"lat":43.8734582,"lon":-1.0708659},{"lat":43.8734082,"lon":-1.0708849}],"tags":{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2011"}}]',
              'tags' => '[{"type":"way","id":115529988,"bounds":{"minlat":43.8733932,"minlon":-1.0708849,"maxlat":43.8734582,"maxlon":-1.0707889},"geometry":[{"lat":43.8734082,"lon":-1.0708849},{"lat":43.8733932,"lon":-1.0708079},{"lat":43.8734422,"lon":-1.0707889},{"lat":43.8734542,"lon":-1.0708439},{"lat":43.8734582,"lon":-1.0708659},{"lat":43.8734082,"lon":-1.0708849}],"tags":{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2011"}}]',
              'meta' => '[{"type":"way","id":115529988,"timestamp":"2011-08-19T20:43:01Z","version":2,"changeset":9069190,"user":"PierenBot","uid":201149,"bounds":{"minlat":43.8733932,"minlon":-1.0708849,"maxlat":43.8734582,"maxlon":-1.0707889},"nodes":[1304971082,1304965190,1304967673,1304969110,1304965228,1304971082],"geometry":[{"lat":43.8734082,"lon":-1.0708849},{"lat":43.8733932,"lon":-1.0708079},{"lat":43.8734422,"lon":-1.0707889},{"lat":43.8734542,"lon":-1.0708439},{"lat":43.8734582,"lon":-1.0708659},{"lat":43.8734082,"lon":-1.0708849}],"tags":{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2011"}}]'
            },
            'center' => {
              'skel' => '[{"type":"way","id":115529988,"center":{"lat":43.8734257,"lon":-1.0708369},"nodes":[1304971082,1304965190,1304967673,1304969110,1304965228,1304971082]}]',
              'body' => '[{"type":"way","id":115529988,"center":{"lat":43.8734257,"lon":-1.0708369},"nodes":[1304971082,1304965190,1304967673,1304969110,1304965228,1304971082],"tags":{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2011"}}]',
              'tags' => '[{"type":"way","id":115529988,"center":{"lat":43.8734257,"lon":-1.0708369},"tags":{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2011"}}]',
              'meta' => '[{"type":"way","id":115529988,"timestamp":"2011-08-19T20:43:01Z","version":2,"changeset":9069190,"user":"PierenBot","uid":201149,"center":{"lat":43.8734257,"lon":-1.0708369},"nodes":[1304971082,1304965190,1304967673,1304969110,1304965228,1304971082],"tags":{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2011"}}]'
            },
            'bb' => {
              'skel' => '[{"type":"way","id":115529988,"bounds":{"minlat":43.8733932,"minlon":-1.0708849,"maxlat":43.8734582,"maxlon":-1.0707889},"nodes":[1304971082,1304965190,1304967673,1304969110,1304965228,1304971082]}]',
              'body' => '[{"type":"way","id":115529988,"bounds":{"minlat":43.8733932,"minlon":-1.0708849,"maxlat":43.8734582,"maxlon":-1.0707889},"nodes":[1304971082,1304965190,1304967673,1304969110,1304965228,1304971082],"tags":{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2011"}}]',
              'tags' => '[{"type":"way","id":115529988,"bounds":{"minlat":43.8733932,"minlon":-1.0708849,"maxlat":43.8734582,"maxlon":-1.0707889},"tags":{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2011"}}]',
              'meta' => '[{"type":"way","id":115529988,"timestamp":"2011-08-19T20:43:01Z","version":2,"changeset":9069190,"user":"PierenBot","uid":201149,"bounds":{"minlat":43.8733932,"minlon":-1.0708849,"maxlat":43.8734582,"maxlon":-1.0707889},"nodes":[1304971082,1304965190,1304967673,1304969110,1304965228,1304971082],"tags":{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2011"}}]'
            }
          }
        }
      }, {
        'area' => {
          'id' => 3_600_000_000 + 1_980_842,
          'geom' => {
            'geom' => {
              'skel' => '[{"type":"area","id":3601980842}]',
              'body' => '[{"type":"area","id":3601980842,"tags":{"building":"yes","heritage":"3","heritage:operator":"mhs","mhs:inscription_date":"2000-10-16","name":"Atrium Casino","ref:mhs":"PA00083937","source:heritage":"data.gouv.fr, Ministère de la Culture - 2016","start_date":"C20","type":"multipolygon","wikidata":"Q2869814","wikipedia":"fr:Atrium Casino"}}]',
              'tags' => '[{"type":"area","id":3601980842,"tags":{"building":"yes","heritage":"3","heritage:operator":"mhs","mhs:inscription_date":"2000-10-16","name":"Atrium Casino","ref:mhs":"PA00083937","source:heritage":"data.gouv.fr, Ministère de la Culture - 2016","start_date":"C20","type":"multipolygon","wikidata":"Q2869814","wikipedia":"fr:Atrium Casino"}}]',
              'meta' => '[{"type":"area","id":3601980842,"tags":{"building":"yes","heritage":"3","heritage:operator":"mhs","mhs:inscription_date":"2000-10-16","name":"Atrium Casino","ref:mhs":"PA00083937","source:heritage":"data.gouv.fr, Ministère de la Culture - 2016","start_date":"C20","type":"multipolygon","wikidata":"Q2869814","wikipedia":"fr:Atrium Casino"}}]'
            },
            'center' => {
              'skel' => '[{"type":"area","id":3601980842}]',
              'body' => '[{"type":"area","id":3601980842,"tags":{"building":"yes","heritage":"3","heritage:operator":"mhs","mhs:inscription_date":"2000-10-16","name":"Atrium Casino","ref:mhs":"PA00083937","source:heritage":"data.gouv.fr, Ministère de la Culture - 2016","start_date":"C20","type":"multipolygon","wikidata":"Q2869814","wikipedia":"fr:Atrium Casino"}}]',
              'tags' => '[{"type":"area","id":3601980842,"tags":{"building":"yes","heritage":"3","heritage:operator":"mhs","mhs:inscription_date":"2000-10-16","name":"Atrium Casino","ref:mhs":"PA00083937","source:heritage":"data.gouv.fr, Ministère de la Culture - 2016","start_date":"C20","type":"multipolygon","wikidata":"Q2869814","wikipedia":"fr:Atrium Casino"}}]',
              'meta' => '[{"type":"area","id":3601980842,"tags":{"building":"yes","heritage":"3","heritage:operator":"mhs","mhs:inscription_date":"2000-10-16","name":"Atrium Casino","ref:mhs":"PA00083937","source:heritage":"data.gouv.fr, Ministère de la Culture - 2016","start_date":"C20","type":"multipolygon","wikidata":"Q2869814","wikipedia":"fr:Atrium Casino"}}]'
            },
            'bb' => {
              'skel' => '[{"type":"area","id":3601980842}]',
              'body' => '[{"type":"area","id":3601980842,"tags":{"building":"yes","heritage":"3","heritage:operator":"mhs","mhs:inscription_date":"2000-10-16","name":"Atrium Casino","ref:mhs":"PA00083937","source:heritage":"data.gouv.fr, Ministère de la Culture - 2016","start_date":"C20","type":"multipolygon","wikidata":"Q2869814","wikipedia":"fr:Atrium Casino"}}]',
              'tags' => '[{"type":"area","id":3601980842,"tags":{"building":"yes","heritage":"3","heritage:operator":"mhs","mhs:inscription_date":"2000-10-16","name":"Atrium Casino","ref:mhs":"PA00083937","source:heritage":"data.gouv.fr, Ministère de la Culture - 2016","start_date":"C20","type":"multipolygon","wikidata":"Q2869814","wikipedia":"fr:Atrium Casino"}}]',
              'meta' => '[{"type":"area","id":3601980842,"tags":{"building":"yes","heritage":"3","heritage:operator":"mhs","mhs:inscription_date":"2000-10-16","name":"Atrium Casino","ref:mhs":"PA00083937","source:heritage":"data.gouv.fr, Ministère de la Culture - 2016","start_date":"C20","type":"multipolygon","wikidata":"Q2869814","wikipedia":"fr:Atrium Casino"}}]'
            }
          }
        }
      }
    ]

    types.each  do |type|
      type.each do |type, type_details|
        type_details['geom'].each do |geom, level_of_details|
          level_of_details.each do |level_of_detail, except|
            overpass_query = "[out:json];#{type}(#{type_details['id']});out #{geom} #{level_of_detail};"
            # uri = URI('https://overpass-api.de/api/interpreter')
            uri = URI('http://127.0.0.1:9292/interpreter')
            uri.query = URI.encode_www_form({ data: overpass_query })
            response = JSON.parse(Net::HTTP.get(uri))['elements']
            # puts JSON.dump(response)
            response = response.collect do |e|
              e = e.compact.except('members', 'bounds')
              e['center'] = nil if e.key?('center')
              e
            end
            except = JSON.parse(except).collect do |e|
              e = e.compact.except('members', 'bounds')
              e['center'] = nil if e.key?('center')
              e
            end
            assert_equal(except, response, "#{type} #{geom} #{level_of_detail}")
          end
        end
      end
    end
  end
end
