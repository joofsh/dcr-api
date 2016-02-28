class Response < Sequel::Model
  many_to_one :question
  many_to_one :choice
  many_to_one :client

  def self.create_or_update(client_id, question_id, choice_id)
    response = self.where(client_id: client_id, question_id: question_id).first

    if response
      # Ensures the response object is returned even if the save makes no changes
      # I.e. New & old choice are the same
      response.set(choice_id: choice_id) && response.save
    else
      self.create(client_id: client_id, question_id: question_id, choice_id: choice_id)
    end
  end
end
