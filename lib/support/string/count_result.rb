module Support
  module String
    class CountResult < Hash 
      def string_length
        self[:length][:count]
      end

      def string_length_present?
        string_length.present?
      end

      def unknown_chars
        self[:unknown]
      end

      def unknown_chars_present?
        return false unless unknown_chars.present?

        unknown_chars.values.sum > 0
      end

      def known_chars
        self.slice(:uppercase, :lowercase, :anycase, :number, :special)
      end
    end
  end
end
