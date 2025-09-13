defmodule SystemEnv do
  @moduledoc """
  Helpers for handling OS environment variables.

  It helps to:

    * cast values of environment variables
    * provide user-friendly error messages

  """

  alias SystemEnv.EnvError

  @type data_type ::
          :boolean
          | :integer
          | :float
          | :string
          | :atom

  @type result ::
          boolean()
          | integer()
          | float()
          | String.t()
          | atom()

  @type option :: {:message, String.t()}
  @type options :: [option()]

  @supported_types [
    :boolean,
    :integer,
    :float,
    :string,
    :atom
  ]

  @doc """
  Gets the value of the given environment variable, and casts it into given type.

  If the environment variable is not set, returns `nil`.

  ## Examples

      iex> SystemEnv.get_env("NOT_SET", :boolean)
      nil

      # export PHX_SERVER=true
      iex> SystemEnv.get_env("PHX_SERVER", :boolean)
      true

      # export DB_POOL_SIZE=10
      iex> SystemEnv.get_env("DB_POOL_SIZE", :integer)
      10

      # export PERCENT=0.95
      iex> SystemEnv.get_env("PERCENT", :float)
      0.95

      # export USER=billy
      iex> SystemEnv.get_env("USER", :string)
      "billy"

      # export USER=billy
      iex> SystemEnv.get_env("USER", :atom)
      :billy

  """
  @spec get_env(String.t(), data_type()) :: result()
  def get_env(name, type)
      when is_binary(name) and type in @supported_types do
    case System.fetch_env(name) do
      {:ok, value} ->
        apply(__MODULE__, :"to_#{type}", [name, value])

      :error ->
        nil
    end
  end

  @spec get_env(String.t()) :: String.t()
  def get_env(name), do: get_env(name, :string)

  @doc """
  Gets the value of the given environment variable, and casts it into given type.

  If the environment variable is not set, raises an error.

  ## Examples

      iex> SystemEnv.fetch_env!("NOT_SET", :boolean)
      ** (SystemEnv.EnvError) environment variable NOT_SET is missing
          (system_env) lib/system_env.ex:134: SystemEnv.fetch_env!/3
          iex:1: (file)

      # export PHX_SERVER=true
      iex> SystemEnv.fetch_env!("PHX_SERVER", :boolean)
      true

      # export DB_POOL_SIZE=10
      iex> SystemEnv.fetch_env!("DB_POOL_SIZE", :integer)
      10

      # export PERCENT=0.95
      iex> SystemEnv.fetch_env!("PERCENT", :float)
      0.95

      # export USER=billy
      iex> SystemEnv.fetch_env!("USER", :string)
      "billy"

      # export USER=billy
      iex> SystemEnv.fetch_env!("USER", :atom)
      :billy

      # pass extra message
      iex> SystemEnv.fetch_env!(
      ...>   "DATABASE_URL",
      ...>   "Set it to something like: ecto://USER:PASS@HOST/DATABASE"
      ...> )
      ** (SystemEnv.EnvError) environment variable DATABASE_URL is missing. Set it to something like: ecto://USER:PASS@HOST/DATABASE
          (system_env) lib/system_env.ex:134: SystemEnv.fetch_env!/3
          iex:1: (file)

  """
  @spec fetch_env!(String.t(), data_type(), options()) :: result()
  def fetch_env!(name, type, opts)
      when is_binary(name) and type in @supported_types and is_list(opts) do
    case System.fetch_env(name) do
      {:ok, value} ->
        apply(__MODULE__, :"to_#{type}", [name, value])

      :error ->
        default_message = "environment variable #{name} is missing"
        extra_message = Keyword.get(opts, :message)

        message =
          if extra_message do
            """
            #{default_message}.
            #{extra_message}
            """
          else
            default_message
          end

        raise EnvError, message
    end
  end

  def fetch_env!(name, type_or_opts)

  @spec fetch_env!(String.t(), data_type()) :: result()
  def fetch_env!(name, type) when is_binary(name) and is_atom(type) do
    fetch_env!(name, type, [])
  end

  @spec fetch_env!(String.t(), options()) :: String.t()
  def fetch_env!(name, opts) when is_binary(name) and is_list(opts) do
    fetch_env!(name, :string, opts)
  end

  @spec fetch_env!(String.t()) :: String.t()
  def fetch_env!(name) when is_binary(name) do
    fetch_env!(name, :string, [])
  end

  @doc false
  def to_boolean(_name, "false"), do: false
  def to_boolean(_name, "0"), do: false
  def to_boolean(_name, ""), do: false
  def to_boolean(_name, _), do: true

  @doc false
  def to_integer(name, value) do
    case Integer.parse(value) do
      {integer, ""} ->
        integer

      _ ->
        raise EnvError,
              "environment variable #{name} is provided, but the value " <>
                "#{inspect(value)} is not the string representation of an integer"
    end
  end

  @doc false
  def to_float(name, value) do
    case Float.parse(value) do
      {float, ""} ->
        float

      _ ->
        raise EnvError,
              "environment variable #{name} is provided, but the value " <>
                "#{inspect(value)} is not the string representation of a float"
    end
  end

  @doc false
  def to_string(_name, value), do: value

  @doc false
  def to_atom(_name, value), do: String.to_atom(value)
end

defmodule SystemEnv.EnvError do
  defexception [:message]
end
