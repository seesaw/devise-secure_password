require_relative 'latin_dictionary'
require_relative 'count_result'

# lib/support/character_counter.rb
#
module Support
  module String
    class CharacterCounter
      extend LatinDictionary

      def self.analyze(string, _args = {})
        new(string).analyze
      end

      attr_reader :count_hash, :string

      def initialize(string)
        raise ArgumentError, "Invalid value for string: #{string}" if string.nil?

        @string = string
        reset_count_hash!
      end

      def analyze(new_string = nil)
        @string = new_string if new_string.present?

        reset_count_hash!
        string.chars.each { |c| tally_character(c) }
        count_hash[:length][:count] = string.length

        count_hash
      end

      private

      attr_writer :count_hash

      def reset_count_hash!
        @count_hash = CountResult[self.class.dictionary]
      end

      def tally_character(character)
        %i(uppercase lowercase number special unknown).each do |type|
          if count_hash[type].key?(character)
            count_hash[type][character] += 1
            return count_hash[type][character]
          end
        end

        # must be new unknown char
        count_hash[:unknown][character] = 1
        count_hash[:unknown][character]
      end

      def character_in_dictionary?(character, dictionary)
        dictionary.key?(character)
      end
    end
  end
end
