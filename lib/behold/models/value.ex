defmodule Behold.Models.Value do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  require Logger

  schema "values" do
    field :value, ValueType

    belongs_to :check, Behold.Models.Check
    timestamps()
  end

  def changeset(check, attrs) do
    check
    |> cast(attrs,[:value, :check_id])
    |> validate_required([
      :value,
      :check_id
    ])
  end

  def create_changeset(%Behold.Models.Value{} = model, value, check_id) do
    changeset = __MODULE__.changeset(model, %{
      value: value,
      check_id: check_id
    })
    case changeset.valid? do
      true ->
        {:ok, changeset}
      false ->
        Logger.error("#{__MODULE__}: Changeset invalid #{inspect(changeset)}")
        {:error, :changeset_invalid}
    end
  end

  def create_changeset(value, check_id) do
    changeset = __MODULE__.changeset(%__MODULE__{}, %{
      value: value,
      check_id: check_id
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
    case Behold.Repo.insert(changeset) do
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
