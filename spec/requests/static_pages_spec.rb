require 'spec_helper'

describe "StaticPages" do

  context 'Home page' do
    it "should have the content 'Microblog'" do
      visit '/static_pages/home'
      expect(page).to have_content('Microblog')
    end

    it "should have the title 'Microblog'" do
      visit '/static_pages/home'
      expect(page).to have_title('Microblog')
    end
  end

  context 'Help page' do
    it "should have the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end

    it "should have title 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_title('Help')
    end
  end

  context 'About page' do
    it "should have the content 'About'" do
      visit '/static_pages/about'
      expect(page).to have_content('About')
    end

    it "should have the title 'about'" do
      visit '/static_pages/about'
      expect(page).to have_title('About')
    end
  end

  context 'Contact page' do
    it "should have the content 'Contact'" do
      visit '/static_pages/contact'
      expect(page).to have_content('Contact')
    end

    it "should have the title 'Contact'" do
      visit '/static_pages/contact'
      expect(page).to have_title('Contact')
    end
  end

end
