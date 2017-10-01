defmodule ExCLI.DSLTest do
  use ExUnit.Case

  alias MyApp.SampleCLI
  alias ExCLI.Argument

  test "creates an app object" do
    assert function_exported?(SampleCLI, :__app__, 0)
    app = SampleCLI.__app__
    assert app.name == "mycli"
    assert app.description == "My CLI"
    assert app.long_description == "This is my long description\n"
  end

  test "generate options" do
    app = SampleCLI.__app__
    assert [%Argument{name: :verbose, aliases: [:v], count: true}] = app.options
  end

  test "generates commands" do
    app = SampleCLI.__app__
    assert [command] = app.commands
    assert command.name == :hello
    assert command.aliases == [:hi]
    assert [%Argument{name: name, help: help}] = command.options
    assert command.long_description == "Gives a nice a warm greeting to whoever would listen\n"
    assert name == :from
    assert help == "the sender of hello"
  end

  test "generates a default name" do
    defmodule MyUnnamedCLI, do: use ExCLI.DSL
    assert MyUnnamedCLI.__app__.name == "my_unnamed_cli"
  end

  test "only allow a single list argument per command" do
    bad_module = quote do
      defmodule BadCLI do
        use ExCLI.DSL
        command :foo do
          argument :abc, list: true
          argument :def, list: true
        end
      end
    end
    assert_raise ArgumentError, "cannot add an argument after a list argument", fn ->
      Code.eval_quoted(bad_module)
    end
  end

  test "mix task" do
    module = quote do
      defmodule TaskCLI do
        use ExCLI.DSL, mix_task: :foo
      end
    end
    Code.eval_quoted(module)
    assert Code.ensure_loaded?(Mix.Tasks.Foo)
    assert function_exported?(Mix.Tasks.Foo, :run, 1)
  end

  test "mix nested task" do
    module = quote do
      defmodule NestedTaskCLI do
        use ExCLI.DSL, mix_task: :'foo.bar'
      end
    end
    Code.eval_quoted(module)
    assert Code.ensure_loaded?(Mix.Tasks.Foo.Bar)
    assert function_exported?(Mix.Tasks.Foo.Bar, :run, 1)
  end

  test "escript" do
    module = quote do
      defmodule EscriptCLI do
        use ExCLI.DSL, escript: true
      end
    end
    Code.eval_quoted(module)
    assert function_exported?(EscriptCLI, :main, 1)
  end
end
