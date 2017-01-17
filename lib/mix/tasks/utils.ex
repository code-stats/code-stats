defmodule CodeStats.TaskUtils do
  @moduledoc """
  Utilities for project build tasks.
  """

  require Logger

  @elixir System.find_executable("elixir")

  defmodule Program do
    @moduledoc """
    Program to execute with arguments. Name is used for prefixing logs.
    """
    defstruct [
      name: "",
      port: nil,
      pending_output: ""
    ]
  end

  @doc """
  Get configuration value.
  """
  def conf(key) when is_atom(key) do
    Application.get_env(:code_stats, key)
  end

  @doc """
  Get path to project root directory.
  """
  def proj_path() do
    Path.expand("../../..", __DIR__)
  end

  @doc """
  Get absolute path to a program in $PATH.
  """
  def exec_path(program) do
    System.find_executable(program)
  end

  @doc """
  Get absolute path to node_modules, with optional postfix.

  Postfix should have leading slash.
  """
  def node_path(postfix \\ "") do
    "#{proj_path()}/node_modules#{postfix}"
  end

  @doc """
  Run the given Mix tasks in parallel and wait for them all to stop
  before returning.

  Tasks should be tuples {task_name, args} or binaries (no args).
  """
  def run_tasks(tasks, timeout \\ 60000) do
    tasks
    |> Enum.map(fn
      task when is_binary(task) ->
        fn -> Mix.Task.run(task) end
      {task, args} ->
        fn -> Mix.Task.run(task, args) end
    end)
    |> run_funs(timeout)
  end

  @doc """
  Run the given functions in parallel and wait for them all to stop
  before returning.

  Functions can either be anonymous functions or tuples of
  {module, fun, args}.
  """
  def run_funs(funs, timeout \\ 60000) when is_list(funs) do
    funs
    |> Enum.map(fn
      fun when is_function(fun) ->
        Task.async(fun)
      {module, fun, args} ->
        Task.async(module, fun, args)
    end)
    |> Enum.map(fn task ->
      Task.await(task, timeout)
    end)
  end

  @doc """
  Start an external program with apprunner.

  Apprunner handles killing the program if BEAM is abruptly shut down.
  Name is used as a prefix for logging output.

  Options that can be given:

  - name: Use as name for logging, otherwise name of binary is used.
  - cd:   Directory to change to before executing.
  """
  def exec(executable, args, opts \\ []) do
    name = Keyword.get(
      opts,
      :name,
      (executable |> Path.rootname() |> Path.basename())
    )

    options = [
      :exit_status, # Send msg with status when command stops
      args: ["#{proj_path()}/lib/mix/tasks/apprunner.exs" | [executable | args]],
      line: 1024 # Send command output as lines of 1k length
    ]

    options = case Keyword.get(opts, :cd) do
      nil -> options
      cd -> Keyword.put(options, :cd, cd)
    end

    Logger.debug("[Started] #{name}")

    %Program{
      name: name,
      pending_output: "",
      port: Port.open(
        {:spawn_executable, @elixir},
        options
      )
    }
  end

  @doc """
  Listen to messages from programs and print them to the screen.

  Also listens to input from user and returns if input is given.
  """
  def listen(programs, task \\ nil, opts \\ [])

  def listen([], _, _), do: nil

  def listen(%Program{} = program, task, opts) do
    listen([program], task, opts)
  end

  def listen(programs, task, opts) do
    # Start another task to ask for user input if we are in watch mode
    task = with \
      true        <- Keyword.get(opts, :watch, false),
      nil         <- task,
      {:ok, task} <- Task.start_link(__MODULE__, :wait_for_input, [self()])
    do
      task
    end

    programs = receive do
      :user_input_received ->
        []

      {port, {:data, {:eol, msg}}} ->
        program = Enum.find(programs, get_port_checker(port))
        msg = :unicode.characters_to_binary(msg, :unicode)

        prefix = "[#{program.name}] #{program.pending_output}"

        Logger.debug(prefix <> msg)

        programs
        |> Enum.reject(get_port_checker(port))
        |> Enum.concat([
          %{program | pending_output: ""}
        ])

      {port, {:data, {:noeol, msg}}} ->
        program = Enum.find(programs, get_port_checker(port))
        msg = :unicode.characters_to_binary(msg, :unicode)

        programs
        |> Enum.reject(get_port_checker(port))
        |> Enum.concat([
          %{program | pending_output: "#{program.pending_output}#{msg}"}
        ])

      # Port was closed normally after being told to close
      {port, :closed} ->
        handle_closed(programs, port)

      # Port closed because the program closed by itself
      {port, {:exit_status, 0}} ->
        handle_closed(programs, port)

      # Program closed with error status
      {port, {:exit_status, status}} ->
        program = Enum.find(programs, get_port_checker(port))
        Logger.error("Program #{program.name} returned status #{status}.")
        raise "Failed status #{status} from #{program.name}!"

      # Port crashed
      {:EXIT, port, _} ->
        handle_closed(programs, port)
    end

    if not Enum.empty?(programs) do
      listen(programs, task, opts)
    end
  end

  @doc """
  Kill a running program returned by exec().
  """
  def kill(%Program{name: name, port: port}) do
    if name != nil do
      Logger.debug("[Killing] #{name}")
    end

    send(port, {self(), :close})
  end

  @doc """
  Print output from given programs to screen until user input is given.

  When user input is given, kill programs and return.
  """
  def watch(%Program{} = program), do: watch([program])

  def watch(programs) when is_list(programs) do
    Logger.info("Programs started, press ENTER to exit.")

    listen(programs, nil, watch: true)

    Logger.info("ENTER received, killing tasks.")

    Enum.each(programs, &kill/1)
    :ok
  end

  def wait_for_input(target) do
    IO.gets("")
    send(target, :user_input_received)
  end

  defp get_port_checker(port) do
    fn %Program{port: program_port} ->
      program_port == port
    end
  end

  defp handle_closed(programs, port) do
    case Enum.find(programs, get_port_checker(port)) do
      %Program{} = program ->
        Logger.debug("[Stopped] #{program.name}")

        programs
        |> Enum.reject(get_port_checker(port))

      nil ->
        # Program was already removed
        programs
    end
  end
end
