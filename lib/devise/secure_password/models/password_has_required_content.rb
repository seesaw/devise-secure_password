module Devise
  module Models
    # rubocop:disable Metrics/ModuleLength
    module PasswordHasRequiredContent
      extend ActiveSupport::Concern

      require 'support/string/character_counter'

      LENGTH_MAX = 255

      included do
        validate :validate_password_content, if: :password_required?
        validate :validate_password_confirmation_content, if: :password_required?
        validate :validate_password_confirmation, if: :password_required?
      end

      def validate_password_content
        self.password ||= ''
        errors.delete(:password)
        validate_password_content_for(:password)
        errors[:password].count.zero?
      end

      def validate_password_confirmation_content
        return true if password_confirmation.nil? # rails skips password_confirmation validation if nil!

        errors.delete(:password_confirmation)
        validate_password_content_for(:password_confirmation)
        errors[:password_confirmation].count.zero?
      end

      def validate_password_confirmation
        return true if password_confirmation.nil? # rails skips password_confirmation validation if nil!

        unless password == password_confirmation
          human_attribute_name = self.class.human_attribute_name(:password)
          errors.add(:password_confirmation, :confirmation, attribute: human_attribute_name)
        end
        errors[:password_confirmation].count.zero?
      end

      def validate_password_content_for(attr)
        return unless respond_to?(attr) && !(password_obj = send(attr)).nil?

        result = character_counter_class.analyze(password_obj, password_locale: user_password_locale)
        validate_length(result.string_length, attr)
        validate_unknown_chars(result.unknown_chars, attr) if result.unknown_chars_present?
        validate_known_chars_map(result.known_chars, attr)
      end

      protected

      def add_error_with_string(error_string, attr)
        errors.add(attr, error_string) if error_string.present?
      end

      def validate_unknown_chars(unknown_chars, attr)
        type_total = unknown_chars.values.reduce(0, :+)
        return if type_total <= required_char_counts_for_type(:unknown)[:max]

        error_string = error_string_for_unknown_chars(type_total, unknown_chars)
        add_error_with_string(error_string, attr)
      end

      def validate_known_chars_map(known_chars, attr)
        known_chars.each do |known_chars_type, chars_map|
          error_string = validate_known_chars_type(known_chars_type, chars_map)
          add_error_with_string(error_string, attr)
        end
      end

      def validate_known_chars_type(chars_type, chars_map)
        type_total = chars_map.values.reduce(0, :+)
        if type_total < required_char_counts_for_type(chars_type)[:min]
          error_string_for_type_length(chars_type, :min)
        elsif type_total > required_char_counts_for_type(chars_type)[:max]
          error_string_for_type_length(chars_type, :max)
        end
      end

      def validate_length(dict, attr)
        error_string = if dict < Devise.password_length.min
                         error_string_for_length(:min)
                       elsif dict > Devise.password_length.max
                         error_string_for_length(:max)
                       end
        add_error_with_string(error_string, attr)
      end

      def error_string_for_length(threshold = :min)
        lang_key = case threshold
                   when :min then 'secure_password.password_has_required_content.errors.messages.minimum_length'
                   when :max then 'secure_password.password_has_required_content.errors.messages.maximum_length'
                   else return ''
                   end

        count = required_char_counts_for_type(:length)[threshold]
        I18n.t(lang_key, count: count, subject: I18n.t('secure_password.character', count: count))
      end

      def error_string_for_type_length(type, threshold = :min)
        lang_key = case threshold
                   when :min then 'secure_password.password_has_required_content.errors.messages.minimum_characters'
                   when :max then 'secure_password.password_has_required_content.errors.messages.maximum_characters'
                   else return ''
                   end

        count = required_char_counts_for_type(type)[threshold]
        error_string = I18n.t(lang_key, count: count, type: I18n.t("secure_password.types.#{type}"),
                                        subject: I18n.t('secure_password.character', count: count))
        dict_for_type = character_counter_class.dict_for_type(type)
        "#{error_string}  #{dict_for_type}"
      end

      def error_string_for_unknown_chars(count, dict)
        I18n.t(
          'secure_password.password_has_required_content.errors.messages.unknown_characters',
          count: count,
          subject: I18n.t('secure_password.character', count: count)
        ) + " (#{dict.keys.join(', ')})"
      end

      def required_char_counts_for_type(type)
        self.class.config[:REQUIRED_CHAR_COUNTS][type]
      end

      def character_counter_class
        self.class.password_character_counter_class
      end

      def user_password_locale
        config_password_locale = self.class.password_locale
        return if config_password_locale.nil?

        config_password_locale.is_a?(Proc) ? config_password_locale.call(self) : config_password_locale
      end

      module ClassMethods
        config_params = %i(
          password_required_uppercase_count
          password_required_lowercase_count
          password_required_anycase_count
          password_required_number_count
          password_required_special_character_count
          password_character_counter_class
          password_locale
        )
        ::Devise::Models.config(self, *config_params)

        # rubocop:disable Metrics/MethodLength
        def config
          {
            REQUIRED_CHAR_COUNTS: {
              length: {
                min: Devise.password_length.min,
                max: Devise.password_length.max
              },
              uppercase: {
                min: password_required_uppercase_count,
                max: LENGTH_MAX
              },
              lowercase: {
                min: password_required_lowercase_count,
                max: LENGTH_MAX
              },
              anycase: {
                min: password_required_anycase_count || (password_required_uppercase_count + password_required_lowercase_count),
                max: LENGTH_MAX
              },
              number: {
                min: password_required_number_count,
                max: LENGTH_MAX
              },
              special: {
                min: password_required_special_character_count,
                max: LENGTH_MAX
              },
              unknown: {
                min: 0,
                max: 0
              }
            }
          }
        end
        # rubocop:enable Metrics/MethodLength
      end
      # rubocop:enable Metrics/ModuleLength
    end
  end
end
