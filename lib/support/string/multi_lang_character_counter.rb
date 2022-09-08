require 'unicode_utils'
require_relative 'count_result'

# lib/support/multi_lang_character_counter.rb
#
module Support
  module String
    class MultiLangCharacterCounter
      # there is not dictionary of all languages so return nil
      def self.dict_for_type(*); end

      def self.analyze(string)
        new(string).analyze
      end

      attr_reader :count_hash, :string

      def initialize(string)
        raise ArgumentError, "Invalid value for string: #{string}" if string.nil?

        @string = string
      end

      def analyze
        @count_hash = CountResult[categorize_string]
        count_hash
      end

      private

      def with_total_length_and_default(categorized)
        total_length = categorized.values.map(&:values).flatten.sum
        { length: { count: total_length }, number: {}, special: {} }.merge(categorized)
      end

      def categorize_string
        categorized = string.chars.tally.map do |char, count|
          width_count = UnicodeUtils.char_display_width(char) * count
          categorize_char(char, width_count)
        end.reduce(:deep_merge)
        with_total_length_and_default(categorized)
      end

      # rubocop:disable Metrics/MethodLength
      def categorize_char(char, width_count)
        char_type = UnicodeUtils.char_type(char)
        category =  case char_type
                    when :Letter
                      letter_category(char)
                    when :Punctuation, :Symbol, :Separator
                      :special
                    when :Number
                      :number
                    else
                      :unknown
                    end
        { category => { char => width_count } }.symbolize_keys
      end
      # rubocop:enable Metrics/MethodLength

      def letter_category(char)
        if UnicodeUtils.cased_char?(char)
          char == UnicodeUtils.upcase(char) ? :uppercase : :lowercase
        else
          :anycase
        end
      end
    end
  end
end
