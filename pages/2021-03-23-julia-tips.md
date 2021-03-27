@def published = Date(2021, 03, 23)
@def hascode = true
@def title = "Julia Developer Tips"
@def authors = """Matthijs"""
@def rss = "Tips and tricks for new Julia developers"
@def tags = ["code", "Julia"]

# Julia Developer Tips

I currently spend quite some time teaching Julia to interested developers. One recurring question is to share my tips for Julia development, specifically tooling and utility functions. Things that make your work easier, but that I always forget to explain explicitly. All these tips can be Googled and read in the Julia documentation, but I'll write them down here for later reference. Considered it a curated list of tips.

## How to get started with Julia

I assume you are already familiar with Julia. If not, go download it from the [Julia website](https://julialang.org/). Start learning via your preferred style, the [Julia learning page](https://julialang.org/learning/) has a great overview of material.

What I used for teaching so far:
- Like to dive deep? Read the [manual](https://docs.julialang.org/en/v1/manual/getting-started/).
- Like to read a free book? [ThinkJulia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html).
- Like guided training with a tutor? Watch [videos](https://juliaacademy.com/courses).
- Like to start hands-on work with Jupyter notebooks? Find them on [Github](https://github.com/JuliaAcademy/JuliaTutorials/tree/main/introductory-tutorials/intro-to-julia).
- Like reading academic papers? Start with the [paper](https://arxiv.org/pdf/1411.1607.pdf) from the founders.

Please learn Julia in the way that works best for you, I can't tell you what works best.

### Which IDE?

I use [Visual Study Code](https://code.visualstudio.com/) with the [Julia extension](https://www.julia-vscode.org/). But please use whatever you like. For example, I have a colleague who raves about [Neovim](https://neovim.io/) and corresponding Julia plugin.

### Julia package creation

After learning the Julia language basics, the next thing you should learn is how to create Julia packages. It's the one and only way to distribute your code to others in a standard manner.

I taught myself via this [Youtube Video](https://www.youtube.com/watch?v=QVmU29rCjaA). Created by Chris Rackauckas, a prominent Julia contributor.

I recently discovered this [Blog Post - How to create packages with Julia](https://jaantollander.com/post/how-to-create-software-packages-with-julia-language/), which also gives a good overview.

## The Julia tips

The Julia manual already includes quite some tips:
* [Julia Manual - Performance Tips](https://docs.julialang.org/en/v1/manual/performance-tips/)
* [Julia Manual - Workflow Tips](https://docs.julialang.org/en/v1/manual/workflow-tips/)
* [Julia Manual - Styleguide](https://docs.julialang.org/en/v1/manual/style-guide/)

### Basic Utilities

Julia has plenty of (interactive) utilities to help you make some more sense of Julia code. When I accidentally use one of these functions in a training, people often tell me "I wish you would spend more time explaining these". So here it goes.

The most basic 'utilities' are all functions to get type information. These should be covered in all Julia teaching material, but let's do a quick recap:

You'll find yourself wanting to know the type:
```julia
julia> typeof(3)
Int64
```

Or maybe you want to know the supertype
```julia
julia> supertype(Int64)
Signed
```

Another great function you should never forget is to get all the methods of a function:
```julia
julia> methods(append!)
# 5 methods for generic function "append!":
[1] append!(A::Array{Bool,1}, items::BitArray{1}) in Base at bitarray.jl:772
[2] append!(B::BitArray{1}, items::BitArray{1}) in Base at bitarray.jl:755
[3] append!(a::Array{T,1} where T, items::AbstractArray{T,1} where T) in Base at array.jl:973
[4] append!(B::BitArray{1}, items) in Base at bitarray.jl:771
[5] append!(a::AbstractArray{T,1} where T, iter) in Base at array.jl:981
```

[InteractiveUtils.jl](https://docs.julialang.org/en/v1/stdlib/InteractiveUtils/#Interactive-Utilities), by default loaded in your Julia REPL. Note: don't use them in your packages if you can avoid it, they are primarily tools for developers to use on the REPL. The names of these functions are pretty self-explanatory.
* [subtypes](https://docs.julialang.org/en/v1/stdlib/InteractiveUtils/#InteractiveUtils.subtypes)
* [supertypes](https://docs.julialang.org/en/v1/stdlib/InteractiveUtils/#InteractiveUtils.supertypes)
* [methodswith](https://docs.julialang.org/en/v1/stdlib/InteractiveUtils/#InteractiveUtils.methodswith)
* [@which](https://docs.julialang.org/en/v1/stdlib/InteractiveUtils/#InteractiveUtils.@which)
* [@edit](https://docs.julialang.org/en/v1/stdlib/InteractiveUtils/#InteractiveUtils.@edit)

I especially use `@which` and `@edit` more and more as our code base grows. It helps you find which method is being called, where `@edit` immediately opens your editor at that location:
```julia
julia> @which push!([1,2], 1)
push!(a::Array{T,1}, item) where T in Base at array.jl:932
```

Another cool trick is to quickly make a subtype tree, for example with AbstractTrees
```julia
julia> using AbstractTrees
julia> AbstractTrees.children(x::Type) = subtypes(x)
julia> print_tree(Integer)
Integer
├─ Bool
├─ Signed
│  ├─ BigInt
│  ├─ Int128
│  ├─ Int16
│  ├─ Int32
│  ├─ Int64
│  └─ Int8
└─ Unsigned
   ├─ UInt128
   ├─ UInt16
   ├─ UInt32
   ├─ UInt64
   └─ UInt8
```

As you grow in Julia experience, you'll find yourself wanting more utilities. Like `Test.@inferred` which is useful to check for type instability. I can advice the book [Julia Hands-on Design Patterns book](https://www.packtpub.com/product/hands-on-design-patterns-and-best-practices-with-julia/9781838648817) for more goodies.

### Unit Testing

Every Julia package developer is doing Test Driven Development. It's the defacto standard in software development nowadays. Where to learn TDD? I watched two Robert C Martin (Uncle Bob) videos at work about TDD and that was it. I'm sure there are free TDD tutorials out there, but I didn't need much more to be convinced.

What do you want me to say about unit testing? It's almost trivial and already explained in the blog post ["How to create packages with Julia"](https://jaantollander.com/post/how-to-create-software-packages-with-julia-language/).

```Julia
using Test
@testset "name your testset" begin
    # just test anything that evaluates to a Boolean
    @test 1==2
end
```

If you do test driven development, you should have good code coverage pretty much by default. But you'll want to brag about your code coverage, so you can use [Coverage.jl](https://github.com/JuliaCI/Coverage.jl)

### Profiling

Julia has a [profiler](https://docs.julialang.org/en/v1/manual/profile/). To make a quick overview plot I love [ProfileView.jl](https://github.com/timholy/ProfileView.jl).

That's actually all I ever used for profiling.

### Debugging

To be honest I hardly ever use the debugger.

Debugging works out of the box in Visual Studio Code, you can see the [Julia-VSCode debugging guide](https://www.julia-vscode.org/docs/stable/userguide/debugging/) for more information.

Julia has debugging capabilities embedded which you can use from the command line. I liked [this blog post](https://opensourc.es/blog/basics-debugging/) which compares multiple debugging alternatives.