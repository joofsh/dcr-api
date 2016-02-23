Sequel.migration do
  change do
    create_table :addresses do
      primary_key :id

      String :street
      String :street_2
      String :city
      String :state
      String :zipcode

      DateTime :created_at
      DateTime :updated_at
    end

    create_table :users do
      primary_key :id
      String :username, unique: true
      String :email, unique: true
      String :first_name, null: false
      String :last_name, null: false

      String :phone
      String :gender
      String :sexual_orientation
      String :language
      String :race
      Boolean :hiv_positive, default: false
      Date :birthdate

      String :crypted_password, null: true

      # for STI
      String :role, null: false

      foreign_key :advocate_id, :users, deferrable: true
      foreign_key :mailing_address_id, :addresses, deferrable: true
      foreign_key :home_address_id, :addresses, deferrable: true

      DateTime :created_at
      DateTime :updated_at
      index [:username]
      index [:email]
    end

    create_table :tokens do
      String :value, null: false, unique: true
      Integer :user_id, null: false, unique: true
      String :type, null: false
      DateTime :created_at
      DateTime :updated_at

      primary_key [:value]
    end

    create_table :resources do
      primary_key :id
      String :operating_hours
      String :phone
      String :title, null: false
      String :url
      String :image_url
      foreign_key :address_id, :addresses, deferrable: true

      DateTime :created_at
      DateTime :updated_at
    end

    create_table :tags do
      primary_key :id
      String :name, null: false, unique: true
      Float :weight
      DateTime :created_at
      DateTime :updated_at

      index :name, unique: true
    end

    create_table :questions do
      primary_key :id

      Integer :order
      String :stem, null: false
      DateTime :created_at
      DateTime :updated_at
    end

    create_table :choices do
      primary_key :id

      String :stem
      foreign_key :tag_id, :tags, deferrable: true
      foreign_key :question_id, :questions, deferrable: true
      foreign_key :next_question_id, :questions, deferrable: true

      DateTime :created_at
      DateTime :updated_at
    end

    create_table :responses do
      primary_key :id

      foreign_key :choice_id, :choices, deferrable: true
      foreign_key :question_id, :questions, deferrable: true
      foreign_key :client_id, :users, deferrable: true

      DateTime :created_at
      DateTime :updated_at
    end

    create_table :tags_users do
      foreign_key :tag_id, null: false
      foreign_key :user_id, null: false
      DateTime :created_at
      DateTime :updated_at
      primary_key [:tag_id, :user_id]
    end

    create_table :resources_tags do
      foreign_key :tag_id, null: false
      foreign_key :resource_id, null: false
      DateTime :created_at
      DateTime :updated_at

      primary_key [:tag_id, :resource_id]
    end
  end
end
