require 'unicode_utils'
require 'i18n_data'
require_relative 'count_result'

# lib/support/multi_lang_character_counter.rb
#
module Support
  module String
    class MultiLangCharacterCounter
      # there is not dictionary of all languages so return nil
      def self.dict_for_type(*); end

      def self.analyze(string, password_locale:)
        new(string, password_locale).analyze
      end

      attr_reader :count_hash, :string, :password_locale

      def initialize(string, password_locale)
        raise ArgumentError, "Invalid value for string: #{string}" if string.nil?

        @string = string
        @password_locale = password_locale
        @count_hash = CountResult[default_count_map]
      end

      def analyze
        categorize_string!
        count_hash
      end

      private

      def default_count_map
        default_map = { length: { count: 0 }, number: {}, special: {} }
        if password_locale_cased?
          default_map.merge(lowercase: {}, uppercase: {})
        else
          default_map.merge(anycase: {})
        end
      end

      def with_total_length_and_default(categorized)
        total_length = categorized.empty? ? 0 : categorized.values.map(&:values).flatten.sum
        accepted_categorized = categorized.slice(*@count_hash.keys)
        @count_hash.deep_merge!(length: { count: total_length }, **accepted_categorized)
      end

      def categorize_string!
        categorized = string.chars.tally.map do |char, count|
          width_count = UnicodeUtils.char_display_width(char) * count
          categorize_char(char, width_count)
        end.reduce(:deep_merge)
        categorized ||= {}
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

      def password_locale_cased?
        locale_name = I18nData.languages(password_locale)[password_locale.to_s.upcase]
        return false if locale_name.nil?
  
        UnicodeUtils.cased_char?(locale_name.chars.first)
      rescue
        false
      end
    end
  end
end
