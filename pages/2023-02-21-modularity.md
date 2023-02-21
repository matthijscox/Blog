@def published = Date(2023, 02, 21)
@def hascode = true
@def title = "Modularity"
@def authors = """Matthijs"""
@def rss = "Modularity"
@def tags = ["software", "philosophy"]

# Modularity

After you've spend some time in software development, you'll have encountered the term modularity. Either modularity was explained to you or you learned through osmosis or by failing a lot. I'm going to write down some aspects that were never explained to me and fall in the latter categories.

## What is a module?

In software a module is pretty abstract and can refer to several things. You can read wikipedia on [Modularity](https://en.wikipedia.org/wiki/Modularity) and [Modular Programming](https://en.wikipedia.org/wiki/Modular_programming). Basically a 'system' can be broken down into parts or 'subsystems' or 'components' or 'modules', which ideally have little dependency on each other. It's all about [loose coupling](https://en.wikipedia.org/wiki/Loose_coupling).

Little dependency has the advantages that you can replace the parts more easily, parts can be re-used in multiple places and humans can understand these simpler parts without always having to understand the whole. So it's about upgrade, reuse, and easier development.

## Design versus production

A lot of modularity talk I encountered was about the design and development of the software source code. Something that was hardly explained to me is how this is different from the 'modules' running in production.

It might be intuitively clear to compiled language programmers, like in C/C++, with enough experience compiling, linking and deploying multiple libraries. But if you have spend all your time writing Python or Java, then I don't think it's always obvious.

You can write highly modular, decoupled code. And then dump it all into one single production module. This 'production module' can be one of many things, ranging from a compiled library to a virtual machine.

So I like to separate into three different scenarios:
* monolith source code, monolith product
* modular source code, monolith product
* modular source code, modular product

~~~
<div class=figure>
  <img src="/img/Modularity.jpg" style="width:100%;padding-left:0%;margin-bottom:0">
</div>
~~~

When you start out with a little project, all by yourself or with a few people, then unless you take some time to think, you'll probably start with a full monolith. It's just easy.

The middle path is often chosen by starting projects that have to deploy to multiple environments. For example a startup with an embedded hardware device and a cloud application. You probably don't want to deploy all your application code onto your little hardware device, so you'll be forced to separate it. But in each production environment, you are the only one deploying something, so it's fine to keep everything there as one coupled entity. The main reason to switch to multiple production modules, will be for upgrading for example the UI while the backend keeps running, but often you can get away with upgrading everything at once for a while.

The final path, modularity on both sides, is more likely at larger organizations that want to upgrade different parts of the system at different times, instead of taking down the entire system for long times to replace a part.

Modularity in the design mostly benefits the development effectiveness. It's all about minimizing communication between people and minimizing their cognitive load, so they can change the code more easily.

Modularity in production mostly benefits the software system itself. Parts can run independent from each others. Parts can be re-used. Parts can be swapped independent from others. It does help people as well, because they can deliver parts independent from other people, but this can also be tackled in the source code delivery.

Obviously an organization can apply all these options all at once, where different teams work with different levels of modularity.

![team development](/img/ModularityTeams.jpg)

{{ addcomments }}