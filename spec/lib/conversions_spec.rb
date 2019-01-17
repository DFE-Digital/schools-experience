describe 'Conversions' do
  describe 'Distance::Miles::ToMetres' do

    context '.convert' do

      subject { Conversions::Distance::Miles::ToMetres }

      specify "should multiply by 1609.344" do
          {
            1 => 1609,
            5 => 8046,
            10 => 16093,
          }.each do |miles, metres|
            expect(subject.convert(miles)).to be_within(1).of(metres)
          end
      end

    end
  end
end
