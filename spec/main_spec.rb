describe "Application 'CoreDataStore'" do

  class User < StoreModel::Base
    fields do
      string :nickname
      string :name
      int16 :age
    end
  end

  class Account < StoreModel::Base
    fields do
      string :provider
      string :username
    end
  end

  after do
    User.delete_all
    Account.delete_all
  end

  it "create object" do
    user = User.create(nickname: 'test_user', name: 'Test User', age: 20)
    account = Account.create(provider: 'github', username: 'testuser')

    user.nickname.should == 'test_user'
    user.name.should == 'Test User'
    User.all.count.should == 1
    Account.all.count.should == 1
  end

  it "throw error when invalid parameter on initialize" do
    lambda {
      User.create(nickname: 'test_user', name: 'Test User', age: 20, hoge: 'hoge')
    }.should.raise(StoreModel::NoPropertyError)
  end

  it "find specified object" do
    3.times {|i| User.create(nickname: "user#{i}", name: "User #{i}", age: 20+i) }
    user = User.find(['nickname == %@', 'user2'])[0]
    user.name.should == 'User 2'
    user2 = User.find(['name == %@', 'User 1'])[0]
    user2.nickname.should == 'user1'
  end

  it "returns sorted data" do
    3.times {|i| User.create(nickname: "user#{i}", name: "User #{i}", age: 20+i) }
    users_in_desc = User.find(nil, [:age, :desc])
    users_in_desc.map(&:age).should == [22, 21, 20]
    users_in_asc = User.find(nil, [:age, :asc])
    users_in_asc.map(&:age).should == [20, 21, 22]
  end

  it "update object" do
    user = User.create(nickname: 'test_user', name: 'Test User', age: 20)
    user.nickname = 'updated!'
    user.save
    User.find[0].nickname.should == 'updated!'
  end

  it "fetch all objects" do
    3.times {|i| User.create(nickname: "user#{i}", name: "User #{i}", age: 20+i) }

    users = User.all
    users.count.should == 3
    users[0].nickname.should == 'user0'
    users[0].name.should == 'User 0'
    users[0].age.should == 20
    users[1].nickname.should == 'user1'
    users[1].name.should == 'User 1'
    users[1].age.should == 21
    users[2].nickname.should == 'user2'
    users[2].name.should == 'User 2'
    users[2].age.should == 22
  end

  it "remove object" do
    user = User.create(nickname: 'test_user', name: 'Test User', age: 20)
    user.remove
    User.all.count.should == 0
  end

  it "delete all objects" do
    3.times {|i| User.create(nickname: "user#{i}", name: "User #{i}", age: 20+i) }
    Account.create(provider: 'github', username: 'testuser')

    User.all.count.should == 3
    Account.all.count == 1
    User.delete_all
    User.all.count.should == 0
    Account.all.count == 1
  end

end
