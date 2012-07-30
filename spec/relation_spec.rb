describe "MotionStore 'Relationship'" do

  class RelAddress < MotionStore::Model
    fields do
      string :country
      string :zip
    end
  end

  class RelUser < MotionStore::Model
    fields do
      string :name
      int16 :age
      relation :address, destination: 'RelAddress'
    end
  end

  before do
    MotionStore::Store.shared.reset
    [RelUser, RelAddress].each{|klass| klass.delete_all }
  end

  after do
    MotionStore::Store.shared.reset
    [RelUser, RelAddress].each{|klass| klass.delete_all }
  end

  it "create 1:1 relation" do
    address = RelAddress.create(country: 'Japan', zip: '123-4567')
    user = RelUser.create(name: 'Test User', age: 20, address: address)

    user.name.should == 'Test User'
    user.age.should == 20
    user.address.should == address
    user.address.country.should == 'Japan'
    user.address.zip.should == '123-4567'
    RelUser.count.should == 1
    RelAddress.count.should == 1
  end

end