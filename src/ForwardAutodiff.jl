module ForwardAutodiff

import Base: exp, sin, cos, tan, +, -, *, /, sqrt, convert, promote_rule, zero

export D

struct Infinitesimal{T <: Number} <: Number
    x::T
    dx::T
end

function convert(::Type{Infinitesimal{T}}, x::T) where {T}
   Infinitesimal(x, zero(x))
end
function convert(::Type{Infinitesimal{T}}, x::Infinitesimal{S}) where {S, T}
   Infinitesimal(T(x.x), T(x.dx))
end
# This is needed according to an error before
function convert(::Type{Infinitesimal{T}}, x::T) where {T <: Number}
    Infinitesimal(x, zero(x))
end
function convert(::Type{Infinitesimal{T}}, x::S) where {T, S <: Number}
    x_as_T = convert(T, x)
    Infinitesimal(x_as_T, zero(x_as_T))
end

function zero(x::Infinitesimal{T}) where T
    Infinitesimal(zero(x.x), zero(x.dx))
end

function promote_rule(::Type{Infinitesimal{T}}, ::Type{Infinitesimal{S}}) where {T,S}
    Infinitesimal{promote_type(T,S)}
end
function promote_rule(::Type{Infinitesimal{T}}, ::Type{S}) where {T, S <: Number}
    Infinitesimal{promote_type(T,S)}
end
function promote_rule(::Type{T}, ::Type{Infinitesimal{S}}) where {T <: Number, S}
    Infinitesimal{promote_type(T,S)}
end
function promote_rule(::Type{S}, ::Type{Infinitesimal{T}}) where {S <: AbstractIrrational, T}
    Infinitesimal{promote_type(S,T)}
end

function extract_derivative(xdx::Infinitesimal)
    return xdx.dx
end
function extract_derivative(xs::Array)
    [extract_derivative(x) for x in xs]
end
function extract_derivative(xs::Tuple)
    convert(Tuple, [extract_derivative(x) for x in xs])
end

"""    D([i], f)

Differential operator; with an optional integer, specifies a partial derivative
with respect to argment `i` (from 1).

Returns a function that computes the derivative of `f`.  NOTE: at the moment,
nested derivatives won't work: `D(D(f))` will not compute a second derivative.
"""
function D(f)
    function df(x)
        xdx = Infinitesimal(x, one(x))
        result = f(xdx)
        return extract_derivative(result)
    end
    df
end
function D(i::Integer, f)
    function df(xs...)
        xarr = [(j != i ? x : Infinitesimal(x, one(x))) for (j,x) in enumerate(xs)]
        result = f(xarr...)
        return extract_derivative(result)
    end
    df
end

function +(x::Infinitesimal, y::Infinitesimal)
    Infinitesimal(x.x+y.x, x.dx+y.dx)
end
function -(x::Infinitesimal, y::Infinitesimal)
    Infinitesimal(x.x-y.x, x.dx-y.dx)
end
function -(x::Infinitesimal)
    Infinitesimal(-x.x, -x.dx)
end
function *(x::Infinitesimal, y::Infinitesimal)
    Infinitesimal(x.x*y.x, x.x*y.dx + x.dx*y.x)
end
function /(x::Infinitesimal, y::Infinitesimal)
    Infinitesimal(x.x/y.x, x.dx/y.x - x.x*y.dx/(y.x*y.x))
end

function sqrt(x::Infinitesimal)
    Infinitesimal(sqrt(x.x), x.dx/(2*sqrt(x.x)))
end

function exp(x::Infinitesimal)
    return Infinitesimal(exp(x.x), exp(x.x)*x.dx)
end
function sin(x::Infinitesimal)
    return Infinitesimal(sin(x.x), cos(x.x)*x.dx)
end
function cos(x::Infinitesimal)
    return Infinitesimal(cos(x.x), -sin(x.x)*x.dx)
end
function tan(x::Infinitesimal)
    c = cos(x.x)
    return Infinitesimal(tan(x.x), x.dx/(c*c))
end

end # module
