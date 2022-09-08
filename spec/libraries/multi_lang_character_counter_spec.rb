require 'support/string/multi_lang_character_counter'

RSpec.describe Support::String::MultiLangCharacterCounter do
  let(:input_string) { '' }

  subject { described_class.new(input_string) }

  describe 'attributes' do
    it { is_expected.to respond_to(:analyze) }
    it { is_expected.to respond_to(:count_hash) }
  end

  describe '#count' do
    context 'when input string is invalid' do
      let(:input_string) { nil }

      it 'raises an ArgumentError' do
        expect { subject.analyze }.to raise_error(ArgumentError)
      end
    end

    context 'when input string is a non latin lang' do
      let(:input_string) do
        [
          'خزانة ؛12' # 'guardaroba .12'
        ].sample
      end

      before { subject.analyze }

      it 'tallies the correct chracter counts' do
        total_anycase = subject.count_hash[:anycase].values.sum
        total_number = subject.count_hash[:number].values.sum
        total_special = subject.count_hash[:special].values.sum

        expect(total_anycase).to eq(5)
        expect(total_number).to eq(2)
        expect(total_special).to eq(2)
      end
    end

    context 'when input string is a non latin lang with display width greater than 1' do
      let(:input_string) do
        ['他の'].sample
      end

      before { subject.analyze }

      it 'tallies the correct chracter counts' do
        total_anycase = subject.count_hash[:anycase].values.sum

        expect(total_anycase).to eq(4)
      end
    end

    context 'when input string is a latin lang' do
      let(:input_string) do
        ['GUardaroba.12 '].sample
      end

      before { subject.analyze }

      it 'tallies the correct chracter counts' do
        total_uppercase = subject.count_hash[:uppercase].values.sum
        total_lowercase = subject.count_hash[:lowercase].values.sum
        total_number = subject.count_hash[:number].values.sum
        total_special = subject.count_hash[:special].values.sum

        expect(total_uppercase).to eq(2)
        expect(total_lowercase).to eq(8)
        expect(total_number).to eq(2)
        expect(total_special).to eq(2)
      end
    end
  end
end
