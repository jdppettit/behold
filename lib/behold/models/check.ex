defmodule Behold.Models.Check do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  require Logger

  schema "checks" do
    field :type, CheckTypes
    field :value, :string
    field :interval, :integer
    field :target, :string
    field :state, CheckStateTypes
    field :name, :string
    field :operation, CheckOperationTypes
    field :comparison, :string

    timestamps()
  end

  def changeset(check, attrs) do
    check
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :type,
      :value,
      :interval,
      :target,
    ])
  end

  def create_changeset(%__MODULE__{} = model, type, value, interval, target) do
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
    changeset = __MODULE__.changeset(%__MODULE__{}, %{
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

  def get_all_valid_checks() do
    query = from checks in __MODULE__,
      where: checks.id >= ^1

    case Behold.Repo.all(query) do
      [_ | _] = checks ->
        {:ok, checks}
      [] = checks ->
        {:ok, checks}
      error ->
        {:error, :database_error}
    end
  end

  def update_check_state(check, new_state) do
    check_struct = struct(%__MODULE__{}, check)
    changeset = __MODULE__.changeset(check_struct, %{
      state: new_state
    })
    case changeset.valid? do
      true ->
        Behold.Repo.update(changeset)
        :ok
      false ->
        :error
    end
  end

  def get_by_id(id) do
    case Behold.Repo.get(__MODULE__, id) do
      nil ->
        {:error, :not_found}
      model ->
        {:ok, model}
    end
  end
end
