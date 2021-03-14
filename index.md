@def title = "Franklin Example"
@def tags = ["syntax", "code"]

# Welcome

This is a blog about math, code, physics and other things that interest me.

It's written with Franklin, a great thing about that is that I can easily write code on it:
```julia
abstract type AbstractPoint end
struct XYPoint{T<:Real} <: Point
    x::T
    y::T
end
```

## Posts

Just need to figure out how to automatically add recent posts here.

See e.g. [cormullion's blog](https://github.com/cormullion/cormullion.github.io)
