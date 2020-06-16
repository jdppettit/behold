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
    field :last_alerted_for, CheckStateTypes
    field :unique_id, :string

    has_many :alerts, Behold.Models.Alert

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
      :unique_id
    ])
    |> unique_constraint(:unique_id)
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
      {:error, %{errors: [
        unique_id: {"has already been taken", [
          constraint: :unique, constraint_name: "checks_unique_id_index"
        ]
      }]}} ->
        Logger.error("#{__MODULE__}: Rejecting changeset because unique_id already exists")
        {:error, :unique_id_invalid}
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
      _error ->
        {:error, :database_error}
    end
  end

  def get_all_valid_checks(:preload) do
    query = from checks in __MODULE__,
      where: checks.id >= ^1

    case Behold.Repo.all(query) do
      [_ | _] = checks ->
        {:ok, checks |> Behold.Repo.preload(:alerts)}
      [] = checks ->
        {:ok, checks}
      _error ->
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
        Logger.info("#{__MODULE__}: Updating check #{check.id} with status #{new_state}")
        {code, _} = Behold.Repo.update(changeset)
        Logger.info("#{__MODULE__}: Check #{check.id} got #{inspect(code)} updating state")
        code
      false ->
        :error
    end
  end

  def update_last_alerted(check, last_alerted) do
    check_struct = struct(%__MODULE__{}, check)
    changeset = __MODULE__.changeset(check_struct, %{
      last_alerted_for: last_alerted
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

  def get_by_id(id, :preload) do
    case Behold.Repo.get(__MODULE__, id) do
      nil ->
        {:error, :not_found}
      model ->
        {:ok, model |> Behold.Repo.preload(:alerts)}
    end
  end

  def delete_by_id(id) do
    Behold.Repo.transaction(fn ->
      {:ok, model} = get_by_id(id)
      {:ok, nil} = Behold.Models.Value.delete_by_check_id(id)
      case Behold.Models.Alert.get_by_id(id) do
        {:ok, alerts} ->
          alerts
          |> Enum.map(fn alert ->
            {:ok, _} = Behold.Models.Alert.delete_by_id(alert.id)
          end)
        {:error, :not_found} ->
          nil
      end
      Behold.Repo.delete(model)
    end)
    {:ok, nil}
  end
end
