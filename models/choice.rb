class Choice < Sequel::Model
  plugin :association_pks

  many_to_one :question
  many_to_one :next_question, class: :Question
  many_to_many :tags

  presented_methods :tags

  add_association_dependencies tags: :nullify
end
