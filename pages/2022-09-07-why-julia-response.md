@def published = Date(2022, 09, 07)
@def hascode = true
@def title = "Why we still recommend Julia"
@def authors = """Matthijs"""
@def rss = "Why we still recommend Julia"
@def tags = ["julia", "code"]

# Why we still recommend Julia

Co-written with Jorge Vieyra.

This is a response to the article from Yury Vishnevy ["Why I no longer recommend Julia"](https://yuri.is/not-julia/). The primary argument revolves around "correctness" and the perception that the Julia ecosystem introduces significantly more bugs than other languages. A response was written by [Rik Huijzer](https://huijzer.xyz/posts/recommend/) and while we like that post, it did not address the core argument of Yury.

TL;DR;
* Some valid concerns and the community is taking them seriously.
* Mostly an ecosystem problem that is slowly being addressed.
* Formalizing Abstract Interfaces will solve this problem.
* With Julia you can shoot yourself in the foot … as with any other programming language.
* We need to improve documentation.
* Every Julia release is tested against all registered packages, need some help for "correctness" that can be easily addressed.

The article is written by Yury who has spent a long time working with Julia and is perceived by the community to be a competent programmer.
As such the Julia community is taking his concerns/feedback very seriously, see the [Julia Forum](https://discourse.julialang.org/t/discussion-on-why-i-no-longer-recommend-julia-by-yuri-vishnevsky/81151). All of the issues mentioned by Yury seem to be closed or have a solution ready.

As mentioned by Keno Fischer (JC CTO for compilers) on the [HackerNews discussion](https://news.ycombinator.com/item?id=31396861), he points out that most of the problems that Yury describes are ecosystem related (except for one bug in Core). This tells us that the open source ecosystem is having some growing pains that need to be addressed.

This is not dissimilar to what happens in other open source languages, e.g. Python. That's why in Python there exist several packages doing the same thing, some of them kind of working, some of them abandoned, and a few working correctly. The difference is that Python is a language that has been around for 30 years as a general purpose language and roughly 15 years as a "scientific computing" language and has had more time to work these things out.

This problem that Yury is pointing out is not inherent to the language (except for the missing feature below), but related to original community that got involved with. In the case of Julia, mostly written by academia, as was originally the case for MATLAB, Python and R.

From our personal point of view what Yury points out is that the composability of the language drives most of the package developers where there are little assurances on what the "abstract interfaces" allow you. This is one of the major concerns and perhaps our top request to enhance in the language, that is having formal abstract interfaces. Some first ideas for abstract interfaces are in [BinaryTraits.jl](https://github.com/tk3369/BinaryTraits.jl) and this [issue](https://github.com/JuliaLang/julia/issues/6975). Main problem is that once you use an AbstractSomething you don't really know what you are committing to and what are your "obligations". As such it is hard to fully fulfill your "promises" and "obligations" and that is what is happening on the ecosystem.
Many Julia package developers realized this and they are paying extra attention to this and even rewriting several of the packages, e.g. Flux and Zygote, both mentioned in the blog post.

This problem is very obvious with the `OffsetArrays` packages, one of the promises that AbstractArrays expects is that elements are accessed by indexes and that bounds will be checked.
However, you can use the  `@inbounds` macro as a "promise" to the compiler that you were not going to access indexes outside bounds in order to speed things up. This creates two conflicting promises (`OffsetArrays` promises one thing, and `@inbounds` another) and things go bad as mentioned in the blog.

As a side note, `OffsetArrays` is a very peculiar package for a niche group of users who don't like the default array indexing. We would never advise to deploy `OffsetArrays` into production. In general we advise to carefully review every package and dependency you introduce into your production environment.

To continue, the Julia authors didn't consider that `@inbounds` could be used to screw things up. A way to solve it what is done on the `CUDA` package with a warning, e.g.
```julia
julia> using CUDA
julia> x = rand(10);
julia> cux = CuVector(x);
julia> cux[1]
┌ Warning: Performing scalar indexing on task Task (runnable) @0x000000000b123080.
│ Invocation of getindex resulted in scalar indexing of a GPU array.
│ This is typically caused by calling an iterating implementation of a method.
│ Such implementations *do not* execute on the GPU, but very slowly on the CPU,
│ and therefore are only permitted from the REPL for prototyping purposes.
│ If you did intend to index this array, annotate the caller with @allowscalar.
└ @ GPUArrays C:\Users\jvieyras\.julia\packages\GPUArrays\Zecv7\src\host\indexing.jl:56
0.5820401314176449
```

The problem with the `@inbounds` macro is not a Julia specific thing, in Cython that is an option that the developer can disable to speed things up and in C … it is not even there, you can always index and array out of bounds. The fact that in Julia you can easily disable bounds is not unique to Julia … Half of the complaint was that the official documentation had this one wrong `@inbounds` example.

The alternative to not having abstract interfaces is testing more and better. Invenia has a good blog post on [interface testing](https://invenia.github.io/blog/2020/11/06/interfacetesting/). Their proposal is to define interface packages together with explicit interface test suites. We think this test driven approach is a good direction until we can enforce abstract interfaces explicitly.

We personally like the Julia community because EVERY day they run all the unit tests of ALL upstream registered packages. If there is a regression they often fix that either on a Julia release or with the package developer or both. Let me reiterate that they do this [EVERY day](https://github.com/JuliaCI/NanosoldierReports/tree/master/pkgeval/by_date). We typically don't do that level of rigorous testing inside the companies we worked for. If "correctness" is a issue for something, it is a matter of better testing and we can learn from the Julia community.

The focus on the Julia community has been on speed and composability, whereas now they are starting to focus on growth pains, in this case correctness is worrisome, but it is definitely something that can be addressed. On the other hand Python now has the opposite problem, most of PyData presentations are on Python scalability and ways to speed it up. Adding speed "after the fact" is more difficult than fixing incorrect results. Moving forward, we still believe the language foundations are a strength.

Thanks to Mosè Giordano, Dheepak Krishnamurthy, Martijn Bennebroek and Rik Huijzer for proof-reading and providing insightful comments.

{{ addcomments }}