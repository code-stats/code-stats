defmodule CodeStats.AdminCommands do
  @moduledoc """
  Administration commands that should be called by connecting an IEx shell
  into the instance.
  """

  alias Ecto.Changeset

  alias CodeStats.{
    Repo,
    Language,
    XP,
    User
  }

  import Ecto.Query, only: [from: 2]

  @doc """
  Make the given language an alias of the given target language.

  Moves all XP to the new language and update users' caches.
  """
  def alias_language(lang_name, target_name) do
    {:ok, language} = Language.get_or_create(lang_name)
    {:ok, target} = Language.get_or_create(target_name)

    # If target is already an alias of something, we can't do it
    if target.alias_of_id != nil do
      raise "Cannot alias to an existing alias!"
    end

    # Make language an alias of target
    language
    |> Changeset.change()
    |> Changeset.put_change(:alias_of_id, target.id)
    |> Repo.update!()

    # Set all XP that pointed at language to point at target
    from(x in XP, where: x.original_language_id == ^language.id)
    |> Repo.update_all(set: [language_id: target.id])

    id2str = fn id -> Integer.to_string(id) end

    # Update caches for all users with that language
    from(
      u in User,
      where: fragment("cache->'languages'\\??", ^id2str.(language.id)),
      update: [
        set: [
          cache:
            fragment(
              """
              jsonb_set(
                cache#-array['languages', ?],
                array['languages', ?],
                to_jsonb(
                  coalesce(
                    (cache#>>array['languages', ?])::bigint,
                    0
                  ) +
                  coalesce(
                    (cache#>>array['languages', ?])::bigint,
                    0
                  )
                ),
                true
              )
              """,
              ^id2str.(language.id),
              ^id2str.(target.id),
              ^id2str.(language.id),
              ^id2str.(target.id)
            )
          ]
        ]
    )
    |> Repo.update_all([])
  end
end
