Sequel.migration do
  up do
    alter_table(:addresses) do
      add_column :lat, String
      add_column :lng, String
    end
  end

  down do
    alter_table(:addresses) do
      drop_column :lat
      drop_column :lng
    end
  end
end
