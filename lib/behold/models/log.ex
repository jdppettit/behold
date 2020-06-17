defmodule Behold.Models.Log do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  require Logger

  schema "logs" do
    field :type, LogTypes
    field :result, :string
    field :target_id, :integer
    field :target_type, LogTargetTypes

    timestamps()
  end

  def changeset(check, attrs) do
    check
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :type,
      :result,
      :target_id,
      :target_type
    ])
  end

  def create_changeset(map) do
    changeset = __MODULE__.changeset(%__MODULE__{}, map)
    case changeset.valid? do
      true ->
        {:ok, changeset}
      false ->
        Logger.error("#{__MODULE__}: Changeset invalid #{inspect(changeset)}")
        {:error, :changeset_invalid}
    end
  end

  def create_changeset(model, map) do
    changeset = __MODULE__.changeset(model, map)
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
      {_, _} ->
        Logger.error("#{__MODULE__}: Problem inserting record #{inspect(changeset)}")
        {:error, :database_error}
    end
  end

  def update(changeset) do
    case Behold.Repo.update(changeset) do
      {:ok, model} ->
        {:ok, model}
      {_, _} ->
        Logger.error("#{__MODULE__}: Problem updating record #{inspect(changeset)}")
        {:error, :database_error}
    end
  end
end