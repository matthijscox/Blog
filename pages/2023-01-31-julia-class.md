@def published = Date(2023, 01, 30)
@def hascode = true
@def title = "Julia Classes"
@def authors = """Matthijs"""
@def rss = "Julia Classes"
@def tags = ["julia", "code"]

# Julia Classes

This post is for educational purposes only.

Someone asked in my [Julia Encapsulation post](https://www.functionalnoise.com/pages/2021-07-02-julia-encapsulation/) how to code a more conventional object-oriented class in Julia. If you ignore class inheritance, then I assume we are talking about a composite type with methods inside that you can call via `object.method(args...)`.

> Note that in Julia a [method](https://docs.julialang.org/en/v1/manual/methods/#Methods) is an instance of a function. In this post I might be using the terms a little interchangable, due to my mental confusion with some other OO language terminology of methods vs functions. I will also use [type](https://docs.julialang.org/en/v1/manual/types/#Composite-Types) vs class vs struct definitions interchangeable, but an object is an instance of a type.

Pseudo-code of a Julia type with contained methods would look like:

```julia
mutable struct MyClass
  myInt::Int

  function print_int(self::MyClass)
    println("hello, I have myInt: $(self.myInt)")
  end

  function set_int!(self::MyClass, new_int::Int)
    self.myInt = new_int
  end

  function MyClass(int::Int)
    return new(int)
  end
end
```

Which you then call via:

```julia
obj = MyClass(5)
obj.set_int!(8)
obj.print_int()
```

The struct definition syntax above is actually possible in Julia, but doesn't do what you want. The inner methods are **not** available as properties. You will get the following error:

```julia
julia> obj.set_int!(8)
ERROR: type MyClass has no field set_int!
```

What's the closest we can get?

I think we have two options available:
* use immutable fields of type function inside the struct
* define a custom `getproperty` method that returns functions

Let's try them both and see how they feel.

## Functions as fields

Simple solution: we turn the functions into immutable fields and set them in the constructor. Please consider all possible horrors if you accidentally make these fields mutable and the user inserts a custom function into your field.

I will place the code inside a module, which is typically how you will share your types anyway. This also shows the one advantage of using the dot syntax to access functions. Now you do not have to export the functions or call them via the module namespace, the type itself carries the functions.

```julia
module MyModule
  mutable struct MyClass
    myInt::Int

    # we have these `const` fields since Julia 1.8
    const print_int::Function
    const set_int!::Function

    function print_int(self::MyClass)
      println("hello, I have myInt: $(self.myInt)")
    end

    function set_int!(self::MyClass, new_int::Int)
      self.myInt = new_int
      return self
    end

    function MyClass(int::Int)
      obj = new(
        int,
        ()->print_int(obj),
        (new_int,)->set_int!(obj, new_int),
      )
      return obj
    end
  end
end
```

This code works and the inner functions remain somewhat hidden, you cannot directly access them in the module. You can also move the functions outside the struct definition, and into the module. The result will be similar. The difference is that the functions are no longer hidden, you can access them via `MyModule.print_int(obj)`.


```julia
julia> obj = MyModule.MyClass(5)
Main.MyModule.MyClass(5, Main.MyModule.var"#1#5"{Main.MyModule.var"#print_int#3"}(Core.Box(Main.MyModule.MyClass(#= circular reference @-3 =#)), Main.MyModule.var"#print_int#3"()), Main.MyModule.var"#2#6"{Main.MyModule.var"#set_int!#4"}(Core.Box(Main.MyModule.MyClass(#= circular reference @-3 =#)), Main.MyModule.var"#set_int!#4"()))

julia> obj.print_int()
hello, I have myInt: 5

julia> obj.set_int!(8).print_int()
hello, I have myInt: 8

```

For extra fun I made the `set_int!` return the mutated object, so we can chain the function calls. This is extremely convential looking OO syntax. I did keep the exclamation mark `!` for mutating function names. This is Julia after all.

Downside of this `field::Function` approach is that by default you get a lot of circular references in the REPL display. We can get rid of the circular reference display by defining a custom `Base.show` function. Here's a straightforward attempt:

```julia
function Base.show(io::IO, obj::MyModule.MyClass)
  print(io, "$(typeof(obj))($(obj.myInt))")
end
```

Now it will display more conventially:

```julia
julia> obj
Main.MyModule.MyClass(5)
```

## Functions as custom properties

In this approach we will return functions when calling the `getproperty` method on our custom type. Note that we need to make the functions available in the module scope, so no hiding of functions.

```julia
module MyModule
  mutable struct MyClass
    myInt::Int
  end

  function print_int(obj::MyClass)
    println("hello, I have myInt: $(obj.myInt)")
  end

  function set_int!(obj::MyClass, new_int::Int)
    obj.myInt = new_int
    return obj
  end

  function Base.getproperty(obj::MyClass, prop::Symbol)
    if prop == :myInt
      return getfield(obj, prop)
    elseif prop == :print_int
      return ()->print_int(obj)
    elseif prop == :set_int!
      return (new_int,)->set_int!(obj, new_int)
    else
      throw(UndefVarError(prop))
    end
  end
end
```

Now you can access the functions again as properties:

```julia
julia> obj = MyModule.MyClass(5)
Main.MyModule.MyClass(5)

julia> obj.set_int!(8)
Main.MyModule.MyClass(8)

julia> obj.print_int()
hello, I have myInt: 8

```

## Conclusion

Either of the options above could be automated away with a macro. Let's call that macro `@class`. I will not meta-program that macro here, but then it could look like the pseudo-code at the start. Everything is possible in Julia if you really want it. Some say that's an advantage, some say that's a disadvantage.

```julia
module MyModule
  @class mutable struct MyClass
    myInt::Int

    function print_int(self::MyClass)
      println("hello, I have myInt: $(self.myInt)")
    end

    function set_int!(self::MyClass, new_int::Int)
      self.myInt = new_int
    end
  end
end
```

What is considered OO? The Rust manual section ["What is OO"](https://doc.rust-lang.org/book/ch17-01-what-is-oo.html) states:
* _Objects contain data and behavior._ Confirmed in this post.
* _Encapsulation that Hides Implementation Details._ Discussed in a [previous post](https://www.functionalnoise.com/pages/2021-07-02-julia-encapsulation/).
* _Inheritance as a Type System and as Code Sharing._


Actually Julia objects already contain behavior via multiple dispatch. All I did was implement the syntactic sugar often provided with class-based object oriented programming languages. This might give you more feeling of belonging.

I did not try to write an implementation for class inheritance. Maybe it can be done with some very complex meta-programming. But like the Rust language, a trait based approach is more suitable for Julia, see for example discussions in [Traits.jl](https://github.com/mauro3/SimpleTraits.jl).

To repeat: I wrote this code for educational purposes only. I would not advise to use such coding patterns in large scale Julia code bases. Please stick to exporting (public) methods and keep the style more Julian. But perhaps this post can help you better understand Julia, especially if you have only been exposed to strictly class-based object oriented programming styles.

{{ addcomments }}