class AddPriorityLevelToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :priority_level, :integer
  end
end
