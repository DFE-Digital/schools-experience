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

  describe 'Distance::Miles::ToMetres' do
    context '.convert' do
      context 'with precision of 0' do
        subject { Conversions::Distance::Metres::ToMiles }

        specify "should divide by 1609.344" do
          {
            1800 => 1,
            3600 => 2,
            4700 => 3,
          }.each do |metres, miles|
            expect(subject.convert(metres, 0)).to eql(miles)
          end
        end
      end

      context 'with precision of 1' do
        subject { Conversions::Distance::Metres::ToMiles }

        specify "should divide by 1609.344" do
          {
            1800 => 1.1,
            3600 => 2.2,
            4700 => 2.9,
          }.each do |metres, miles|
            expect(subject.convert(metres)).to eql(miles)
          end
        end
      end

      context 'with infinite precision' do
        subject { Conversions::Distance::Metres::ToMiles }

        specify "should divide by 1609.344" do
          {
            1800 => 1.1184,
            3600 => 2.2369,
            4700 => 2.9204,
          }.each do |metres, miles|
            expect(subject.convert(metres, nil)).to be_within(0.0001).of(miles)
          end
        end
      end
    end
  end
end
