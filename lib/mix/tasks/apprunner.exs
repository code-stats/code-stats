defmodule AppRunner do
  def wait_for_eof() do
    case IO.getn("", 1024) do
      :eof -> nil
      _ -> wait_for_eof()
    end
  end

  def exec(program, args) do
    Port.open(
      {:spawn_executable, program},
      [
        :exit_status,
        :stderr_to_stdout, # Redirect stderr to stdout to log properly
        args: args,
        line: 1024
      ]
    )
  end

  def get_pid(port) do
    case Port.info(port) do
      nil ->
        nil

      info when is_list(info) ->
        case Keyword.get(info, :os_pid) do
          nil -> nil
          pid -> Integer.to_string(pid)
        end
    end
  end

  def kill(pid) do
    System.find_executable("kill") |> System.cmd([pid])
  end

  def wait_loop(port) do
    receive do
      {_, {:data, {:eol, msg}}} ->
        msg |> :unicode.characters_to_binary(:unicode) |> IO.puts()

      {_, {:data, {:noeol, msg}}} ->
        msg |> :unicode.characters_to_binary(:unicode) |> IO.write()

      {_, :eof_received} ->
        get_pid(port) |> kill()
        :erlang.halt(0)

      {_, :closed} ->
        :erlang.halt(0)

      {_, {:exit_status, status}} ->
        :erlang.halt(status)

      {:EXIT, _, _} ->
        :erlang.halt(1)
    end

    wait_loop(port)
  end
end

[program | args] = System.argv()
port = AppRunner.exec(program, args)

Task.async(fn ->
  AppRunner.wait_for_eof()
  :eof_received
end)

AppRunner.wait_loop(port)
