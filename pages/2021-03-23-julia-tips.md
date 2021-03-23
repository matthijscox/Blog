@def published = Date(2021, 03, 23)
@def hascode = true
@def title = "Julia Developer Tips"
@def authors = """Matthijs"""
@def rss = "Tips and tricks for new Julia developers"
@def tags = ["code", "Julia"]

# Julia Developer Tips

I'm teaching quite some Julia trainings at my current employer. One recurring question is to share some tips about development tooling and functions. Just a few things that make your life easier, but that I always forget to explain explicitly. All these things can be Googled and read in the Julia documentation, but I'll write them down here for later reference.

## How to get started with Julia

In this post, I assume you are already familiar with Julia. If not, go download it from the [Julia website](https://julialang.org/). Start learning via your preferred style, the [Julia learning page](https://julialang.org/learning/) has a great overview of material.

What I used for teaching so far:
- Like to dive deep? Read the [manual](https://docs.julialang.org/en/v1/manual/getting-started/).
- Like to read a free book? [ThinkJulia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html).
- Like guided training with a tutor? Watch [videos](https://juliaacademy.com/courses).
- Like to start hands-on work with Jupyter notebooks? Find them on [Github](https://github.com/JuliaAcademy/JuliaTutorials/tree/main/introductory-tutorials/intro-to-julia).
- Like reading academic papers? Start with the [paper](https://arxiv.org/pdf/1411.1607.pdf) from the founders.

### Which IDE?

I use [Visual Study Code](https://code.visualstudio.com/) with the [Julia extension](https://www.julia-vscode.org/). But please use whatever you like, I have a colleague who raves about [Neovim](https://neovim.io/) and corresponding Julia plugin.

### Julia package creation

After learning the Julia language basics, the next thing you should do is learn how to create Julia packages. It's the one and only way to distribute your code to others in a standard manner.

I taught myself via this [Youtube Video](https://www.youtube.com/watch?v=QVmU29rCjaA). Created by Chris Rackauckas, a prominent Julia contributor.

I recently discovered this [Blog Post - How to create packages with Julia](https://jaantollander.com/post/how-to-create-software-packages-with-julia-language/), which also gives a good overview.

## The tips

