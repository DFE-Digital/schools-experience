shared_context 'test entity' do
  class TestEntity
    include Bookings::Gitis::Entity

    entity_id_attribute :testentityid
    entity_attributes :firstname, :lastname
    entity_attributes :hidden, internal: true
    entity_attributes :notcreate, except: :create
    entity_attributes :notupdate, except: :update
  end

  class TeamEntity
    include Bookings::Gitis::Entity

    entity_id_attribute :teamentityid

    entity_attribute :title
    entity_association :leader, TestEntity
  end
end
