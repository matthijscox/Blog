@def published = Date(2022, 07, 30)
@def hascode = true
@def title = "Advanced Julia: Embedding libraries in C++"
@def authors = """Matthijs"""
@def rss = "Embedding Julia libraries in C++ on Windows"
@def tags = ["julia", "cpp", "code"]

# Advanced Julia: Embedding libraries in C++

Embedding compiled Julia libraries inside a foreign environment with a C-callable interface is an advanced topic on the border of my expertise. It's somewhat underdocumented and non-trivial, so I've made this tutorial by writing down the steps I followed myself.

The fundamentals are explained in the [Embedding section](https://docs.julialang.org/en/v1/manual/embedding/) in the Julia manual. For the datatypes that can be passed between C and Julia, see [calling-c-and-fortran-code](https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/).

I will make things hard for myself and compile on Windows. Also note that I am using c++ instead of c, but most steps will be similar for c.

High level the steps involved are:
* Setup a c/c++ compiler
* Make a Julia package
* Write the Julia c-interface functions
* Write the c++ code calling those functions
* Compile Julia code to a library with PackageCompiler.jl
* Compile c++ and link it to the Julia library

I'll explain how I did these steps and especially touch upon the Julia-C interface functions and types.

## Compiling C++

I will compile C++ on Windows. It's notoriously difficult on Windows to find the right compiler. I got burned once on some generic MinGW compiler, creating all kinds of wrong string conversions, took us days to find out. So far the MinGW x86_64-8.1.0-posix-seh-rt_v6-rev0 is working fine on my personal system. You can also use the [Microsoft Visual C++ compiler tools](https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=msvc-170), you can download the command line tools separate from the Visual Studio IDE. Make sure the right tool is added to your windows path. Use `where g++` or `where gcc` to find out which one you are using.

Let's start at the real basics. So make a file called example.cpp.
```cpp
#include <iostream>

int main()
{
    std::cout << "hello world" << std::endl;
    return 0;
}
```

Now on your command line run: `g++ example.cpp -o example`. This will compile an example.exe, which you can then run on your command line with `example.exe` and see the output string "hello world".

Use `gcc` for c and `g++` for c++. These functions come with a bunch of compile and link options. There are so many options... The most common ones are:

* `-c` (Compilation option).
Compile only. Produces .o files from source files without doing any linking.
* `-I[/path/to/headers]` (Compilation option).
Include a folder with header files, like julia.h.
* `-o file-name` (Link option, usually).
Use file-name as the name of the file produced by g++ (usually, this is an executable file).
* `-l[library-name]` (Link option).
Link in the specified library. See above. (Link option).
* `-L[/path/to/shared-libraries] -l[library-name]` (Link option).
Link in the specified library, like julia.dll, from a given folder.

## Create a Julia package

I assume you have basic Julia knowledge, including package development. Julia libraries are created from a package, so go ahead and make one in a folder. Simply run:

```julia
julia> cd("my/desired/package/path")
julia> import Pkg; Pkg.generate("MyLibPackage")
```

## Compiling Julia

[PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl) is your primary friend and documentation is improving rapidly. Perhaps in the future we will have an incredible [StaticCompiler.jl](https://github.com/tshort/StaticCompiler.jl), but that's for another time.

PackageCompiler does take a few minutes to compile any Julia code, even a simple hello world. That's because all of Julia base is included, regardless of whether actually need all base functionality or not.

We will be using the [create_library](https://julialang.github.io/PackageCompiler.jl/stable/libs.html) functionality of PackageCompiler. The easiest way is to find some example build scripts from others and add those to your package, so let's go find one.

## Existing examples?

A skeleton Julia compilation example is already available [here](https://github.com/JuliaLang/PackageCompiler.jl/tree/master/examples/MyLib).

For a pure C example implementation see Simon Byrne's [libcg](https://github.com/simonbyrne/libcg). See if you can already run that example.

Steps:
* Clone the repository in a folder. You know: `git clone https://github.com/simonbyrne/libcg.git`.
* Run the Makefile. Uh oh...

OK, running the Makefile on Windows isn't trivial either. [StackOverflow provides some answers](https://stackoverflow.com/questions/2532234/how-to-run-a-makefile-in-windows). My c/c++ mingw installation comes with `mingw32-make`, but that doesn't work with this specific Makefile, see this [issue](https://github.com/simonbyrne/libcg/issues/21). Advise is to install Cygwin with make, because they use a lot of shell scripting which doesn't work on Windows.

OK, so this example is not so simple on Windows. In the end I decided to write my own Windows Makefile for my own c++ code and run it with `mingw32-make`.

You can find my personal examples in this [repository called embedjuliainc](https://github.com/matthijscox/embedjuliainc/).

### Interlude: Makefiles?

Compiling c/c++ projects generally involves a lot of steps to compile multiple files and link libraries together. This can become a complex build process and you don't want to type all commands manually all the time. So people made build tools! Yay! Typically these come with their own kind of scripting language that you need to learn. Hmm, OK, just do it. It's also generally Unix oriented, not Windows. Make is a one common build tool, here's a [Makefile tutorial](https://makefiletutorial.com/).

As an example, I enjoyed this [g++ makefile example](https://earthly.dev/blog/g++-makefile/). It explains all compilation steps and how to make a Makefile for our simple example c++ program above. Very informative, please read and try it out!

### Interlude: Name Mangling

Another thing that is different in all my examples below, is that c++ mangles the names of functions. That means that a function `f(int)` get's turning into something like `__f_i(int)`. To avoid this we need to use [extern C](https://www.geeksforgeeks.org/extern-c-in-c/) whenever we define function interfaces. This took me a while to figure out, so a lesson learned the hard way!

```cpp
extern "C"
{
    #include "julia_init.h"
}
```

## Basic Types

I created an example of basic type data transfer between Julia and c++ in this [repository](https://github.com/matthijscox/embedjuliainc/tree/main/basic). It contains implementations of the following data types:
* Booleans
* Integers
* Doubles
* Strings
* Structs
* Arrays
* Enumerations

For a full comparison look at:
* The Julia source code file [BasicTypes.jl](https://github.com/matthijscox/embedjuliainc/blob/main/basic/BasicTypes/src/BasicTypes.jl)
* The C++ file calling into the Julia library in [basic.cpp](https://github.com/matthijscox/embedjuliainc/blob/main/basic/main-cpp/basic.cpp) which uses [basic.h](https://github.com/matthijscox/embedjuliainc/blob/main/basic/BasicTypes/build/basic.h).

In general Julia's [C interface documentation](https://docs.julialang.org/en/v1/base/c/#C-Interface) is your friend.

The typical pattern is straightforward, this Julia code:
```julia
Base.@ccallable function test_int64(myInt64::Int64)::Int64
    return myInt64
end
```

You can call with such c++ code:
```cpp
int64_t test_int64(int64_t myInt64);
int64_t myInt64 = 9006271;
test_int64(myInt64);
```

### Header file

The `PackageCompiler.create_library` function also likes to receive a header file. So please write all your c/c++ interface types and functions inside this header file. I wonder if this header file could be created automatically from all the `Base.@ccallable` function signatures? Now you have to manually keep the Julia source code and the header file in sync.

### Struct types

As the manual says on [Struct Type Correspondences](https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/#Struct-Type-Correspondences). Structs can be passed. Fixed size arrays in c/c++ map onto the `NTuple` in Julia.

Nested structs work just fine:
```julia
struct ChildStruct
    ChildStructId::Cint
end

struct ParentStruct
    ParentStructId::Cint
    myChildStruct::ChildStruct
    staticArray::NTuple{3, Cint}
end

Base.@ccallable function test_nested_structs(myParentStruct::ParentStruct)::ParentStruct
    return myParentStruct
end
```

The corresponding C/C++ interface:
```cpp
struct ChildStruct
{
    int ChildStructId;
};

struct ParentStruct
{
    int ParentStructId;
    ChildStruct myChildStruct;
    int staticArray[3];
};

ParentStruct test_nested_structs(ParentStruct myParentStruct);
```

### Passing by reference

If you want to avoid any copying and additional memory allocation, you will have to pass the data by reference as a pointer. A typical example is to pass an array by reference. In the example code I pass an `Array{Cint}`. Note that you also need to pass the dimensions of the array, in this case only the length, since we assume it's a vector.

```julia
Base.@ccallable function test_array(myArrayPtr::Ptr{Cint}, myArraySize::Cint)::Cvoid
    myArray = unsafe_wrap(Array{Cint}, myArrayPtr, myArraySize, own=false)
    # do stuff, mutating an element will mutate the original C memory, be careful
end
```

### Mutating

Let's pass a struct by reference and mutate it. You can first load the entire struct with `unsafe_load`.

```julia
Base.@ccallable function test_nested_structs_ptr(myParentStructPtr::Ptr{ParentStruct})::Cvoid
    myParentStruct = unsafe_load(myParentStructPtr)
    myParentStruct.myChildStruct = ChildStruct(12)
    return Cvoid()
end
```

For arrays you can first `unsafe_wrap` like in the section above. Or you can immediately `unsafe_store!` on an individual element. As always be very careful with these operations.

### Nested variable sized structs

Be careful with placing variable-sized arrays inside structs (this includes strings). You will have to somehow pass along the array size and manually unwrap such complexity. I still have to write a complex example for this. The Julia manual has a very minimal example in the ["Calling C and Fortran"](https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/#Struct-Type-Correspondences) section.

For example, I would like to pass such a structure by reference:
```julia
struct VarSizedStruct
    len::Cint
    varArray::Array{Cdouble}
    string::Cstring
end
struct NestedVarStruct
    len::Cint
    varArray::Array{VarSizedStruct}
end
```

I don't know if it is a smart thing to do. You'll have to manually interpret the bytes...

I think the best way to go, is to place pointers inside the structs and to manually `unsafe_wrap` every array.
```julia
struct VarSizedStruct
    lenArray::Cint
    varArrayPtr::Ptr{Cdouble}
    lenString::Cint # in case the string is not NUL-terminated
    string::Ptr{Uint8}
end
struct NestedVarStruct
    len::Cint
    varArrayPtr::Ptr{VarSizedStruct}
end

function Base.@ccallable(nestedPtr::Ptr{NestedVarStruct})::Cvoid
    nested = unsafe_load(nestedPtr)
    len = nested.len
    struct_array = unsafe_wrap(Array{VarSizedStruct}, nested.varArrayPtr, len, own=false)
    last_struct = struct_array[len]
    last_double_array = unsafe_wrap(Array{Cdouble}, last_struct.varArrayPtr, last_struct.lenArray, own=false)
    last_string = unsafe_string(last_struct.string, last_struct.lenString)
    return Cvoid()
end
```

Basically you are not passing along the struct with data, but a collection of pointers and lengths. You'll have to then manually convert the data to an internal Julia representation of your choosing. It seems error prone and feels like it could be automated.

## Garbage Collector

The manual is clear on [memory management](https://docs.julialang.org/en/v1/manual/embedding/#Memory-Management) from within c/c++. You can even disable the garbage collector if you want.

One thing we ran into while testing the c-callable Julia functions from within a Julia script, is that the garbage collector may remove your object even while the function is executing. This can happen when passing pointers instead of objects and leads to horribly unexpected segmentation faults. Please use the `GC.@preserve` for those cases.

I placed an example in the precompile statements file:
```julia
arr = Cint[1,2,3]
arr_pointer = Ptr{Cint}(pointer_from_objref(arr))
len_arr = Base.cconvert(Cint, length(arr))
# please garbage collector, preserve my array during execution
GC.@preserve arr test_array(arr_pointer, len_arr)
```

## Error handling

A typical old C way of error handling is to always return an integer on the C interface. The Julia code is then responsible for catching errors and returning the corresponding error integer. Any other desired output arguments are passed as mutable input parameters on the C interface. If you want the error messages as well, you could also pass along a struct with the error code/type and a Cstring with the error message. I've added an example with an [ExceptionHandler.jl](https://github.com/matthijscox/embedjuliainc/tree/main/exceptions) package for this case to my repository.

Here's a simple example:
```julia
error_code(::Exception)::Cint = 2

Base.@ccallable function something(inputPtr::Ptr{Cint}, outputPtr::Ptr{Cint})::Status
    resultCode::Cint = 0
    try
        # do stuff
    catch e
        resultCode = error_code(e)
    end
    return resultCode
end
```

But that is not what I am looking for. I want a way to catch Julia exceptions inside c++. The Julia manual [embedding section on exceptions](https://docs.julialang.org/en/v1/manual/embedding/#Exceptions) is not clear on how to do this for native `Base.@ccallable` functions. Through experimentation I found out that exceptions cannot be caught by a regular try/catch block inside the c++ code wrapping around the julia library call.

Let's say we have a function that throws errors on the c-interface:
```julia
Base.@ccallable function throw_basic_error()::Cint
    throw(ErrorException("this is an error"))
    return 0
end
```

### Missed exceptions

This would be an expected way to catch errors, but it doesn't work:

```cpp
try
{
    throw_basic_error();
}
catch (const std::exception& e)
{
    std::cout << "\n a standard exception was caught, with message '"
                << e.what() << std::endl;
}
catch (...)
{
    std::cout << "\n unknown exception caught" << std::endl;
}
```

When running this code, you will see an error like `fatal: error thrown and no exception handler available.`. Our current assumption is that this is due to Julia initializing in another thread or process than the c++ code itself.

### Catch those exceptions

After some digging we found the `JL_TRY` and `JL_CATCH` macros in the Julia header file. These can be used to catch Julia exceptions:

```cpp
JL_TRY {
    throw_basic_error();
}
JL_CATCH {
    jl_value_t *errs = jl_stderr_obj();
    std::cout << "A Julia exception was caught" << std::endl;
    if (errs) {
        jl_value_t *showf = jl_get_function(jl_base_module, "showerror");
        if (showf != NULL) {
            jl_call2(showf, errs, jl_current_exception());
            jl_printf(jl_stderr_stream(), "\n");
        }
    }
    return 1;
}
```

To print the error type and message, you will have to use functions directly from the Julia runtime. We did not yet find a nice and easy way to convert the Julia exception into a c++ exception.

## Outlook

The package [CBinding.jl](https://github.com/analytech-solutions/CBinding.jl) can automatically generate the Julia types from a c header file. There is a lot of knowledge in that package, so I should investigate it better. I also wonder if it's possible to do the opposite: to generate a c header from Julia types and functions.

Other interesting packages are [Cxx.jl](https://github.com/JuliaInterop/Cxx.jl) and [CxxWrap.jl](https://github.com/JuliaInterop/CxxWrap.jl). These packages focus on embedding c++ (libraries) inside Julia, but again contain a lot of knowledge and some examples on embedding Julia inside c/c++.

## Conclusion

Embedding in c/c++ is non-trivial. I advise to avoid embedding if you can ;) If you cannot avoid embedding, then use the examples from this post, but I do not guarantee that all my examples are safe and robust. I did not yet create examples with complicated nested variable sized structures and arrays, that's for another time. For now I'd advise to keep the c-interface as simple as possible. Good luck!

## Acknowledgements

Special acknowledgements to Daan Sperber, Biao Xu and Evangelos Paradas for helping me figure out a lot of the steps involved.

{{ addcomments }}