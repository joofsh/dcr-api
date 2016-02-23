class Choice < Sequel::Model
  many_to_one :question
  many_to_one :next_question, class: :Question
  many_to_one :tag
end
