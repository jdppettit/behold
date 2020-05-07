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

  def create_changeset(%Behold.Models.Alert{} = model,
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

  def insert(changeset) do
    case Behold.Repo.insert(changeset) do
      {:ok, model} ->
        {:ok, model}
      {_, _} ->
        Logger.error("#{__MODULE__}: Problem inserting record #{inspect(changeset)}")
        {:error, :database_error}
    end
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
    IO.inspect("doing update on alert")
    changeset = __MODULE__.changeset(alert, %{
      last_sent: new_date
    })
    Behold.Repo.update(changeset)
  end
end
