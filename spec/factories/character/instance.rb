FactoryBot.define do
  factory :character_instance, class: Character::Instance do
    user              { create(:user) }
    template          { create(:character_template) }
    nature            { template.nature }
    name              { Faker::Lorem.characters(5) }
    level             { 1 }
    special_class     { create(:character_class)}
  end
end
