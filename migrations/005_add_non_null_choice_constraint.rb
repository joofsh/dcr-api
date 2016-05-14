Sequel.migration do
  up do
    alter_table(:choices) do
      set_column_not_null :question_id
    end
  end

  down do
    alter_table(:choices) do
      set_column_allow_null :question_id
    end
  end
end
