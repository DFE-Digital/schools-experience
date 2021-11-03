xml.instruct! :xml, version: "1.0"
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.url do
    xml.loc root_url
  end

  xml.url do
    xml.loc schools_url
  end

  @enabled_schools_urns.each do |urn|
    xml.url do
      xml.loc candidates_school_url(urn)
    end
  end
end
