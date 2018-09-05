class AddColumnCpfToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :cpf, :bigint
  end
end
