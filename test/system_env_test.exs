defmodule SystemEnvTest do
  use ExUnit.Case

  setup context do
    if env = context[:env] do
      {name, value} = env
      System.put_env(name, value)
      on_exit(fn -> System.delete_env(name) end)
    end

    :ok
  end

  describe "get_env/2" do
    test "not set" do
      assert nil == SystemEnv.get_env("VAR", :boolean)
    end

    @tag env: {"VAR", "true"}
    test "type - boolean - true" do
      assert true == SystemEnv.get_env("VAR", :boolean)
    end

    @tag env: {"VAR", "0"}
    test "type - boolean - false" do
      assert false == SystemEnv.get_env("VAR", :boolean)
    end

    @tag env: {"VAR", "10"}
    test "type - integer" do
      assert 10 == SystemEnv.get_env("VAR", :integer)
    end

    @tag env: {"VAR", "bad"}
    test "type - integer - error" do
      assert_raise SystemEnv.EnvError,
                   "environment variable VAR is provided, but the value \"bad\" is not the string representation of an integer",
                   fn ->
                     SystemEnv.get_env("VAR", :integer)
                   end
    end

    @tag env: {"VAR", "11"}
    test "type - float without a decimal point" do
      assert 11.0 == SystemEnv.get_env("VAR", :float)
    end

    @tag env: {"VAR", "11.0"}
    test "type - float with a decimal point" do
      assert 11.0 == SystemEnv.get_env("VAR", :float)
    end

    @tag env: {"VAR", "bad"}
    test "type - float - error" do
      assert_raise SystemEnv.EnvError,
                   "environment variable VAR is provided, but the value \"bad\" is not the string representation of a float",
                   fn ->
                     SystemEnv.get_env("VAR", :float)
                   end
    end

    @tag env: {"VAR", "hello"}
    test "type - string" do
      assert "hello" == SystemEnv.get_env("VAR", :string)
    end

    @tag env: {"VAR", "hello"}
    test "type - atom" do
      assert :hello == SystemEnv.get_env("VAR", :atom)
    end
  end

  describe "get_env/1" do
    @tag env: {"VAR", "hello"}
    test "type defaults to :string" do
      assert "hello" == SystemEnv.get_env("VAR")
    end
  end

  describe "fetch_env!/3" do
    test "not set" do
      assert_raise SystemEnv.EnvError,
                   "environment variable VAR is missing",
                   fn ->
                     SystemEnv.fetch_env!("VAR", :boolean)
                   end
    end

    test "not set - extra message" do
      assert_raise SystemEnv.EnvError,
                   "environment variable VAR is missing.\nSet it to something like: ecto://USER:PASS@HOST/DATABASE\n",
                   fn ->
                     SystemEnv.fetch_env!("VAR", :boolean,
                       message: "Set it to something like: ecto://USER:PASS@HOST/DATABASE"
                     )
                   end
    end

    @tag env: {"VAR", "true"}
    test "type - boolean - true" do
      assert true == SystemEnv.fetch_env!("VAR", :boolean)
    end

    @tag env: {"VAR", "0"}
    test "type - boolean - false" do
      assert false == SystemEnv.fetch_env!("VAR", :boolean)
    end

    @tag env: {"VAR", "10"}
    test "type - integer" do
      assert 10 == SystemEnv.fetch_env!("VAR", :integer)
    end

    @tag env: {"VAR", "bad"}
    test "type - integer - error" do
      assert_raise SystemEnv.EnvError,
                   "environment variable VAR is provided, but the value \"bad\" is not the string representation of an integer",
                   fn ->
                     SystemEnv.fetch_env!("VAR", :integer)
                   end
    end

    @tag env: {"VAR", "11"}
    test "type - float without a decimal point" do
      assert 11.0 == SystemEnv.fetch_env!("VAR", :float)
    end

    @tag env: {"VAR", "11.0"}
    test "type - float with a decimal point" do
      assert 11.0 == SystemEnv.fetch_env!("VAR", :float)
    end

    @tag env: {"VAR", "bad"}
    test "type - float - error" do
      assert_raise SystemEnv.EnvError,
                   "environment variable VAR is provided, but the value \"bad\" is not the string representation of a float",
                   fn ->
                     SystemEnv.fetch_env!("VAR", :float)
                   end
    end

    @tag env: {"VAR", "hello"}
    test "type - string" do
      assert "hello" == SystemEnv.fetch_env!("VAR", :string)
    end

    @tag env: {"VAR", "hello"}
    test "type - atom" do
      assert :hello == SystemEnv.fetch_env!("VAR", :atom)
    end
  end

  describe "fetch_env!/2" do
    @tag env: {"VAR", "hello"}
    test "second argument is type" do
      assert :hello == SystemEnv.fetch_env!("VAR", :atom)
    end

    test "second argument is options" do
      assert_raise SystemEnv.EnvError,
                   "environment variable VAR is missing.\nSet it to something like: ecto://USER:PASS@HOST/DATABASE\n",
                   fn ->
                     SystemEnv.fetch_env!("VAR", :boolean,
                       message: "Set it to something like: ecto://USER:PASS@HOST/DATABASE"
                     )
                   end
    end
  end

  describe "fetch_env!/1" do
    @tag env: {"VAR", "hello"}
    test "type defaults to :string" do
      assert "hello" == SystemEnv.get_env("VAR")
    end
  end
end
