require "test_helper"

describe TasksController do
  let (:task) {
    Task.create name: "sample task", description: "this is an example for a test",
                completion_date: Time.now + 5.days
  }

  # Tests for Wave 1
  describe "index" do
    it "can get the index path" do
      # Act
      get tasks_path

      # Assert
      must_respond_with :success
    end

    it "can get the root path" do
      # Act
      get root_path

      # Assert
      must_respond_with :success
    end
  end

  # Unskip these tests for Wave 2
  describe "show" do
    it "can get a valid task" do
      # Act
      get task_path(task.id)

      # Assert
      must_respond_with :success
    end

    it "will redirect for an invalid task" do
      # Act
      get task_path(-1)

      # Assert
      must_respond_with :redirect
      expect(flash[:error]).must_equal "Could not find task with id: -1"
    end
  end

  describe "new" do
    it "can get the new task page" do
      # Act
      get new_task_path

      # Assert
      must_respond_with :success
    end
  end

  describe "create" do
    it "can create a new task" do

      # Arrange
      task_hash = {
        task: {
          name: "new task",
          description: "new task description",
          completion_date: nil,
        },
      }

      # Act-Assert
      expect {
        post tasks_path, params: task_hash
      }.must_change "Task.count", 1

      new_task = Task.find_by(name: task_hash[:task][:name])
      expect(new_task.description).must_equal task_hash[:task][:description]
      # expect(new_task.due_date.to_time.to_i).must_equal task_hash[:task][:due_date].to_i
      # expect(new_task.completed).must_equal task_hash[:task][:completed]

      must_respond_with :redirect
      must_redirect_to task_path(new_task.id)
    end
  end

  # Unskip and complete these tests for Wave 3
  describe "edit" do
    it "can get the edit page for an existing task" do
      get edit_task_path(task)
      must_respond_with :success
    end

    it "will respond with redirect when attempting to edit a nonexistant task" do
      get edit_task_path(3)
      must_respond_with :redirect
      must_redirect_to tasks_path
      expect(flash[:error]).must_equal "Could not find task with id: 3"
    end
  end

  # Uncomment and complete these tests for Wave 3
  describe "update" do
    # Note:  If there was a way to fail to save the changes to a task, that would be a great
    #        thing to test.
    it "can update an existing task" do
      id = Task.first.id
      task_hash = {
        task: {
          name: "update task",
          description: "update description",
          completion_date: nil,
        },
      }
      expect {
        patch task_path(id), params: task_hash
      }.wont_change "Task.count"
      task = Task.find(id)
      expect(task.name).must_equal task_hash[:task][:name]
      expect(task.description).must_equal task_hash[:task][:description]
      expect(task.completion_date).must_equal task_hash[:task][:completion_date]
    end

    it "will redirect to the root page if given an invalid id" do
      task_hash = {
        task: {
          name: "update task",
          description: "update description",
          completion_date: nil,
        },
      }
      expect {
        patch task_path(-1), params: task_hash
      }.wont_change "Task.count"
      must_respond_with :redirect
      must_redirect_to root_path
    end
    it "will not update if the params are invalid" do
      # id = Task.first.id
      # task = Task.find(id)
      # expect {
      #   patch task_path(id), params: {} <--- can not test !! #<NoMethodError: private method `require' called for {}:Hash>
      # }.wont_change "Task.count"
      # must_respond_with :error
    end
  end

  # Complete these tests for Wave 4
  describe "destroy" do
    it "can delete a task" do
      task = Task.create(name: "New Task")
      expect {
        delete task_path(task.id)
      }.must_change "Task.count", -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "will redirect to the root page if given an invalid id" do
      expect {
        delete task_path(-1)
      }.wont_change "Task.count"

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  # Complete for Wave 4
  describe "toggle_complete" do
    before do
      task = Task.create(name: "New Task for completion")
      @id = Task.last.id
      @task_todo = Task.find(@id)
    end
    it "sets completion_date == updated time when marked completed" do
      expect {
        patch mark_task_path(@task_todo)
      }.wont_change "Task.count"

      task_completed = Task.find(@id)

      expect(task_completed.completion_date.to_s).must_equal task_completed.updated_at.to_s
      must_respond_with :redirect
      must_redirect_to task_path(@id)
      expect(task_completed.name).must_equal @task_todo.name
      expect(task_completed.description).must_equal @task_todo.description
    end

    it "sets completion_date to nil when unmarked completed" do
      task_completed = @task_todo
      task_completed.update(completion_date: DateTime.current - 1)

      expect {
        patch mark_task_path(task_completed)
      }.wont_change "Task.count"

      task_todo = Task.find(@id)
      expect(task_todo.completion_date).must_be_nil
      expect(task_completed.name).must_equal @task_todo.name
      expect(task_completed.description).must_equal @task_todo.description
      must_respond_with :redirect
      must_redirect_to task_path(@id)
    end

    it "will redirect to the root page if given an invalid id" do
      expect {
        patch mark_task_path(-1)
      }.wont_change "Task.count"

      must_respond_with :redirect
      must_redirect_to task_path(-1) # this is bad becuase redirects to non-existant page, I should change design.
    end
  end
end
