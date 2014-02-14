FactoryGirl.define do
  factory :user do
    name "Ron Cooke"
    email "ron.cooke@me.com"
    password "foobar"
    password_confirmation "foobar"
  end
end