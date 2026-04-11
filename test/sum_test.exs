defmodule CredoUnnecessaryReduce.SumTest do
  use Credo.Test.Case, async: true

  alias CredoUnnecessaryReduce.Check

  describe "sum: +" do
    test "Enum.sum is good" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.sum(numbers)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> refute_issues()
    end

    test "Enum.reduce, oh no!" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0, fn number, result -> number + result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0, fn number, result -> result + number end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum instead of Enum.reduce.")
    end

    test "ok to start with a different value or use different variables" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, -1, fn i, acc -> i + acc end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 2, fn i, acc -> acc + i end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum instead of Enum.reduce.")
    end

    test "catches when Enum.reduce is piped" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          numbers |> Enum.reduce(0, fn number, result -> number + result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum instead of Enum.reduce.")
    end
  end

  describe "sum_by: +" do
    test "Enum.sum_by is good" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.sum_by(numbers, fn number -> number * 2 end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> refute_issues()
    end

    test "Enum.reduce, oh no!" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0, fn number, result -> (number * 2) + result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0, fn number, result -> result + (number * 2) end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0.0, fn number, result -> (number * 2.2) + result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0.0, fn number, result -> result + (number * 2.2) end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")
    end

    test "other code in the function" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0, fn number, result ->
            intermediate = number / 3

            side_effect_fn(intermediate)

            (intermediate * 2) + result
          end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0, fn number, result ->
            intermediate = number / 3

            side_effect_fn(intermediate)

            result + (intermediate * 2)
          end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")
    end

    test "ok to start with a different value or use different variables" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, -1, fn i, acc -> (i + 4) + acc end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 2, fn i, acc -> acc + (i + 4) end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")
    end

    test "catches when Enum.reduce is piped" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          numbers |> Enum.reduce(0, fn number, result -> (number * 2) + result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")
    end

    test "complex expressions with function calls" do
      # acc + function_call(item)
      """
      defmodule NeoWeb.TestModule do
        def calculate(numbers) do
          Enum.reduce(numbers, 0, fn item, acc ->
            acc + String.length(to_string(item))
          end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")

      # function_call(item) + acc
      """
      defmodule NeoWeb.TestModule do
        def calculate(numbers) do
          Enum.reduce(numbers, 0, fn item, acc ->
            String.length(to_string(item)) + acc
          end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")
    end

    test "map access in mathematical operations" do
      """
      defmodule NeoWeb.TestModule do
        def calculate(items) do
          Enum.reduce(items, 0, fn item, acc ->
            acc + item.value
          end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")
    end
  end

  describe "sum: -" do
    test "Enum.sum is good" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.sum(numbers)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> refute_issues()
    end

    test "Enum.reduce, oh no!" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0, fn number, result -> number - result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0, fn number, result -> result - number end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum instead of Enum.reduce.")
    end

    test "ok to start with a different value or use different variables" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, -1, fn i, acc -> i - acc end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 2, fn i, acc -> acc - i end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum instead of Enum.reduce.")
    end

    test "catches when Enum.reduce is piped" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          numbers |> Enum.reduce(0, fn number, result -> number - result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum instead of Enum.reduce.")
    end
  end

  describe "sum_by: -" do
    test "Enum.sum_by is good" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.sum_by(numbers, fn number -> number * 2 end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> refute_issues()
    end

    test "Enum.reduce, oh no!" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0, fn number, result -> (number * 2) - result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0, fn number, result -> result - (number * 2) end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0.0, fn number, result -> (number * 2.2) - result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 0.0, fn number, result -> result - (number * 2.2) end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")
    end

    test "ok to start with a different value or use different variables" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, -1, fn i, acc -> (i + 4) - acc end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 2, fn i, acc -> acc - (i + 4) end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")
    end

    test "catches when Enum.reduce is piped" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          numbers |> Enum.reduce(0, fn number, result -> (number * 2) - result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")
    end

    test "complex expressions with function calls" do
      """
      defmodule NeoWeb.TestModule do
        def calculate(numbers) do
          Enum.reduce(numbers, 100, fn item, acc ->
            acc - abs(item)
          end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.sum_by instead of Enum.reduce.")
    end
  end

  test "Non sum or product cases" do
    """
    defmodule NeoWeb.TestModule do
      def mult(numbers) do
        Enum.reduce(numbers, 0.0, fn number, result -> result / (number * 2.2) end)
      end
    end
    """
    |> to_source_file("lib/neo_web/test_module.ex")
    |> run_check(Check)
    |> refute_issues()

    """
    defmodule NeoWeb.TestModule do
      def mult(numbers) do
        Enum.reduce(numbers, -1, fn i, acc -> (i + 4) / acc end)
      end
    end
    """
    |> to_source_file("lib/neo_web/test_module.ex")
    |> run_check(Check)
    |> refute_issues()

    """
    defmodule NeoWeb.TestModule do
      def mult(numbers) do
        Enum.reduce(numbers, 2, fn i, acc -> acc / (i + 4) end)
      end
    end
    """
    |> to_source_file("lib/neo_web/test_module.ex")
    |> run_check(Check)
    |> refute_issues()
  end

  test "item isn't referenced" do
    # You could use Enum.sum / sum_by maybe, but probably better
    # do not use a loop at all
    """
    defmodule NeoWeb.TestModule do
      def calculate(items) do
        Enum.reduce(items, 1, fn item, acc ->
          acc + 4.3
        end)
      end
    end
    """
    |> to_source_file("lib/neo_web/test_module.ex")
    |> run_check(Check)
    |> refute_issues()

    """
    defmodule NeoWeb.TestModule do
      def calculate(items) do
        Enum.reduce(items, 1, fn item, acc ->
          acc + "some string"
        end)
      end
    end
    """
    |> to_source_file("lib/neo_web/test_module.ex")
    |> run_check(Check)
    |> refute_issues()
  end

  test "both operands are complex expressions (no accumulator)" do
    # This tests the {:other, :other, :addition} pattern added in PR #4
    # Neither operand is the accumulator variable, so this is not a standard
    # accumulation pattern and should not crash or trigger false positives
    """
    defmodule NeoWeb.TestModule do
      def calculate(items) do
        Enum.reduce(items, 0, fn item, _acc ->
          String.length(item.name) + abs(item.value)
        end)
      end
    end
    """
    |> to_source_file("lib/neo_web/test_module.ex")
    |> run_check(Check)
    |> refute_issues()
  end

  def assert_check_issue(code, message) do
    code
    |> assert_issue(fn issue ->
      assert issue.message == message
      assert issue.category == :refactor
    end)
  end
end
