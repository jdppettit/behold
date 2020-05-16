defmodule Behold.Models.Value do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  require Logger

  alias Observer.Common.Common

  schema "values" do
    field :value, ValueType
    field :returned_value, :string

    belongs_to :check, Behold.Models.Check
    timestamps()
  end

  def changeset(check, attrs) do
    check
    |> cast(attrs, __schema__(:fields))
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

  def create_changeset(value, check_id, returned_value) do
    changeset = __MODULE__.changeset(%__MODULE__{}, %{
      value: value,
      check_id: check_id,
      returned_value: Common.convert_to_string(returned_value)
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
      {_, _} ->
        Logger.error("#{__MODULE__}: Problem inserting record #{inspect(changeset)}")
        {:error, :database_error}
    end
  end

  def get_recent_values_by_check_id(id, threshold \\ 3) do
    query = from values in __MODULE__,
      where: values.check_id == ^id,
      order_by: [desc: values.inserted_at],
      limit: ^threshold

    case Behold.Repo.all(query) do
      [_ | _] = values ->
        {:ok, values}
      [] = values ->
        {:ok, values}
      _error ->
        {:error, :database_error}
    end
  end

  def delete_by_check_id(check_id) do
    query = from values in __MODULE__,
      where: values.check_id == ^check_id

    Behold.Repo.all(query)
    |> Enum.map(fn f ->
      Behold.Repo.delete(f)
    end)
    {:ok, nil}
  end

  def get_by_check_id(check_id, last \\ 10) do 
    query = from values in __MODULE__,
      where: values.check_id == ^check_id,
      order_by: [desc: values.inserted_at],
      limit: ^last

    case Behold.Repo.all(query) do
      [_ | _] = values ->
        {:ok, values}
      [] = values ->
        {:ok, values}
      _error ->
        {:error, :database_error}
    end
  end
end
