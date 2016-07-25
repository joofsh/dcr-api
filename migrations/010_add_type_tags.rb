Sequel.migration do
  up do
    alter_table(:tags) do
      add_column :type, String
    end

    DB[:tags].update(type: 'Descriptor')
  end

  down do
    alter_table(:tags) do
      drop_column :type
    end
  end
end
