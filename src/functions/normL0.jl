# L0 pseudo-norm (times a constant)

export NormL0

"""
**``L_0`` pseudo-norm**

    NormL0(λ=1.0)

Returns the function
```math
f(x) = λ\\cdot\\mathrm{nnz}(x)
```
for a nonnegative parameter `λ`.
"""

immutable NormL0{R <: Real} <: ProximableFunction
  lambda::R
  function NormL0{R}(lambda::R) where {R <: Real}
    if lambda < 0
      error("parameter λ must be nonnegative")
    else
      new(lambda)
    end
  end
end

NormL0{R <: Real}(lambda::R=1.0) = NormL0{R}(lambda)

function (f::NormL0){T <: RealOrComplex}(x::AbstractArray{T})
  return f.lambda*countnz(x)
end

function prox!{T <: RealOrComplex}(y::AbstractArray{T}, f::NormL0, x::AbstractArray{T}, gamma::Real=1.0)
  countnzy = 0;
  gl = gamma*f.lambda
  for i in eachindex(x)
    over = abs(x[i]) > sqrt(2*gl);
    y[i] = over*x[i];
    countnzy += over;
  end
  return f.lambda*countnzy
end

fun_name(f::NormL0) = "weighted L0 pseudo-norm"
fun_dom(f::NormL0) = "AbstractArray{Real}, AbstractArray{Complex}"
fun_expr(f::NormL0) = "x ↦ λ countnz(x)"
fun_params(f::NormL0) = "λ = $(f.lambda)"

function prox_naive{T <: RealOrComplex}(f::NormL0, x::AbstractArray{T}, gamma::Real=1.0)
  over = abs.(x) .> sqrt(2*gamma*f.lambda);
  y = x.*over;
  return y, f.lambda*countnz(y)
end
