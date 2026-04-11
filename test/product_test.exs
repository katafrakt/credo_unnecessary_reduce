defmodule CredoUnnecessaryReduce.ProductTest do
  use Credo.Test.Case, async: true

  alias CredoUnnecessaryReduce.Check

  describe "product" do
    test "Enum.product is good" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.product(numbers)
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
          Enum.reduce(numbers, 1, fn number, result -> number * result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 1, fn number, result -> result * number end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product instead of Enum.reduce.")
    end

    test "catches when Enum.reduce is piped" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          numbers
          |> Enum.reduce(1, fn number, result -> number * result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product instead of Enum.reduce.")
    end

    test "ok to start with a different value or use different variables" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, -1, fn i, acc -> i * acc end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 2, fn i, acc -> acc * i end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product instead of Enum.reduce.")
    end
  end

  describe "product_by" do
    test "Enum.product_by is good" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.product_by(numbers, fn number -> number * 2 end)
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
          Enum.reduce(numbers, 1, fn number, result -> (number + 2) * result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 1, fn number, result -> result * (number + 2) end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 1.0, fn number, result -> (number + 2.2) * result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 1.0, fn number, result -> result * (number + 2.2) end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product_by instead of Enum.reduce.")
    end

    test "catches when Enum.reduce is piped" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          numbers
          |> Enum.reduce(1, fn number, result -> (number + 2) * result end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product_by instead of Enum.reduce.")
    end

    test "ok to start with a different value or use different variables" do
      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, -1, fn i, acc -> (i + 4) * acc end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product_by instead of Enum.reduce.")

      """
      defmodule NeoWeb.TestModule do
        def mult(numbers) do
          Enum.reduce(numbers, 2, fn i, acc -> acc * (i + 4) end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product_by instead of Enum.reduce.")
    end

    test "complex expressions with function calls" do
      """
      defmodule NeoWeb.TestModule do
        def calculate(numbers) do
          Enum.reduce(numbers, 1, fn item, acc ->
            acc * abs(item)
          end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product_by instead of Enum.reduce.")
    end

    test "map access in mathematical operations" do
      """
      defmodule NeoWeb.TestModule do
        def calculate(items) do
          Enum.reduce(items, 1, fn item, acc ->
            acc * item.multiplier
          end)
        end
      end
      """
      |> to_source_file("lib/neo_web/test_module.ex")
      |> run_check(Check)
      |> assert_check_issue("Consider using Enum.product_by instead of Enum.reduce.")
    end

    test "item isn't referenced" do
      # You could use Enum.product / product_by maybe, but probably better
      # do not use a loop at all
      """
      defmodule NeoWeb.TestModule do
        def calculate(items) do
          Enum.reduce(items, 1, fn item, acc ->
            acc * 4.3
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
            acc * "some string"
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

  test "both operands are complex expressions (no accumulator)" do
    # This tests the {:other, :other, :mult} pattern added in PR #4
    # Neither operand is the accumulator variable, so this is not a standard
    # accumulation pattern and should not crash or trigger false positives
    """
    defmodule NeoWeb.TestModule do
      def calculate(items) do
        Enum.reduce(items, 1, fn item, _acc ->
          abs(item.x) * abs(item.y)
        end)
      end
    end
    """
    |> to_source_file("lib/neo_web/test_module.ex")
    |> run_check(Check)
    |> refute_issues()
  end

  test "accumulator multiplied by constant integer" do
    # This tests the {:acc_var, :integer, :mult} pattern
    """
    defmodule NeoWeb.TestModule do
      def calculate(items) do
        Enum.reduce(items, 1, fn _item, acc ->
          acc * 5
        end)
      end
    end
    """
    |> to_source_file("lib/neo_web/test_module.ex")
    |> run_check(Check)
    |> refute_issues()
  end
end
