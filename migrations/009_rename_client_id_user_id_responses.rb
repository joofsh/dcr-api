Sequel.migration do
  change do
    alter_table(:responses) do
      rename_column :client_id, :user_id
    end
  end
end
