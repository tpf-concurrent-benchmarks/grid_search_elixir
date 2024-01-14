defmodule ObjectiveFun do
  def griewank_fun(parameters) when is_list(parameters) do
    [a, b, c] = parameters
    (1.0 / 4000.0) * (a * a + b * b + c * c) - :math.cos(a) * :math.cos(b / :math.sqrt(2)) * :math.cos(c / :math.sqrt(3)) + 1
  end
end