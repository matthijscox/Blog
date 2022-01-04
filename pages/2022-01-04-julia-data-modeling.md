@def published = Date(2022, 01, 04)
@def hascode = true
@def title = "Julia Data Modeling: A Pointy Example"
@def authors = """Matthijs"""
@def rss = "Julia Data Modeling: A Pointy Example"
@def tags = ["julia", "code"]

# Julia Data Modeling: A Pointy Example

Julia's high performance gives the developer a lot of freedom in their choice of data structures. The downside of this freedom is that you need to spend more time thinking about the optimal data model for your code.

In a low performance language you are often restrained by the interface of the underlying high performance library. For example, in the MATLAB language or the Python Numpy package you are encouraged to make vectors of only numbers.

In Julia you can define your own custom types, which can be just as performant, or even more performant depending on your use case, than the already available types.

## Lot's of Points

To illustrate the possibilities, I'll take a simple example that I personally encountered a lot. You've got some data points on an XY plane and the data is labeled as valid or not.

The straightforward way to model this data (coming from a vectorized framework) is to define these as vectors.

To keep them easily together in Julia, you'll then want to put them in a custom type:

```julia
struct VectorData
    x::Vector{Float64}
    y::Vector{Float64}
    validx::Vector{Bool}
    validy::Vector{Bool}
end
```
The reason that vectors (of primitive types) are often performant is due to how your computer stores memory in data. When you apply operations that need to iterate over `x` for example, the compact memory layout is quite ideal. You can read this excellent article about [What scientists must know about hardware to write fast code](https://viralinstruction.com/posts/hardware/).

So this can be a very good data structure. For example for multiplying your `x` values with a matrix.

If you spend a lot of time iterating over the data points however, like filtering the valid data based on some function, things become a bit more messy.

Also some developer might suddenly decide not all vectors in `VectorData` need to be equally long. Or the user of your data structure accidentally only changes one vector. If you want the vectors to be mutable, yet always of equal length, then you should check the vector lengths in all your functions to be safe :(

Let's try an alternative.

```julia
struct PointData
    x::Float64
    y::Float64
    validx::Bool
    validy::Bool
end
struct PointVector
   points::Vector{PointData}
end
```

Note that I put the vector of `PointData` into a struct, which just makes function dispatching more pleasant.

Let's write our desired filter function and try them both. Decide for yourself which solution you find most readable.

```julia
function within_threshold(x::T, y::T, threshold::T) where T<:Real
    return x^2 + y^2 < threshold^2
end

function filter_points(pts::VectorData, threshold=0.4)
    keep = pts.validx .& pts.validy .& within_threshold.(pts.x, pts.y, Ref(threshold))
    return VectorData(pts.x[keep], pts.y[keep], pts.validx[keep], pts.validy[keep])
end

function keep_point(p::PointData, threshold)
    return p.validx && p.validy && within_threshold(p.x, p.y, threshold)
end

function filter_points(points::AbstractArray{PointData}, threshold=0.4)
    return filter(p -> keep_point(p, threshold), points)
end

function filter_points(pts::PointVector, threshold=0.4)
    return PointVector(filter_points(pts.points))
end

```

We can quickly try both functions out by constructing some example data:

```julia
function Base.convert(::Type{PointVector}, v::VectorData)
    points = PointData.(v.x, v.y, v.validx, v.validy)
    return PointVector(points)
end

using BenchmarkTools
N = 10_000_000 # making the vectors do not fit in my computer's cache ;)
vd = VectorData(rand(N), rand(N), rand(Bool, N), rand(Bool, N))

@benchmark filter_points(vd)

BenchmarkTools.Trial: 175 samples with 1 evaluation.
 Range (min … max):  25.246 ms … 62.595 ms  ┊ GC (min … max): 0.00% … 27.22%
 Time  (median):     26.840 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   28.581 ms ±  4.728 ms  ┊ GC (mean ± σ):  1.55% ±  5.52%

 Memory estimate: 6.60 MiB, allocs estimate: 14.

pv = convert(PointVector, vd)
@benchmark filter_points(pv)

BenchmarkTools.Trial: 170 samples with 1 evaluation.
 Range (min … max):  21.897 ms … 85.568 ms  ┊ GC (min … max):  0.00% … 8.27%
 Time  (median):     28.346 ms              ┊ GC (median):     0.72%
 Time  (mean ± σ):   29.538 ms ±  7.879 ms  ┊ GC (mean ± σ):  10.11% ± 9.53%

 Memory estimate: 228.88 MiB, allocs estimate: 4.

```

In this case it turns the times are roughly equal. My PointVector solution is slightly faster, but does use way more memory.

## Interlude: Filtering better

I am a little annoyed at the memory usage of the filter function. So I am exploring how to improve that here.

The `Base.filter()` function might be the memory consumer. If you write a list comprehension it actually use `Iterators.filter`, so these two solutions behave equally. Less memory usage, but slightly slower:
```julia
function filter_points(points::AbstractArray{PointData}, threshold=0.4)
    return [p for p in points if keep_point(p, threshold)]
end
function filter_points(points::AbstractArray{PointData}, threshold=0.4)
    return collect(Iterators.filter(p -> keep_point(p, threshold), points))
end

@benchmark filter_points(pv)

BenchmarkTools.Trial: 117 samples with 1 evaluation.
 Range (min … max):  36.909 ms … 101.812 ms  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     39.738 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   42.855 ms ±   7.999 ms  ┊ GC (mean ± σ):  1.13% ± 3.73%

 Memory estimate: 14.26 MiB, allocs estimate: 14.
```

I can also define the functionality myself. You can see it's pretty much equal to the list comprehension.

```julia
function filter_points(points::T, threshold=0.4) where T<:AbstractArray{PointData}
    new_points = T()
    for p in points
        if keep_point(p, threshold)
            push!(new_points, p)
        end
    end
    return new_points
end

@benchmark filter_points(pv)

BenchmarkTools.Trial: 116 samples with 1 evaluation.
 Range (min … max):  41.746 ms … 57.218 ms  ┊ GC (min … max): 0.00% … 22.16%
 Time  (median):     42.415 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   43.246 ms ±  2.438 ms  ┊ GC (mean ± σ):  1.21% ±  4.03%

 Memory estimate: 14.26 MiB, allocs estimate: 14.
```

It seems I can reduce memory usage at the cost of some runtime performance. In the source code of `Base.filter` I see that it pre-allocates a new vector and shrinks it afterwards, while in this code we grow the new vector dynamically. I'm keeping this info here for future reference.

## More point possibilities

Having to choose between an array of structs, or a struct of arrays, is a typical scenario while coding in Julia. The best choice really depends on what you intend to do most with your data. If performance is not the issue, then I prefer the array of structs for reasons of clarity (that means the `PointVector` in the above example).

But let's not stop there and explore some more options together.

Why not accept the fact that we have two points intertwined in our data model?

```julia
struct Point{T}
    x::T
    y::T
end
struct TwoPoints
    values::Point{Float64}
    valid::Point{Bool}
end
struct VectorTwoPoints
    data::Vector{TwoPoints}
end
```

Or pair up the value and valid field. Perhaps this is a common pattern in your codebase to flag any value as valid or not?

```julia
struct ValidValue{T}
    value::T
    valid::Bool
end
struct VectorPointValues
    data::Vector{Point{ValidValue}}
end
```

Or accept that we always have a value and a valid per direction. The interesting thing here is that we can extend the directions easily in the future if we want to go 3D for example. To label the direction, we could use an enum, but those are not popular in Julia. One reason is that you cannot easily dispatch on enums. So you might find something like this:

```julia
abstract type Direction end
struct X <: Direction end
struct Y <: Direction end

struct DirectionalValidValue
    direction::Direction
    value::Float64
    valid::Bool
end
struct VectorDirectionalValues
    data::Vector{DirectionalValidValue}
end
```

And now we could go full circle and just make a struct array again:

```julia
struct DirectionalVectorData
    direction::Vector{<:Direction}
    values::Vector{Float64}
    valid::Vector{Bool}
end
```

This last one might be best if we often find ourselves concatenating the x and y value from the initial structure. For example if we want to fit the x and y data together in a 2D model.

I'm not going to test the filtering performance of all of these. I expect roughly equal performance as the `PointVector` solution, with a little extra overhead if we use structs inside structs.

The ideal structures will depend on your own use case; what you do with the data in the functions you write. I'm still learning what is best for my own use cases. A structure of arrays seems to be the first choice for performance, assuming your data fits into memory as continuous vectors. DataFrames.jl stores each column as a vector for this purpose. But the desire to want both a struct array and an array of structs is a common pattern as well. So common that it has it's own package: [StructArrays.jl](https://github.com/JuliaArrays/StructArrays.jl).

## StructArrays

Let's have a brief look at StructArrays. I'm re-using the data generated in the example from the beginning.

```julia
julia> using StructArrays

julia> sa = StructArray(pv.points)
10000000-element StructArray(::Vector{Float64}, ::Vector{Float64}, ::Vector{Bool}, ::Vector{Bool}) with eltype PointData:
 PointData(0.8342412444868733, 0.7156389385059589, false, false)
 ⋮
 PointData(0.21446860650049493, 0.23189128521923086, false, false)

# you can get the properties again
julia> sa.x
10000000-element Vector{Float64}:
 0.8342412444868733
 ⋮
 0.21446860650049493

# we can apply our filter function on it
julia> filter_points(sa)
314598-element StructArray(::Vector{Float64}, ::Vector{Float64}, ::Vector{Bool}, ::Vector{Bool}) with eltype PointData:
 PointData(0.09048345510701994, 0.320553989305556, true, true)
 ⋮
 PointData(0.11419461083293259, 0.34645035134668634, true, true)

julia> @benchmark filter_points(sa)
BenchmarkTools.Trial: 73 samples with 1 evaluation.
 Range (min … max):  63.260 ms … 92.607 ms  ┊ GC (min … max): 0.00% … 14.19%
 Time  (median):     66.733 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   68.442 ms ±  5.277 ms  ┊ GC (mean ± σ):  0.48% ±  2.31%

 Memory estimate: 14.26 MiB, allocs estimate: 14.
```

Unfortunately it's slower than the direct implementations, StructArrays seems to add a bit of overhead. But the convenience might be worth it for you, and maybe you do not spend that much time iterating over the rows/elements of the struct array.

## Custom struct array implementation

If you want to build your own custom struct array, you'll have to write your own iterators and other functionality. It's more work, but is it worth it? Let's see how it goes.

Basically I will just extend the `VectorData` type and link it to the `PointData` type via iterate and getindex and such. I will copy the structures here for clarity again.

```julia
struct PointData
    x::Float64
    y::Float64
    validx::Bool
    validy::Bool
end
struct VectorData
    x::Vector{Float64}
    y::Vector{Float64}
    validx::Vector{Bool}
    validy::Vector{Bool}
end

# remember there is some danger in this assumption
Base.length(v::VectorData) = length(v.x)
Base.eachindex(v::VectorData) = eachindex(v.x)
Base.IteratorSize(::Type{VectorData}) = Base.HasLength()

# I stole this function from AbstractArrays.jl, after reading StructArrays.jl
# we could also choose to make VectorData <: AbstractArray
function Base.iterate(A::VectorData, state=(eachindex(A),))
    y = iterate(state...)
    y === nothing && return nothing
    A[y[1]], (state[1], Base.tail(y)...)
end

function Base.getindex(A::VectorData, idx::Integer)
    return PointData(A.x[idx], A.y[idx], A.validx[idx], A.validy[idx])
end

# defining my own filter function, not sure if there is a better way
function Base.filter(f::Function, A::VectorData)
    keep = Int64[]
    for (index, p) in enumerate(A)
        if f(p)
            push!(keep, index)
        end
    end
    return VectorData(A.x[keep], A.y[keep], A.validx[keep], A.validy[keep])
end

```

Now we can use iteration to filter the points:

```julia
function filter_points(pts::VectorData, threshold=0.4)
    return filter(p -> keep_point(p, threshold), pts)
end
```

Let's look at the filtering performance.

```julia
using BenchmarkTools
N = 10_000_000
vd = VectorData(rand(N), rand(N), rand(Bool, N), rand(Bool, N))

@benchmark filter_points(vd)

BenchmarkTools.Trial: 82 samples with 1 evaluation.
 Range (min … max):  54.039 ms … 83.368 ms  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     60.138 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   61.772 ms ±  5.472 ms  ┊ GC (mean ± σ):  1.02% ± 3.27%

 Memory estimate: 10.61 MiB, allocs estimate: 21.
```

You see it's hard to do a much better job than StructArrays. And definitely hard to beat an actual struct of arrays.

{{ addcomments }}