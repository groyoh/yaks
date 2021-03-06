module Yaks
  module Reader
    class JsonAPI
      def call(parsed_json, _env = {})
        included = parsed_json['included'].nil? ? {} : parsed_json['included'].dup

        if parsed_json['data'].is_a?(Array)
          CollectionResource.new(
            attributes: parsed_json['meta'].nil? ? nil : {meta: parsed_json['meta']},
            members: parsed_json['data'].map { |data| call('data'  => data, 'included' => included) }
          )
        else
          attributes = parsed_json['data'].dup
          links = attributes.delete('links') || {}
          type  = attributes.delete('type')
          attributes.merge!(attributes.delete('attributes') || {})

          association_links, resource_links = links.partition { |_k, v| v.is_a?(Hash) }
          embedded   = convert_embedded(Hash[association_links], included)
          links      = convert_links(Hash[resource_links])

          Resource.new(
            type: Util.singularize(type),
            attributes: Util.symbolize_keys(attributes),
            subresources: embedded,
            links: links
          )
        end
      end

      def convert_embedded(links, included)
        links.flat_map do |rel, link_data|
          # A Link doesn't have to contain a `linkage` member.
          # It can contain URLs instead, or as well, but we are only worried about *embedded* links here.
          linkage = link_data['linkage']
          # Resource linkage MUST be represented as one of the following:
          #
          # * `null` for empty to-one relationships.
          # * a "linkage object" for non-empty to-one relationships.
          # * an empty array ([]) for empty to-many relationships.
          # * an array of linkage objects for non-empty to-many relationships.
          if linkage.nil?
            nil
          elsif linkage.is_a? Array
            CollectionResource.new(
              members: linkage.map { |link|
                data = included.find{ |item| (item['id'] == link['id']) && (item['type'] == link['type']) }
                call('data'  => data, 'included' => included)
              },
              rels: [rel]
            )
          else
            data = included.find{ |item| (item['id'] == linkage['id']) && (item['type'] == linkage['type']) }
            call('data'  => data, 'included' => included).with(rels: [rel])
          end
        end.compact
      end

      def convert_links(links)
        links.map do |rel, link|
          Resource::Link.new(rel: rel.to_sym, uri: link)
        end
      end
    end
  end
end
