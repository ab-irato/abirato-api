class Character::Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include Character::Event::ValidationConcern
  include Character::Event::RelationsConcern

  after_create :apply_event_data

  field :character_instance_id, type: Integer
  field :event_type, type: String
  field :event_date, type: DateTime
  field :event_data, type: Hash

  index({ character_instance_id: 1 }, unique: true)

  private

  def apply_event_data
    case event_type
    when EXPERIENCE_TYPE
      character_instance.experience_amount += event_data[:amount] if event_data
      character_instance.save!
    end
  end
end
