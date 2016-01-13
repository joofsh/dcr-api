Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :username, size: 255, null: false, unique: true
      String :email, size: 255
      String :first_name, size: 255
      String :last_name, size: 255

      String :address, size: 255
      String :city, size: 255
      String :zipcode, size: 255

      String :phone, size: 255

      String :crypted_password, size: 192, null: true

      # for STI
      String :role, size: 255, null: false

      Integer :primary_therapist_id

      DateTime :created_at
      DateTime :updated_at
      index [:username]
      index [:email]
    end

    create_table :sessions do
      foreign_key :patient_id, :users, null: false
      foreign_key :therapist_id, :users, null: false
      DateTime :date, null: false
      Integer :duration, size: 255, null: false

      index [:therapist_id]
    end

    create_table :tokens do

      String :value, size: 255, null: false, unique: true
      Integer :user_id, size: 255, null: false, unique: true
      String :type, size: 255, null: false

      primary_key [:value]
    end
  end
end
