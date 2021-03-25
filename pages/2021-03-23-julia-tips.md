@def published = Date(2021, 03, 23)
@def hascode = true
@def title = "Julia Developer Tips"
@def authors = """Matthijs"""
@def rss = "Tips and tricks for new Julia developers"
@def tags = ["code", "Julia"]

# Julia Developer Tips

I'm teaching quite some Julia trainings at my current employer. One recurring question is to share my tips for Julia development, specifically tooling and utility functions. Things that make your work easier, but that I always forget to explain explicitly. All these tips can be Googled and read in the Julia documentation, but I'll write them down here for later reference.

## How to get started with Julia

In this post, I assume you are already familiar with Julia. If not, go download it from the [Julia website](https://julialang.org/). Start learning via your preferred style, the [Julia learning page](https://julialang.org/learning/) has a great overview of material.

What I used for teaching so far:
- Like to dive deep? Read the [manual](https://docs.julialang.org/en/v1/manual/getting-started/).
- Like to read a free book? [ThinkJulia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html).
- Like guided training with a tutor? Watch [videos](https://juliaacademy.com/courses).
- Like to start hands-on work with Jupyter notebooks? Find them on [Github](https://github.com/JuliaAcademy/JuliaTutorials/tree/main/introductory-tutorials/intro-to-julia).
- Like reading academic papers? Start with the [paper](https://arxiv.org/pdf/1411.1607.pdf) from the founders.

### Which IDE?

I use [Visual Study Code](https://code.visualstudio.com/) with the [Julia extension](https://www.julia-vscode.org/). But please use whatever you like. For example, I have a colleague who raves about [Neovim](https://neovim.io/) and corresponding Julia plugin.

### Julia package creation

After learning the Julia language basics, the next thing you should do is learn how to create Julia packages. It's the one and only way to distribute your code to others in a standard manner.

I taught myself via this [Youtube Video](https://www.youtube.com/watch?v=QVmU29rCjaA). Created by Chris Rackauckas, a prominent Julia contributor.

I recently discovered this [Blog Post - How to create packages with Julia](https://jaantollander.com/post/how-to-create-software-packages-with-julia-language/), which also gives a good overview.

## The tips

The Julia manual already includes quite some tips:
* [Julia Manual - Performance Tips](https://docs.julialang.org/en/v1/manual/performance-tips/)
* [Julia Manual - Workflow Tips](https://docs.julialang.org/en/v1/manual/workflow-tips/)
* [Julia Manual - Styleguide](https://docs.julialang.org/en/v1/manual/style-guide/)

### Julia Utilities

Julia has plenty of (interactive) utilities to help you make some more sense of Julia code. When I accidentally use one of these functions in a training, people often tell me "I wish you would spend more time explaining these". So here it goes.

https://docs.julialang.org/en/v1/stdlib/InteractiveUtils/#Interactive-Utilities

Things to explain
* recap of typeof/supertype/isa etc. See Types and Dispatch notebook.

Quickly make a Number subtype tree with AbstractTrees

InteractiveUtils.jl, be default loaded in your Julia REPL. Note: don't use them in your packages if you can avoid it, they are tools for developers.
* methods
* methodswith
* @which
* @edit
* @code_native, etc
* Test.@inferred


### Unit Testing

Every Julia package developer is doing test driven development. It's the defacto standard nowadays.

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

Julia has a [profiler](https://docs.julialang.org/en/v1/manual/profile/). To make a quick overview I love [ProfileView.jl](https://github.com/timholy/ProfileView.jl).

### Debugging

Too be honest I hardly ever use the debugger.

Debugging works out of the box in Visual Studio Code, you can see the [Julia-VSCode debugging guide](https://www.julia-vscode.org/docs/stable/userguide/debugging/) for more information.

Julia has debugging capabilities embedded which you can use from the command line. I liked [this blog post](https://opensourc.es/blog/basics-debugging/) which compares multiple debugging alternatives.