Sequel.migration do
  up do
    alter_table(:resources) do
      add_column :email, String
      add_column :category, String
      add_column :description, String
      add_column :population_served, String
      add_column :note, String
      add_column :languages, String
      add_column :published, TrueClass, null: false, default: false
    end
  end

  down do
    alter_table(:resources) do
      drop_column :email
      drop_column :category
      drop_column :description
      drop_column :population_served
      drop_column :note
    end
  end
end
