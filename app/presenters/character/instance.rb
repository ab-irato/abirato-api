# frozen_string_literal: true
module ApiPresenter

  class Character::Instance
    class << self
      def format(instance)
        return {} if instance.nil?
        res = {
          name: instance.name,
          level: instance.level,
          experience_amount: instance.experience_amount,
          nature: instance.character_nature_id,
          template: instance.character_template_id,
        }
        res[:traits] = instance.traits
        res[:modifiers] = instance.modifiers
        res[:classes] = []
        instance.classes.each do |c|
          res[:classes] << {
            name: c.name,
            category: c.type
          }
        end
      end
    end
  end
end