# lib/support/latin_dictionary.rb
#
module Support
  module String
    module LatinDictionary
      def dictionary
        {
          length: { count: 0 },
          uppercase: characters_to_dictionary(('A'..'Z').to_a),
          lowercase: characters_to_dictionary(('a'..'z').to_a),
          number: characters_to_dictionary(('0'..'9').to_a),
          special: characters_to_dictionary([' ', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '-', '=', '[', ']', '{', '}', '|', '"', '/', '\\', '.', ',', '`', '<', '>', ':', ';', '?', '~', "'"]),
          unknown: {}
        }
      end

      def dict_for_type(type)
        full_dictionary = dictionary
        dict =  case type
                when :uppercase, :lowecase, :number
                  [full_dictionary[type].keys.first, full_dictionary[type].keys.last].join('..')
                when :special
                  full_dictionary[type].keys.join
                end
        "(#{dict})" if dict.present?
      end

      private

      def characters_to_dictionary(array)
        array.index_with { |_i| 0 }
      end
    end
  end
end
