Sequel.migration do
  up do
    alter_table :choices do
      drop_foreign_key :tag_id
    end

    create_table :choices_tags do
      foreign_key :tag_id, null: false
      foreign_key :choice_id, null: false
      DateTime :created_at
      DateTime :updated_at

      primary_key [:tag_id, :choice_id]
    end
  end

  down do
    alter_table :choices do
      add_foreign_key :tag_id, :tags
    end

    drop_table :choices_tags
  end
end
