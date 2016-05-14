Sequel.migration do
  up do
    alter_table(:resources) do
      rename_column :category, :old_category
      add_column :category, 'text[]'
    end

    DB[:resources].update(category: Sequel.pg_array([:old_category]))

    alter_table(:resources) do
      drop_column :old_category
    end
  end

  down do
    alter_table(:resources) do
      rename_column :category, :old_category
      add_column :category, 'text'
    end

    update_sql = <<-EOSQL
      UPDATE resources r
      SET category = old_category[1]
    EOSQL

    DB.run update_sql

    alter_table(:resources) do
      drop_column :old_category
    end
  end
end
