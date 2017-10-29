defmodule CodeStats.Language.AdminCommands do
  @moduledoc """
  Administration commands that should be called by connecting an IEx shell
  into the instance.
  """

  alias Ecto.Changeset

  alias CodeStats.Repo
  alias CodeStats.Language
  alias CodeStats.Language.CacheService
  alias CodeStats.User
  alias CodeStats.XP

  import Ecto.Query, only: [from: 2]

  @doc """
  Make the given language an alias of the given target language.

  Moves all XP to the new language and update users' caches.
  """
  @spec alias_language(String.t, String.t) :: nil
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

    id2str = &Integer.to_string/1

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

    # Update frontpage language caches
    CacheService.refresh_total_language_xp()
  end

  @doc """
  Remove language's alias status.

  All aliased XP will be moved back to this language.
  """
  @spec unalias_language(String.t) :: nil
  def unalias_language(lang_name) do
    {:ok, language} = Language.get_or_create(lang_name)

    if language.alias_of_id != nil do
      raise "Cannot unalias a language that is not an alias!"
    end

    # Remove language alias attribute
    language
    |> Changeset.change()
    |> Changeset.put_change(:alias_of_id, nil)
    |> Repo.update!()

    # Set all XP that was originally of this language back to this language
    from(x in XP, where: x.original_language_id == ^language.id)
    |> Repo.update_all(set: [language_id: language.id])

    # Update caches for all users (since there's no easy way to separate language points)
    (from u in User, select: u)
    |> Repo.all()
    |> Enum.each(
      fn user -> User.update_cached_xps(user, true) end
    )

    # Update frontpage language caches
    CacheService.refresh_total_language_xp()
  end
end
