require 'rails_helper'

RSpec.describe Character::Instance, type: :model do
  describe 'basic validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:experience_amount) }
    it { is_expected.to validate_presence_of(:additive_power) }
    it { is_expected.to validate_presence_of(:additive_swiftness) }
    it { is_expected.to validate_presence_of(:additive_control) }
    it { is_expected.to validate_presence_of(:additive_strength) }
    it { is_expected.to validate_presence_of(:additive_constitution) }
    it { is_expected.to validate_presence_of(:additive_dexterity) }
    it { is_expected.to validate_presence_of(:additive_intelligence) }
    it { is_expected.to validate_presence_of(:grown_strength) }
    it { is_expected.to validate_presence_of(:grown_constitution) }
    it { is_expected.to validate_presence_of(:grown_dexterity) }
    it { is_expected.to validate_presence_of(:grown_intelligence) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:template) }
    it { is_expected.to belong_to(:nature) }
    it { is_expected.to belong_to(:special_class) }
    it { is_expected.to belong_to(:prestigious_class) }
    it { is_expected.to belong_to(:legendary_class) }
  end

  describe 'factories' do
    context 'a valid factory' do
      it 'should be valid' do
        expect { create(:character_instance) }.not_to raise_error
      end

      it 'should not create events' do
        expect{ create(:character_instance) }.not_to change{ Character::Event.count }
      end
    end

    context 'with an additive trait' do
      let(:instance) { create(:character_instance) }

      before(:each) do
        instance.additive_swiftness = 1
      end

      it 'should be valid with correct level and experience' do
        instance.experience_amount = Character::Instance.target_experience(15)
        expect { instance.save!  }.not_to raise_error
      end

      it 'should raise error with incorrect level' do
        expect { instance.save!  }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'with wrong xp' do
      let(:instance) { create(:character_instance) }

      it 'doesn`t raise an error and applies correct level' do
        instance.experience_amount = 1500
        instance.level = 1
        expect { instance.save! }.not_to raise_error
        expect(instance.level).to eq 3
      end
    end
  end

  describe 'methods' do
    let!(:instance) { create(:character_instance) }

    context '#current_class' do
      it 'should return the special class for a starting character' do
        expect(instance.current_class).to eq(instance.special_class)
      end

      it 'should return the prestigious class for a leveled character' do
        instance.experience_amount = Character::Instance.target_experience(15)
        prestigious_class = Character::Class.where(power: instance.power, control: instance.control, swiftness: instance.swiftness + 1).first
        instance.additive_swiftness = 1
        expect { instance.save!  }.not_to raise_error
        expect(instance.current_class).to eq(prestigious_class)
      end
    end

    context '#classes' do
      it 'should return the special class for a starting character' do
        expect(instance.classes.count).to eq(1)
        expect(instance.classes.first).to eq(instance.special_class)
      end

      it 'should return two classes for a leveled character' do
        instance.experience_amount = Character::Instance.target_experience(15)
        prestigious_class = Character::Class.where(power: instance.power, control: instance.control, swiftness: instance.swiftness + 1).first
        instance.additive_swiftness = 1
        instance.save!
        expect(instance.classes.count).to eq(2)
        expect(instance.classes.first).to eq(instance.special_class)
        expect(instance.classes.last).to eq(prestigious_class)
      end
    end

    context '#modifiers' do
      let!(:instance) { create(:character_instance) }

      it 'should return the nature modifiers for a basic character' do
        modifiers = instance.modifiers

        expect(modifiers.keys.count).to eq(4)
        expect(modifiers[:constitution]).to eq(instance.nature.constitution)
        expect(modifiers[:intelligence]).to eq(instance.nature.intelligence)
        expect(modifiers[:dexterity]).to eq(instance.nature.dexterity)
        expect(modifiers[:strength]).to eq(instance.nature.strength)
      end
    end

    context '#traits' do
      let!(:instance) { 
        create(
          :character_instance,
          additive_power: 1,
          additive_control: 0,
          additive_swiftness: 0
        )
      }

      it 'should return the nature traits plus one for a basic character' do
        traits = instance.traits

        expect(traits.keys.count).to eq(3)
        expect(traits[:power]).to eq(instance.nature.power + 1)
        expect(traits[:swiftness]).to eq(instance.nature.swiftness)
        expect(traits[:control]).to eq(instance.nature.control)
      end
    end

    context '#waiting_traits?' do
      let!(:instance) { create(:character_instance) }

      it 'should be false on creation' do
        expect(instance.waiting_trait?).to eq(false)
      end

      it 'should be false under next level step' do
        instance.experience_amount = Character::Instance.target_experience(5)
        instance.save!
        expect(instance.level).to eq(5)
        expect(instance.waiting_trait?).to eq(false)
      end

      it 'should be true if level is high enough' do
        instance.experience_amount = Character::Instance.target_experience(10)
        instance.save!
        expect(instance.level).to eq(10)
        expect(instance.waiting_trait?).to eq(true)
      end

      it 'should be false if level is high enough and trait is added' do
        instance.experience_amount = Character::Instance.target_experience(10)
        instance.additive_control += 1
        instance.save!
        expect(instance.level).to eq(10)
        expect(instance.waiting_trait?).to eq(false)
      end

      it 'should be true if level is very high' do
        instance.experience_amount = Character::Instance.target_experience(15)
        instance.save!
        expect(instance.level).to eq(15)
        expect(instance.waiting_trait?).to eq(true)
      end
    end
  end
end
