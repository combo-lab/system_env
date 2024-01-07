defmodule CozyEnvTest do
  use ExUnit.Case

  setup context do
    if env = context[:env] do
      {varname, value} = env
      System.put_env(varname, value)
      on_exit(fn -> System.delete_env(varname) end)
    end

    :ok
  end

  describe "get_env/2" do
    test "not set" do
      assert nil == CozyEnv.get_env("VAR", :boolean)
    end

    @tag env: {"VAR", "true"}
    test "type - boolean - true" do
      assert true == CozyEnv.get_env("VAR", :boolean)
    end

    @tag env: {"VAR", "0"}
    test "type - boolean - false" do
      assert false == CozyEnv.get_env("VAR", :boolean)
    end

    @tag env: {"VAR", "10"}
    test "type - integer" do
      assert 10 == CozyEnv.get_env("VAR", :integer)
    end

    @tag env: {"VAR", "bad"}
    test "type - integer - error" do
      assert_raise CozyEnv.EnvError,
                   "environment variable VAR is provided, but the value \"bad\" is not the string representation of an integer",
                   fn ->
                     CozyEnv.get_env("VAR", :integer)
                   end
    end

    @tag env: {"VAR", "11"}
    test "type - float without a decimal point" do
      assert 11.0 == CozyEnv.get_env("VAR", :float)
    end

    @tag env: {"VAR", "11.0"}
    test "type - float with a decimal point" do
      assert 11.0 == CozyEnv.get_env("VAR", :float)
    end

    @tag env: {"VAR", "bad"}
    test "type - float - error" do
      assert_raise CozyEnv.EnvError,
                   "environment variable VAR is provided, but the value \"bad\" is not the string representation of a float",
                   fn ->
                     CozyEnv.get_env("VAR", :float)
                   end
    end

    @tag env: {"VAR", "hello"}
    test "type - string" do
      assert "hello" == CozyEnv.get_env("VAR", :string)
    end

    @tag env: {"VAR", "hello"}
    test "type - atom" do
      assert :hello == CozyEnv.get_env("VAR", :atom)
    end
  end

  describe "fetch_env!/3" do
    test "not set" do
      assert_raise CozyEnv.EnvError,
                   "environment variable VAR is missing",
                   fn ->
                     CozyEnv.fetch_env!("VAR", :boolean)
                   end
    end

    test "not set - extra message" do
      assert_raise CozyEnv.EnvError,
                   "environment variable VAR is missing.\nSet it to something like: ecto://USER:PASS@HOST/DATABASE\n",
                   fn ->
                     CozyEnv.fetch_env!("VAR", :boolean,
                       message: "Set it to something like: ecto://USER:PASS@HOST/DATABASE"
                     )
                   end
    end

    @tag env: {"VAR", "true"}
    test "type - boolean - true" do
      assert true == CozyEnv.fetch_env!("VAR", :boolean)
    end

    @tag env: {"VAR", "0"}
    test "type - boolean - false" do
      assert false == CozyEnv.fetch_env!("VAR", :boolean)
    end

    @tag env: {"VAR", "10"}
    test "type - integer" do
      assert 10 == CozyEnv.fetch_env!("VAR", :integer)
    end

    @tag env: {"VAR", "bad"}
    test "type - integer - error" do
      assert_raise CozyEnv.EnvError,
                   "environment variable VAR is provided, but the value \"bad\" is not the string representation of an integer",
                   fn ->
                     CozyEnv.fetch_env!("VAR", :integer)
                   end
    end

    @tag env: {"VAR", "11"}
    test "type - float without a decimal point" do
      assert 11.0 == CozyEnv.fetch_env!("VAR", :float)
    end

    @tag env: {"VAR", "11.0"}
    test "type - float with a decimal point" do
      assert 11.0 == CozyEnv.fetch_env!("VAR", :float)
    end

    @tag env: {"VAR", "bad"}
    test "type - float - error" do
      assert_raise CozyEnv.EnvError,
                   "environment variable VAR is provided, but the value \"bad\" is not the string representation of a float",
                   fn ->
                     CozyEnv.fetch_env!("VAR", :float)
                   end
    end

    @tag env: {"VAR", "hello"}
    test "type - string" do
      assert "hello" == CozyEnv.fetch_env!("VAR", :string)
    end

    @tag env: {"VAR", "hello"}
    test "type - atom" do
      assert :hello == CozyEnv.fetch_env!("VAR", :atom)
    end
  end
end
