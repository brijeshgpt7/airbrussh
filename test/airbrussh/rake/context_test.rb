require "minitest_helper"
require "airbrussh/rake/context"

class Airbrussh::Rake::ContextTest < Minitest::Test
  include RakeTaskDefinition

  def setup
    @config = Airbrussh::Configuration.new
  end

  def teardown
    Airbrussh::Rake::Context.current_task_name = nil
  end

  def test_current_task_name_is_nil_when_disabled
    @config.monkey_patch_rake = false
    context = Airbrussh::Rake::Context.new(@config)
    define_and_execute_rake_task("one") do
      assert_nil(context.current_task_name)
    end
  end

  def test_current_task_name
    @config.monkey_patch_rake = true
    context = Airbrussh::Rake::Context.new(@config)

    assert_nil(context.current_task_name)

    define_and_execute_rake_task("one") do
      assert_equal("one", context.current_task_name)
    end

    define_and_execute_rake_task("two") do
      assert_equal("two", context.current_task_name)
    end
  end

  def test_decorate_command
    @config.monkey_patch_rake = true
    context = Airbrussh::Rake::Context.new(@config)

    define_and_execute_rake_task("one") do
      context.decorate_command(:command_one)
      command_one = context.decorate_command(:command_one)
      context.decorate_command(:command_two)
      command_two = context.decorate_command(:command_two)

      assert_equal(0, command_one.position)
      assert_equal(1, command_two.position)
      refute(command_one.first_execution?)
      refute(command_two.first_execution?)
    end

    define_and_execute_rake_task("two") do
      command_three = context.decorate_command(:command_three)
      command_four = context.decorate_command(:command_four)

      assert_equal(0, command_three.position)
      assert_equal(1, command_four.position)
      assert(command_three.first_execution?)
      assert(command_four.first_execution?)
    end
  end
end
