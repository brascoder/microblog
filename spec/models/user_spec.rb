require 'spec_helper'

describe User do
  before { @user = User.new(name: 'Example User', email: 'user@example.com', password: 'foobar', password_confirmation: 'foobar') }
  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  context 'when name is not present' do
    before { @user.name = " " }
    it { should be_invalid }
  end

  context 'when email is not present' do
    before { @user.email = " " }
    it { should be_invalid }
  end

  context 'when name is too long' do
    before { @user.name = 'a' * 51 }
    it { should be_invalid }
  end

  context 'when email format is invalid' do
    it "should fail validation" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |address|
        @user.email = address
        expect(@user).to be_invalid
      end
    end
  end

  context 'when email format is valid' do
    it "should validate" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |address|
        @user.email = address
        expect(@user).to be_valid
      end
    end
  end

  context 'when email address is already taken' do
    before do
      duplicate_user = @user.dup
      duplicate_user.email = @user.email.upcase
      duplicate_user.save
    end
    it { should be_invalid }
  end

  context 'when password is not present' do
    before { @user = User.new(name: 'Example User', email: 'user@example.com', password: ' ', password_confirmation: ' ') }
    it { should be_invalid }
  end

  context 'when password does not match confirmation' do
    before { @user.password_confirmation = 'mismatch' }
    it { should be_invalid }
  end

  context 'when password is too short' do
    before { @user.password = @user.password_confirmation = 'a' * 5 }
    it { should be_invalid }
  end

  context 'return value of authenticate method' do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    context 'with valid password' do
      it { should eq found_user.authenticate(@user.password) }
    end

    context 'with invalid password' do
      let(:user_for_invalid_password) { found_user.authenticate('invalid') }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe 'remember token' do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "micropost associations" do
    before { @user.save }
    let!(:older_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) }
    let!(:newer_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) }
    it "should have the microposts in order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "should destroy associated posts" do
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe "followed users" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe "unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end
end
