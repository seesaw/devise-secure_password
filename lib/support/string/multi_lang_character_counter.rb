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

      delegate :char_display_width, :char_type, :cased_char?, :downcase, :upcase, to: :UnicodeUtils

      def initialize(string)
        raise ArgumentError, "Invalid value for string: #{string}" if string.nil?

        @string = string
        reset_count_hash!
      end

      def analyze
        reset_count_hash!

        string.chars.each do |char|
          char_display_width = char_display_width(char)
          count_hash[:length][:count] += char_display_width
          count_char_by_type(char, char_display_width)
        end
        normalize_count_hash!
        count_hash
      end

      private

      attr_writer :count_hash, :string

      def reset_count_hash!
        @count_hash = CountResult[length: { count: 0 }, uppercase: {}, lowercase: {}, anycase: {},
                                  number: {}, special: {}, unknown: {}]
      end

      def normalize_count_hash!
        if count_hash[:anycase].values.sum.zero?
          count_hash.delete :anycase
        else
          count_hash.delete :uppercase
          count_hash.delete :lowercase
        end
      end

      # TODO: make me nicer!
      def count_char_by_type(char, char_length)
        case char_type(char)
        when :Letter
          count_letter_char(char, char_length)
        when :Punctuation, :Symbol, :Separator
          count_hash[:special][char] ||= 0
          count_hash[:special][char] += char_length
        when :Number
          count_hash[:number][char] ||= 0
          count_hash[:number][char] += char_length
        else
          count_hash[:unknown][char] ||= 0
          count_hash[:unknown][char] += char_length
        end
      end

      # TODO: make me nicer!
      def count_letter_char(char, char_length)
        count_hash[:uppercase][char] ||= 0
        count_hash[:lowercase][char] ||= 0
        count_hash[:anycase][char] ||= 0

        if cased_char?(char)
          count_hash[:uppercase][char] += char_length if char == upcase(char)
          count_hash[:lowercase][char] += char_length if char == downcase(char)
        else
          count_hash[:anycase][char] += char_length
        end
      end
    end
  end
end
