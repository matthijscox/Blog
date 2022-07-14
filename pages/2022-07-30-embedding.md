@def published = Date(2022, 07, 30)
@def hascode = true
@def title = "Advanced Julia: Embedding in C++"
@def authors = """Matthijs"""
@def rss = "Embedding Julia in C++ the hard way"
@def tags = ["julia", "code"]

# Advanced Julia: Embedding in C/C++

Embedding compiled Julia libraries inside a foreign environment with a C-callable interface is an advanced topic on the border of my expertise. It's heavily underdocumented and non-trivial, I'll try to explain what I know.

Some fundamentals are explained in the [Embedding section](https://docs.julialang.org/en/v1/manual/embedding/) in the Julia manual. For the datatypes that can be passed between C and Julia, see [calling-c-and-fortran-code](https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/).

I will make things hard for myself and compile on Windows. Also note that I am using c++ instead of c, while the interface with the Julia library is actually c.

## Compiling C++

I will compile C++ on Windows. It's notoriously difficult on Windows to find the right compiler. I got burned once on some generic MinGW compiler, creating all kinds of wrong string conversions, took us days to find out. So far the MinGW x86_64-8.1.0-posix-seh-rt_v6-rev0 is working fine on my personal system. You can also use the [Microsoft Visual C++ compiler tools](https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=msvc-170), you can download the command line tools separate from the Visual Studio IDE. Make sure the right tool is added to your windows path. Use `where g++` or `where gcc` to find out which one you are using.

Let's start at the real basics. So make a file called example.cpp.
```c++
#include <iostream>

int main()
{
    std::cout << "hello world" << std::endl;
    return 0;
}
```

Now on your command line run: `g++ example.cpp -o example`. This will compile an example.exe, which you can then run on your command line with `example.exe` and see the output string "hello world".

Use `gcc` for c and `g++` for c++. These functions come with a bunch of compile and link options, the most common ones are:

* `-c` (Compilation option).
Compile only. Produces .o files from source files without doing any linking.
* `-o file-name` (Link option, usually).
Use file-name as the name of the file produced by g++ (usually, this is an executable file).
* `-Llibrary-name` (Link option).
Link in the specified library. See above. (Link option).

## Compiling Julia

[PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl) is your primary friend and documentation is improving rapidly. Perhaps in the future we will have an incredible [StaticCompiler.jl](https://github.com/tshort/StaticCompiler.jl), but that's for another time.

PackageCompiler does take a few minutes to compile any Julia code, even a simple hello world. That's because all of Julia base is included, regardless of whether actually need all base functionality or not.

We will be using the [create_library](https://julialang.github.io/PackageCompiler.jl/stable/libs.html) functionality of PackageCompiler.

## Simple example

A skeleton Julia compilation example is already available [here](https://github.com/JuliaLang/PackageCompiler.jl/tree/master/examples/MyLib).

For a pure C example implementation see Simon Byrne's [libcg](https://github.com/simonbyrne/libcg). See if you can already run that example.

Steps:
* Clone the repository in a folder. You know: `git clone https://github.com/simonbyrne/libcg.git`.
* Run the Makefile. Uh oh...

OK, running Makefile on Windows isn't trivial either. [StackOverflow provides some answers](https://stackoverflow.com/questions/2532234/how-to-run-a-makefile-in-windows). My c/c++ mingw installation comes with `mingw32-make`, but that doesn't work with this Makefile, see this [issue](https://github.com/simonbyrne/libcg/issues/21). Advise is to install Cygwin with make, because they use a lot of shell scripting which doesn't work on Windows.

OK, so this example is not so simple on Windows. In the end I decided to write my own Windows Makefile for my own c++ code and compile it with `mingw32-make`.

### Interlude: Makefiles?

Compiling c/c++ projects generally involves a lot of steps to compile multiple files and link libraries together. This can become a complex build process and you don't want to type all commands manually all the time. So people made build tools! Yay! Typically these come with their own kind of scripting language that you need to learn. Hmm, OK, just do it. It's also generally Unix oriented, not Windows. Make is a one common build tool, here's a [Makefile tutorial](https://makefiletutorial.com/).

As an example, I enjoyed this [g++ makefile example](https://earthly.dev/blog/g++-makefile/). It explains all compilation steps and how to make a Makefile for our simple example c++ program above. Very informative, please read and try it out!

### Interlude: Name Mangling

Another thing that is different in all my examples below, is that c++ mangles the names of functions. That means that a function `f(int)` get's turning into something like `__f_i(int)`. To avoid this we need to use [extern C](https://www.geeksforgeeks.org/extern-c-in-c/) whenever we define function interfaces. This took me a while to figure out, so a lesson learned the hard way!

```c++
extern "C"
{
    #include "julia_init.h"
}
```

## Basic Types



## Lessons Learned

`GC.@preserve`

## Error handling

Special acknowledgements to Daan Sperber and Evangelos Paradas for helping me figure out a lot of the steps involved.

{{ addcomments }}