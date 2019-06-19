shared_context 'restricted unless school onboarded' do |path_to_test|
  specify 'should include concern RestrictAccessUnlessOnboarded' do
    expect(subject).is_a?(Schools::RestrictAccessUnlessOnboarded)
  end
end
