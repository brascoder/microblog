require 'spec_helper'

describe "StaticPages" do
  subject { page }

  context 'Home page' do
    before { visit root_path }

    it { should have_content('MicroBlog') }
    it { should have_title('MicroBlog') }

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) do
        FactoryGirl.create(:micropost, user: user, content: 'Lorem ipsum')
        FactoryGirl.create(:micropost, user: user, content: 'Dolor sit amet')
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end
    end
  end

  context 'Help page' do
    before { visit help_path }

    it { should have_content('Help') }
    it { should have_title('Help') }
  end

  context 'About page' do
    before { visit about_path }

    it { should have_content('About') }
    it { should have_title('About') }
  end

  context 'Contact page' do
    before { visit contact_path }

    it { should have_content('Contact') }
    it { should have_title('Contact') }
  end

end
