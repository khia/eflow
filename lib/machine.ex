defmodule Eflow.Machine do
  
  defexception Error, message: nil

  defmacro __using__(opts) do
    if opts == [], do: opts = [node: Eflow.Machine.Node]
    quote do
      import Eflow.Machine
      import Eflow.Machine.Node
      Module.register_attribute __MODULE__, :wrapper, persist: false, accumulate: false

      def finish(state), do: state
      defoverridable finish: 1

      def pending(state), do: :pending
      defoverridable pending: 1
    end
  end

  def machine_error(message), do: raise Error.new(message: message)
end

defmodule Eflow.Machine.Node do
  defmacro defnode(name, opts, [do: block]) do
    __defnode__(name, Keyword.put(opts, :do, block), __CALLER__)
  end
  defmacro defnode(name, opts) do
    __defnode__(name, opts, __CALLER__)
  end
  def __defnode__(name, opts, _caller) do
    pos = opts[:true] || quote do: finish
    {pos, _, _} = pos
    neg = opts[:false] || quote do: finish
    {neg, _, _} = neg
    block = opts[:do]
    quote do
      defp unquote(name) do
        {result, state} = unquote(block)
        case result do
          true -> unquote(pos).(state)
          false -> unquote(neg).(state)
        end
      end
    end
  end
end