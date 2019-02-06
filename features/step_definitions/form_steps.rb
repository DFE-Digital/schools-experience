Then("I should see a form with the following fields:") do |table|
  within('#main-content form') do
    table.hashes.each do |row|
      label = page.find(".govuk-label", text: row['Label'])

      within(label.ancestor('div.govuk-form-group')) do
        case row['Type']

        when 'date'
          %w{Day Month Year}.each do |date_part|
            page.find('label', text: date_part).tap do |inner_label|
              expect(page).to have_field(inner_label.text, type: 'number')
            end
          end

        when /radio/
          expect(page).to have_css('.govuk-label', text: row['Label'])
          row['Options'].split(',').map(&:strip).each do |opt|
            expect(page).to have_field(opt, type: 'radio')
          end

        else # regular inputs
          expect(page).to have_field(row['Label'], type: row['Type'])
        end
      end
    end
  end
end
