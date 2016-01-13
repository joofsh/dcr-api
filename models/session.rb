class Session < Sequel::Model
  many_to_one :patient
  many_to_one :therapist
  #one_to_many :notes
end
