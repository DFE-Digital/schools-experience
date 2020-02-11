shared_context 'test entity' do
  unless defined? TestEntity
    class TestEntity
      include Bookings::Gitis::Entity

      entity_id_attribute :testentityid
      entity_attributes :firstname, :lastname
      entity_attributes :notcreate, except: :create
      entity_attributes :notupdate, except: :update

      validates :firstname, presence: true, allow_nil: true
    end
  end

  unless defined? CompanyEntity
    class CompanyEntity
      include Bookings::Gitis::Entity

      entity_id_attribute :teamentityid

      entity_attribute :title
      entity_association :leader, TestEntity
    end
  end
end
