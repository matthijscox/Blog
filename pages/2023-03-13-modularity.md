@def published = Date(2023, 03, 13)
@def hascode = true
@def title = "Modularity"
@def authors = """Matthijs"""
@def rss = "Modularity"
@def tags = ["software", "philosophy"]

# Modularity

After you've spend some time in software development, you'll have encountered the term modularity. Either modularity was explained to you, or you learned about modularity through experience, or by feeling the pain of non-modular software. I'm going to write down some aspects that were never explained to me and fall in the latter two categories.

## What is a module?

A module is a part of a system that's as independent as possible.

You can read wikipedia on [Modularity](https://en.wikipedia.org/wiki/Modularity) and [Modular Programming](https://en.wikipedia.org/wiki/Modular_programming). Basically a 'system' can be broken down into parts or 'subsystems' or 'components' or 'modules', which ideally have little dependency on each other. It's all about [loose coupling](https://en.wikipedia.org/wiki/Loose_coupling).

Low dependency between parts has the advantages that you can replace the parts more easily, parts can be re-used in multiple places and humans/agents can understand these simpler parts without always having to understand the whole. So it's about upgrade, reuse, and easier development.

~~~
<div class=figure>
  <img src="/img/Modules.jpg" style="width:80%;padding-left:10%;margin-bottom:0">
  <p>All modules are imaginary. We define them to make sense of the system for ease of manipulation.</p>
</div>
~~~

This is all very abstract. How do you make people _feel_ the need for modularity?

## Design versus production

A lot of modularity talk I encountered was about the design and development of the software source code. Something that was hardly explained to me is how this is different from the 'modules' running in production.

It might be intuitively clear to compiled language programmers, like in C/C++, with enough experience compiling, linking and deploying multiple libraries. But if you have spend all your time writing Python or Java, then I don't think the concept is always obvious.

You can write highly modular, decoupled code. And then dump it all into one single production module. This 'production module' can be one of many things, ranging from a compiled library to a virtual machine. Note that if you have a microservice architecture, but you couple all the microservices together, then they may still form one single intertwined module. The point is not what technology you use for the 'module'.

So I like to separate into three different scenarios:
* monolith source code, monolith product
* modular source code, monolith product
* modular source code, modular product

~~~
<div class=figure>
  <img src="/img/Modularity.jpg" style="width:100%;padding-left:0%;margin-bottom:0">
</div>
~~~

When you start out with a little project, all by yourself or with a few people, then unless you take some time to think, you'll probably start with a full monolith. It's just _easy_.

The middle path is often chosen by projects that have to deploy to multiple environments. For example a startup with an embedded hardware device and a cloud application. You probably don't want to deploy all your application code onto your little hardware device, so you'll be forced to separate it. But in both production environments (cloud and device), you are the only one deploying something, so it's fine to keep everything there as one coupled entity. The main reason to switch to multiple production modules, might be to upgrade for example the UI while the backend keeps running, but often you can get away with upgrading everything at once for a while.

The final path, modularity on both sides, is more likely at larger organizations that want to upgrade different parts of the system at different times by different people, instead of taking down the entire system for longer times to replace a small part.

Modularity in the design phase mostly benefits the development effectiveness. It's all about minimizing communication between people and minimizing their cognitive load, so they can change the code more easily.

Modularity in production mostly benefits the software system itself. Parts can run independent from each others. Parts can be re-used. Parts can be swapped independent from others. It does help people as well, because they can deliver parts independent from other people, but this can also be tackled in the source code delivery.

![team development](/img/ModularityTeams.jpg)

An organization can apply all these options all at once, where different teams work with different levels of modularity. Let's call the modules deployed in production "artifacts", that's a typical name. (Naming things has a weird power and is a strange art, this needs another blog post.)

One team can have a monolith codebase, deploy one artifact to production, but it runs next to other artifacts. Another team might be delivering a code module to another team, which deploys that together with their own code modules into one or more artifacts. And yet another team might have a modular codebase deploying multiple artifacts to multiple production environments, one of which it controls entirely and so it chooses to deploy a monolith artifact there. Anything goes in software development as long as you are succesful.

## Excercises

While writing this post I realize all this modularity talk is very abstract. This is a typical risk I see with software architecture; it becomes so generic that it loses any concrete value. Complaints about software architects often involve their inability to design and create pragmatic systems. They lose touch with the struggles of the software developers. I've heard the term "astronaut architect" to describe this ivory tower behavior.

Let's define a more concrete playful excercise. Take any idea you have, or write some dummy code, and define the following client-server architecture:
* Write one module that will act as a server, for example a Python REST server.
* Write two modules in a compiled language that can link separately compiled libraries. If you can, make one library the client towards the server.
Deploy all into a virtual machine, or your own laptop.

Try swapping parts.
* Update one compiled library component and re-link it.
* Update (a part of) the server.
Can you do all this while the system is running? Can you easily add a new part to the system?

What if multiple people or teams would be working on these components. How would you setup the development environment for them? How would you distribute the components over them? How will you test that the behavior of each component is correct? How will the developers know how the components should communicate with each other (what are the APIs)? How will you change the system if the requirements change? How will you change the development organisation in parallel with system changes?

All enterprise software innovation seems to revolve around being able to update and migrate code effectively, while letting hundreds or thousands of software developers work together all at once. And the software system must keep functioning optimally and correctly.

Another analogy: how to write a book with hundreds of people? The book may be millions of pages, so you cannot solve this problem by giving the work to the best writer. How will you distribute the work, while still maintaining a coherent narrative? Some of the technology will be about the binding and distributing of the books, but most effort will go into solving this parallel human coordination problem.

Large scale software development is all about people and our cognitive limitations. Modularity helps to manage our cognitive load. In this form modularity benefits many concrete systems in our world. Manipulating the concept of 'modularity' itself however remains an arcane art.

{{ addcomments }}