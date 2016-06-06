Sequel.migration do
  change do
    alter_table(:choices) do
      add_column :deleted_at, DateTime, default: Time.at(0)
    end

    alter_table(:questions) do
      add_column :deleted_at, DateTime, default: Time.at(0)
      add_column :category, String
    end
  end
end
