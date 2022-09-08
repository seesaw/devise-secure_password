module Support
  module String
    class CountResult < Hash
      def string_length
        self[:length][:count]
      end

      delegate :present?, to: :string_length, prefix: true

      def unknown_chars
        self[:unknown]
      end

      def unknown_chars_present?
        return false if unknown_chars.blank?

        unknown_chars.values.sum.positive?
      end

      def known_chars
        slice(:uppercase, :lowercase, :anycase, :number, :special)
      end
    end
  end
end
