@def published = Date(2023, 02, 13)
@def hascode = true
@def title = "Julia Encapsulated Class"
@def authors = """Matthijs"""
@def rss = "Julia Encapsulated Class"
@def tags = ["julia", "code"]

# Julia Encapsulated Class Example

This post is for educational purposes only.

Bonus post as combination of my previous posts on [Julia Classes](https://www.functionalnoise.com/pages/2023-01-31-julia-class/) & [Julia Encapsulation](https://www.functionalnoise.com/pages/2021-07-02-julia-encapsulation/). Again I do not encourage this behavior in Julia, but it's interesting to explore the pattern.

A typical pattern that conventional OO people like is to hide/encapsulate some private variables. There's multiple ways of achieving this, but let's make a working example. Here I will do it by defining a special class for the private variables. I'll stick to the complex example of mutating one of the private variables.

As explained in the [Julia Encapsulation](https://www.functionalnoise.com/pages/2021-07-02-julia-encapsulation/) blog, I am using a function with a local object to hide the private variables. Except this time it is defined inside the type/class definition.

```julia
module MyModule

  #=
  The private data for our class
  this example has a mutable and an immutable variable
  note: using `const` from Julia 1.8
  =#
  mutable struct _MyPrivateClass
    myInt::Int
    const name::String
  end

  struct MyClass

    # the methods of the class
    get_int::Function
    set_int!::Function
    get_name::Function

    # this function constructs the private data object
    # and returns a function to retrieve this private object
    function get_data_handle(args...)
      private = _MyPrivateClass(args...)
      return ()->private
    end

    function get_int(get_private_data::Function)
      private = get_private_data()
      return private.myInt
    end

    function set_int!(get_private_data::Function, new_int::Int)
      private = get_private_data()
      private.myInt = new_int
      return nothing
    end

    function get_name(get_private_data::Function)
      private = get_private_data()
      return private.name
    end

    function MyClass(int::Int, name::String="unknown")
      private_data_getter = get_data_handle(int, name)
      obj = new(
        ()->get_int(private_data_getter),
        (new_int,)->set_int!(private_data_getter, new_int),
        ()->get_name(private_data_getter),
      )
      return obj
    end
  end

  # to make the REPL display better
  function Base.show(io::IO, obj::MyClass)
    print(io, "$(typeof(obj))($(obj.get_int()),\"$(obj.get_name())\")")
  end
end
```

This works and all the data is completely hidden in your `MyClass`. Users are forced to go through the embedded methods. And to prove we are not accidentally accessing the same global variable I construct two instances and mutate one.

```julia
julia> obj = MyModule.MyClass(5, "foo")
Main.MyModule.MyClass(5,"foo")

julia> obj2 = MyModule.MyClass(6, "bar")
Main.MyModule.MyClass(6,"bar")

julia> obj.set_int!(12)

julia> obj.get_int()
12

julia> obj2.get_int() # proof that obj2 is not mutated
6

```

### Hide more

Yes, in this example the user can just create an instance of `_MyPrivateClass` and work with that. We'd also have to hide that somehow. I cannot place a struct definition inside a function. Maybe we can put it inside a `let` block.

Or we could use [Ref](https://docs.julialang.org/en/v1/base/c/#Core.Ref)'s to variables defined locally inside the `get_data_handle` function, instead of placing them inside this `_MyPrivateClass`. Or define a separate handle/reference for each variable. For example you can define these instead of `get_data_handle`:

```julia
function private_int_handle(int::Int=0)
  ref = Ref(int)
  return ()->ref
end

function private_string_handle(name::String)
  ref = Ref(name)
  return ()->ref
end
```

These references can be accessed via the `getindex`/`setindex!` or `[]`.

```julia
julia> handle = private_int_handle();

julia> ref = handle()
Base.RefValue{Int64}(0)

julia> ref[] = 5
5

julia> ref[]
5

julia> handle()
Base.RefValue{Int64}(5)

```

Now there is no way to accidentally create an object with the private variables.

### Macro everything away

Next to that, all of these coding patterns could be simplified with some macros. For example, I can imagine the following user experience:

```julia
module MyModule
  @class struct MyClass
    myInt::Int
    const name::String

    @getter get_int(self) = self.myInt
    @getter get_name(self) = self.name

    @setter function set_int!(self, new_int::Int)
      self.myInt = new_int
    end
  end
end
```

That would be an interesting excercise left to the reader. [Metaprogramming](https://docs.julialang.org/en/v1/manual/metaprogramming/) in Julia is a whole field on its own.

To repeat: I wrote this code for educational purposes only. I would not advise to use such coding patterns in large scale Julia code bases. Please stick to simple types and independent methods. But perhaps this post can help you better understand Julia, especially if you have only been exposed to strictly class-based object oriented programming styles.

{{ addcomments }}