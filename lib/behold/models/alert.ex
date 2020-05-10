defmodule Behold.Models.Alert do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  require Logger

  schema "alerts" do
    field :target, :string
    field :type, AlertType
    field :last_sent, :utc_datetime
    field :interval, :integer

    belongs_to :check, Behold.Models.Check

    timestamps()
  end

  def changeset(alert, attrs) do
    alert
    |> cast(attrs, __schema__(:fields))
    |> validate_required([
      :target, :type, :interval
    ])
  end

  def create_changeset(%__MODULE__{} = model,
    type, target, interval, check_id, last_sent
  ) do
    changeset = __MODULE__.changeset(model, %{
      type: type,
      last_sent: last_sent,
      check_id: check_id,
      target: target,
      interval: interval
    })
    case changeset.valid? do
      true ->
        {:ok, changeset}
      false ->
        Logger.error("#{__MODULE__}: Changeset invalid #{inspect(changeset)}")
        {:error, :changeset_invalid}
    end
  end

  def create_changeset(type, target, interval, check_id, last_sent) do
    changeset = __MODULE__.changeset(%__MODULE__{}, %{
      type: type,
      last_sent: last_sent,
      interval: interval,
      check_id: check_id,
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

  def get_all_valid_alerts() do
    Behold.Repo.all(__MODULE__) |> IO.inspect(label: "from model")
  end

  def get_all_valid_alerts(check_id) do
    query = from alerts in __MODULE__,
      where: alerts.check_id == ^check_id

    case Behold.Repo.all(query) do
      [_ | _] = alerts ->
        {:ok, alerts}
      [] = alerts ->
        {:ok, alerts}
      error ->
        {:error, :database_error}
    end
  end

  def update_last_sent(alert, new_date) do
    changeset = __MODULE__.changeset(alert, %{
      last_sent: new_date
    })
    Behold.Repo.update(changeset)
  end

  def get_by_id(id) do
    case Behold.Repo.get(__MODULE__, id) do
      nil ->
        {:error, :not_found}
      model ->
        {:ok, model}
    end
  end

  def delete_by_id(id) do
    case get_by_id(id) do
      {:ok, model} ->
        Behold.Repo.delete(id)
        {:ok, nil}
      {:error, :not_found} ->
        {:error, :not_found}
      error ->
        {:error, :database_error}
    end
  end
end
