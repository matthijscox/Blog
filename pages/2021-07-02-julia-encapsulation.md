@def published = Date(2021, 07, 02)
@def hascode = true
@def title = "Julia Encapsulation"
@def authors = """Matthijs"""
@def rss = "Reflections on encapsulation in the Julia language"
@def tags = ["julia", "code"]

# Julia Encapsulation

Julia is a language that provides no easy encapsulation out of the box. It's a language that evolved in the open source world, so collaboration and re-usability are key. Julia has no reason to block people from accessing data or functions.


Corporations are different. We're running into some discussions with c++ developers, for whom encapsulation is a basic desire. I would like to form a better opinion on this topic. (Some even think it's my job to have an opinion on such esoteric subjects.) 

Encapsulation means the ability to wrap data and functions into some unit (often a class) AND to prevent access to some of these functions and data. The information that can be accessed from the outside is often called _public_, the hidden information is called _private_.


The Julia handbook from Tom Kwong has a chapter devoted to encapsulation, he states the following reasons for encapsulation in his Robustness chapter:


> Based on the Principle of Least Privilege (POLP), we would consider hiding unnecessary implementation details to the client of the interface. However, Julia's data structure is transparent – all fields are automatically exposed and accessible. This poses a potential problem because any improper usage or mutation can break the system. Additionally, by accessing the fields directly, the code becomes more tightly coupled with the underlying implementation of an object.

Here's also a [blog post](https://github.com/ninjaaron/oo-and-polymorphism-in-julia) from someone who talks about encapsulation and goes into more expected OO concepts and their relation to Julia.

What are all the places where we may want to protect things? I can think of the following:
* Functions
* Types
* Modules


## Functions
I hope you know what functions are. But do you really? They take input, execute some more functions and create output. They can also mutate the input. They have a local scope, in Julia that means that something from the outside cannot access the inside.


So... you have encapsulation on the inside? Jep, a function is a lovely unit that automatically encapsulates data and functions defined within its scope. Great!


Here's an example, a function containing a function and a variable. You cannot access them.
```julia
function example()
    x = 5
    function inside()
        y = 6
    end
end

julia> example.x
ERROR: type example has no field x

julia> example.inside
ERROR: type example has no field inside
```


So Julia has encapsulation in functions. Oh wait, there is no way to make these things public, so others cannot re-use them even if we wanted to. Basically everything is private. Hmm... we want the option to choose between what is public and private.


Actually we can just make the function return the public stuff. We can even get very creative by returning local functions from functions that mutate local variables, see this example:


```julia
function test()
    x::Int64 = 2
    function get_x()
        return x
    end
    function add_x(y::Int64)
        x += y
        return nothing
    end
    return (get_x = get_x, add_x = add_x)
end

julia> t = test()
julia> t.add_x(4)
julia> t.get_x()
6
```


Making a function return a local function is called a [closure](https://en.wikipedia.org/wiki/Closure_(computer_programming)). In our case above it adds unnecessary complexity in my opinion, so I wouldn't advise this pattern, but it does the encapsulation job, right?


Functions do all the work. Data passes through them. Functions call other functions. When people talk about encapsulation to prevent access, they basically mean that functions outside your designated unit (often a class) should not be able to access your private stuff.

Now what? Well I'm not sure yet, let's just move on to composite types and their properties.


## Composite Types
Data in Julia is always stored in composite types. Some consider these types like classes without methods. So if you want to prevent access to data, then types might do the work.


You just want to avoid write access? Then it's easy, just make your type immutable. Which it is by default.


Want to avoid write access to a subset of fields? Split off the data into a mutable and an immutable type. Make a composite type of the two of them. Sounds good enough to me.


You want to also avoid read access? That is a bit harder.

First: make it clear to the users that this is private data. The guideline is an underscore in front of the field name, like `_my_private_data`. That reduces the chance of accidents. Obviously this is a gentlemen's agreement, they could still access this data, but they would be doing it at their own risk.


To take it a step further, you could define a new method of the `getproperty` and `setproperty!` function for your custom type. That will make it less convenient to get the private fields.


```julia
struct Example
    public
    also_public
    _private
end

function Base.getproperty(example::Example, prop::Symbol)
    public_props = (:public, :also_public)
    if prop in public_props
         return getfield(example, prop)
    else
         throw(UndefVarError(prop))
    end
end

julia> example = Example(1, 2, 3)
julia> example._private
ERROR: UndefVarError: _private not defined
```


If you don't want people to change some properties of a mutable type, then you'll have to use a similar trick for `setproperty!`. 
In Julia you can change the behavior of your type entirely by easily 'overloading' all relevant functions that dispatch on your type.


But what if the user explicitly calls the `getfield` and `setfield`? Your users are somekind of ninja spies and they really want your data. Personally, I would stop worrying about encapsulation and start worrying about real world security.


There is again a creative option with closures to make it even harder to access the properties, similar to the previous section. You initialize a type with functions as properties. Basically you combine functions (everything private) with types (everything public).


```julia
# the private stuff
struct _Rectangle
  width::Float64
  height::Float64
end

# the public stuff
struct Rectangle
  area::Function
end

# the closure trick
function Rectangle(width::Float64, height::Float64)
  self = _Rectangle(width, height)
  area() = self.width * self.height
  return Rectangle(area)
end

# it works!
julia> rect = Rectangle(4.0, 5.0)
julia> rect.area()
20
```


Good luck accessing those private properties now. Not sure if this is always results in the most performant code, but it's a fun intellectual excercise.


I never used this approach, but if you do go this route, be careful when defining multiple constructors, they should all return a type that behaves the same, else I expect confusion from your users. The behavior of the type depends now on the local functions that are assigned to it in the constructor function. I don't like that, the behavior of a specific type should be known based on the type definition itself. Definitely don't make it mutable, imagine if someone injects another function into the type properties.


Note: there is a [discussion about internal properties](https://github.com/JuliaLang/Juleps/pull/54). That may provide the final solution one day.


### Reasons to avoid data access?


Let's say you designed a lovely custom type, with some lovely data on the inside that's a bit hard to understand. You want to provide the user with some easy interface and hide all these messy details. 


The DataFrame is a good example. It has a simple interface, you just select rows and columns via the `getindex`, which looks like `df[row, column]`. Column selection and inserting can go via `getproperty` and `setproperty!` looking like `df.new_column = [1, 2, 3]`. Lovely interface, no need to look at the internal machinery.


Next there is the possibility that people ignore the interface, go into the internals and accidentally break something.

Let's look for something to break. I'll take the `Dict` type in Julia. It's interface is simple, you add key-value pairs with the `getindex` again. It remembers the number of pairs, which you can access via `length`, but you can totally break the dict by mutating the underlying count property:


```julia
julia> d = Dict()
julia> d[:a] = "bla"
julia> length(d)
1
julia> d.count = 4
julia> length(d)
4
julia> [v for (k,v) in d]
4-element Vector{String}:
    "bla"
 #undef
 #undef
 #undef
```


I've never seen this happening. It just shows that all those Julia users never break the Dict in their code, because the internals are simply not documented. Who would be smart enough to read the internal source code, yet foolish enough to break it? 


## Modules and packages
Functions (and type constructors) are embedded inside modules for others to re-use. A package is just a well defined module that you can easily install and use. (If you are directly `include()`-ing raw source code from others into your code to re-use their functions, you are doing it wrong.)


So if we want to avoid access to functions, we need to make modules do the work. To a module, functions are basically data fields that get accessed. The approach is described by Tom Kwong in his book. You wrap a let block (fully private) into a module (fully public). Any functions that you declare `global` in the let block will be available in the module scope.


```julia
module Example   
    let x = 0, y = 2
        global function add_one()
            x += 1
            return nothing
        end
        global function print_x()
             return private_print()
        end
        function private_print()
             return println(x)
        end
    end
end

julia> Example.print_x()
0
julia> Example.add_one()
julia> Example.print_x()
1

julia> Example.x
ERROR: UndefVarError: x not defined

julia> Example.private_print
ERROR: UndefVarError: private_print not defined
```


Note that we can hide both persisting types and functions in the let block of the module.


The general lesson to hide stuff in Julia: get creative with [scopes](https://docs.julialang.org/en/v1/manual/variables-and-scoping/).


### Reasons to avoid access to functions?


Why would you want to stop users from using your functions?


Maybe this function is some internal function that is not part of the public API and may change later in the future? That means you didn't write a docstring for users, nor did you export it. You can add an underscore in front for extra clarity. All these things should be sufficient "no threspassing" signals for good users to understand the risk of using this private function.


You don't want some entangled mess of function calls throughout your own code? In other words, you want to reduce [coupling](https://en.m.wikipedia.org/wiki/Coupling_(computer_programming))? Then don't make it part of the public package API. Anyway, designing a good interface requires lots of thinking. Mindlessly making things private won't help you.


If your users really like all your internal functions, maybe you should talk to them about it. Perhaps it's good to improve the formal API, or rewrite them into a separate package and manage these facilities officially?


## Conclusion


I think the most important reasons to hide things in the code are:
1. To abstract details away behind an interface. Make your code easier to use, since the user doesn't need to understand the details. And make it more maintainable, since the developer can change the details as long as the behavior remains equal.
2. To avoid strongly coupled systems, where one subsystem uses a lot of internals from another subsystem. Again this is for maintainability (most code advice is). You want to avoid a tangled mess, where one local change has unexpected system wide impact, leading to much extra work.
3. To protect against unwanted behavior. Someone else may accidentally change the state of your program by changing a variable at runtime.


I think these are perfectly reasonable desires. But none of them require you to actually hide things. There are other options.


Julia is really good at making things easy for the user. You can dispatch any existing Base functions onto your new custom type. Voila, new interfaces! 


You don't want people to change your data? Make the type immutable!


Don't want to make the type immutable? Clearly indicate it's a private property, with underscores. Go the extra mile by writing a specific `setproperty!` for your type.


Also try to avoid persisting states if possible. Lovely quote from the Erlang founder in [this post](http://harmful.cat-v.org/software/OO_programming/why_oo_sucks).
> State is the root of all evil. In particular functions with side effects should be avoided.


You don't want people to read your data or functions? 
Add an underscore and don't document them. Clearly document the public exported functions instead. Make the public functions super easy to use!


Really, really don't want people to access your data and functions?
Drop them inside a let block inside a module.


Also I hope you have a test suite that tests your system, so stuff cannot be broken accidentally.


When collaborating with other humans (in a single codebase), you should assume their intentions in the following order:
* Good intentions
* Ignorance
* Bad intentions
I believe you should design your codebase accordingly for good intentions and expect some ignorance. Bad intentions need to be dealt with outside the code base.


Therefore, I believe we should worry less about protecting our privates and focus more on clearly describing what the public interface is. And remove all resistance to using the public interface, keep it simple and easy, thereby rewarding the use of the public interface over any internals. 


Stop hiding things, start making things simple. That's the real spirit of encapsulation.


{{ addcomments }}