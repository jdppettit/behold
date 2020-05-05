defmodule Behold.Models.Alert do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  require Logger

  schema "alerts" do
    field :target, :string
    field :type, AlertType
    field :last_sent, :date
    field :interval, :integer

    belongs_to :check, Behold.Models.Check

    timestamps()
  end

  def changeset(alert, attrs) do
    alert
    |> cast(attrs, __schema__(:fields))
    |> validate_required(__schema__(:fields))
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
end
