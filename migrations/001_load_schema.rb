Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :username, size: 255, unique: true
      String :email, size: 255, unique: true
      String :first_name, size: 255, null: false
      String :last_name, size: 255, null: false

      String :phone, size: 255
      String :gender, size: 255
      String :sexual_orientation, size: 255
      String :language, size: 255
      String :race, size: 255
      Boolean :hiv_positive, default: false
      Date :birthdate

      String :crypted_password, size: 192, null: true

      # for STI
      String :role, size: 255, null: false

      Integer :advocate_id

      DateTime :created_at
      DateTime :updated_at
      index [:username]
      index [:email]
    end

    create_table :addresses do
      primary_key :id

      String :address, size: 255
      String :address_2, size: 255
      String :city, size: 255
      String :state, size: 255
      String :zipcode, size: 255
    end

    create_table :questions do
      primary_key :id

      Integer :order
      String :stem, null: false
    end

    create_table :choices do
      primary_key :id

      String :stem, size: 255
      String :attribute, size: 255
      String :attribute_value, size: 255
      Integer :question_id
      Integer :next_question_id
    end

    create_table :responses do
      primary_key :id

      Integer :choice_id
      Integer :user_id
    end



    create_table :tokens do

      String :value, size: 255, null: false, unique: true
      Integer :user_id, size: 255, null: false, unique: true
      String :type, size: 255, null: false

      primary_key [:value]
    end
  end
end
