describe "Application 'CoreDataStore'" do

  class User < NSManagedObject
    def self.entity
      @entity ||= begin
        entity = NSEntityDescription.new
        entity.name = 'User'
        entity.managedObjectClassName = 'User'
        entity.properties = 
          ['nickname', NSStringAttributeType,
           'name', NSStringAttributeType].each_slice(2).map {|name, type|
            property = NSAttributeDescription.new
            property.name = name
            property.attributeType = type
            # property.optional = false
            # property.defaultValue = 'hoge'
            property
          }
        entity
      end
    end
    include StoreModel
  end

  before do
    User.delete_all
  end

  after do
    User.delete_all
  end

  it "create object" do
    user = User.create(nickname: 'test_user', name: 'Test User')

    user.nickname.should == 'test_user'
    user.name.should == 'Test User'
    User.all.count.should == 1
  end
end
