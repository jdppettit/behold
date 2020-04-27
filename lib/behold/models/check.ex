defmodule Behold.Models.Check do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger

  defmodule CheckTypes do
    use EctoEnum, http: 1, ping: 2, http_json: 3
  end

  schema "checks" do
    field :type, CheckTypes
    field :value, :string
    field :interval, :integer
    field :target, :string
  end

  def changeset(check, attrs) do
    check
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :type,
      :value,
      :interval,
      :target
    ])
  end

  def create_changeset(%Behold.Models.Check{} = model, type, value, interval, target) do
    changeset = __MODULE__.changeset(model, %{
      type: type,
      value: value,
      interval: interval,
      target: target
    })
    case changeset.valid? do
      true ->
        {:ok, changeset}
      false ->
        Logger.error("#{__MODULE__}: Changeset invalid #{inspect(changeset)}")
        {:error, :changeset_invalid}
    end
  end

  def create_changeset(type, value, interval, target) do
    changeset = __MODULE__.changeset(__MODULE__, %{
      type: type,
      value: value,
      interval: interval,
      target: target
    })
    case changeset.valid? do
      true ->
        {:ok, changeset}
      false ->
        Logger.error("#{__MODULE__}: Changeset invalid #{inspect(changeset)}")
        {:error, :changeset_invalid}
    end
  end

  def insert(changeset) do
    case Mood.Repo.insert(changeset) do
      {:ok, model} ->
        {:ok, model}
      {:error, %{errors: [email: {"has already been taken", []}]}} ->
        Logger.error("#{__MODULE__}: Failed to insert record because of duplicate email")
        {:error, :duplicate_email}
      {_, _} ->
        Logger.error("#{__MODULE__}: Problem inserting record #{inspect(changeset)}")
        {:error, :database_error}
    end
  end
end
