require_relative './user'

class Client < User
  many_to_one :advocate, class: :Advocate
  one_to_many :responses

  def users_dataset
    User.dataset.nullify
  end

  # TODO: Refactor this. Needs to become a lot more sophisticated
  # and faster.
  def resources
    @resources ||= begin
      resources = []
      tag_count = tags.count

      tags.each do |tag|
        if tag_count == 1
          resources << tag.resources_dataset.limit(5).all
        elsif tag_count == 2
          resources << tag.resources_dataset.limit(3).all
        else
          resources << tag.resources_dataset.limit(2).all
        end
      end

      resources.flatten
    end
  end

  def questions_dataset
    Question.dataset.order(Sequel.asc(:order))
  end
end
