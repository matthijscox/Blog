@def published = Date(2021, 04, 20)
@def hascode = true
@def title = "C++ Array Printing"
@def authors = """Matthijs"""
@def rss = "C++ Array Printing - exploring how to print vector arrays in c++"
@def tags = ["programming"]

# C++ Array Printing

I'm teaching myself some simple c++ in order to work on this [Brainflow PR](https://github.com/brainflow-dev/brainflow/pull/270). To start, all I want is to display the contents of an array. I'd prefer to convert it first to a string, so I can dump it into a logging system. And what the heck, let's generalize it a bit.

So in Julia I would want something like this:

```julia
julia> display([1, 2, 3])
3-element Vector{Int64}:
 1
 2
 3

 julia> display([1.0, 2.0, 3.0])
3-element Vector{Float64}:
 1.0
 2.0
 3.0
 ```

First of all, I am still a proud Windows user (I can hear you curse), so I am using this [Visual Studio compilation method](https://docs.microsoft.com/en-us/cpp/build/walkthrough-compiling-a-native-cpp-program-on-the-command-line?view=msvc-160). I am using Visual Studio Code for coding, with the most popular c++ extension I could find.

Let's say I want to control the appearance of each element, then I'd have to use something like sprintf. Actually there are some [different options](http://www.cplusplus.com/forum/general/48362/), but this flavor is apparantly best:

```C
#include <iostream>
#include <stdio.h>
#include <string>
using namespace std;

int main()
{
    string str = "[";
    char stemp[100] = "";

    int arr[] = { 1, 2, 3, 4 };
    int size = 4;

    // trying to convert an array to a string in a for-loop
    for (int i = 0; i < size; i++) {
        snprintf(stemp, 100, "%u", arr[i]);
        str.append(stemp);
        // str.to_string(arr[i]); // alternative, but no control over appearance
        if (i < size - 1) {
            str.append(", ");
        }
    }
    str.push_back(']');
    
    cout << str << endl;
}
```

This will output: `[1, 2, 3, 4]`

Turns out you can also use [str.to_string](https://en.cppreference.com/w/cpp/string/basic_string/to_string), which looks easier, but you lose some control over the appearance of the converted integer.

Side remark. Where are the docstrings in the source code in c++, hmm? It seems I have to Google every single thing. When I ctrl+click on a function to browse the source code, I arrive at all kind of funny looking code, no explanations of the behavior. Maybe I need to grow some c++ muscle, or I just keep Googling I guess.

Now let's put all the above into a lovely function, to remember again how functions and pointers work (note: some Googling involved as usual):

```C
string print_vector(int size, int *arr) { 
    string str = "[";
    for (int i = 0; i < size; i++) {
        str.append(std::to_string(arr[i]));
        if (i < size - 1) {
            str.append(", ");
        }
    }
    str.push_back(']');
    return str;
}

int main() {
    int arr[] = { 1, 2, 3, 4 };
    int size = 4; 

    string str = print_vector(size, arr);
    cout << str << endl;
}
```

Yeah, still works. Maybe I should write a unit test, hmm? Turns out it's a [testing jungle](https://gamesfromwithin.com/exploring-the-c-unit-testing-framework-jungle) out there with lot's of [frameworks](https://accu.org/journals/overload/15/78/main_1326/). Ok, I am going to be a bad boy for now and write no tests.

Obviously, I can change the function signature above to `print_vector(int size, double *arr)` and voila, I can print a double array:
```C
[1.000000, 2.000000, 3.000000, 4.000000]
```

In principle I am done. But I'd prefer to have one function that can operate on multiple types of arrays. I am a sucker like that. It is trivial in Julia, but is it possible in c++? Yes, thanks to some colleagues I know that we have [templates](https://www.cplusplus.com/doc/oldtutorial/templates/). Let's try.

So I just write the following, and it works fine. For the fun of it, I added the [typeid name](https://bytes.com/topic/c/answers/878171-any-way-print-out-template-typename-value), which may not always work well they say (the whole internet seems filled with people explaining a certain c/c++ pattern and than warning against it).

```C
template <typename T>
string print_vector(int size, T *arr) { 
    string str = "";
    str.append(typeid(arr).name());
    str.push_back('[');
    for (int i = 0; i < size; i++) {
        str.append(std::to_string(arr[i]));
        if (i < size - 1) {
            str.append(", ");
        }
    }
    str.push_back(']');
    return str;
}

int main() {
    int int_arr[4] = { 1, 2, 3, 4 };
    double double_arr[4] = { 1.0, 2.0, 3.0, 4.0 };
    int size = 4; 

    // templating the function call is optional apparantly
    cout << print_vector(size, int_arr) << endl;
    cout << print_vector<double>(size, double_arr) << endl;
}
```

That outputs the following:
```C
int *[1, 2, 3, 4]
double *[1.000000, 2.000000, 3.000000, 4.000000]
```

That's good enough for my purposes right now. There is a whole world of c++ macros and metaprogramming I can see ahead, but I won't dive into right now. Ofcourse there are also all the object-oriented design patterns I could learn. Another aspect is how to build complex c++ systems with lot's of libraries; Brainflow uses [cmake](https://cmake.org/), I might later want to dive into learning how that works.

Well, this whole excercise took me about 3 hours of my life, but I learned some nice tidbits about c++.

{{ addcomments }}