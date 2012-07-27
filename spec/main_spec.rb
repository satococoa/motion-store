describe "Application 'CoreDataStore'" do

  class User < StoreModel::Base
    fields do
      string :nickname
      string :name
    end
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
