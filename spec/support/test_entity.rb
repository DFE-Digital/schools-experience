shared_context 'test entity' do
  class TestEntity
    include Bookings::Gitis::Entity

    entity_id_attribute :testentityid
    entity_attributes :firstname, :lastname
    entity_attributes :hidden, internal: true
    entity_attributes :notcreate, except: :create
    entity_attributes :notupdate, except: :update

    def initialize(data = {})
      self.testentityid = data['testentityid']
      self.firstname = data['firstname']
      self.lastname = data['lastname']

      super
    end
  end
end
