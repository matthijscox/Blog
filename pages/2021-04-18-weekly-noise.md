@def published = Date(2021, 04, 18)
@def hascode = true
@def title = "Weekly Noise"
@def authors = """Matthijs"""
@def rss = "Weekly Noise - blurting out some thoughts"
@def tags = ["noise"]

# Weekly Noise

 Just need to get some mental noise out of my brain. That's why it's important to keep writing. 


Here are a bunch things I did or thought about this week, some may turn into longer posts. I could just dump these on social media, but then it's all lost in the feed. Now it's like my personal public diary.


Finite vs infinite games re-entered my minds eye via this canadian techie's post on [Why the Canadian tech scene doesn't work](https://alexdanco.com/2021/01/11/why-the-canadian-tech-scene-doesnt-work/). Need to write something about it, also in comparison to my previous post about dark arts. Finite games feel like a dark art.


Also his [world building story](https://alexdanco.com/2021/04/10/world-building/) resonated. Constructing a narrative. Fabricating a meme. Building a new world. Stories are so important to how people think and perceive the world. I know memes are self-reproducing ideas that spread between humans, kinda like genes in our DNA. These 'worlds' he mentioned are virtual entities weaved using multiple memes, a new combination of them or some slight mutations. Companies and nations are such long lasting virtual entities. Humans are their computing substrate. Much can be written about it and the shape of [Moloch](https://slatestarcodex.com/2014/07/30/meditations-on-moloch/) is already known. But here he is talking about spinning up such entities/worlds in just about any context for your own convenience. Sounds like a tool that can be greatly used and abused. I'll need to write more about that.


[Nebulosity](https://metarationality.com/nebulosity). An interesting meta-rationality concept. How does it apply to culture? We can see the shape of culture from far away, like in other companies, countries or ages, but I struggle to see it up close.


Now that I dare to publicly discuss some of my own views I meet more interesting people. This way I met a kindred spirit. Just resonated. Should have talked sooner. Exchanged blogs and podcast links. Though most links I got were from investor types, who write persuasive and have a helicopter view on capital and society, but are not necessarily truth seekers.
(Exploration vs Exploitation: How much should you focus on finding interesting people and topics versus grinding towards a real goal?)


Some of my managers read my blog and posts. I wonder what the effect will be, but if they are truly [clueless](https://www.ribbonfarm.com/2009/10/07/the-gervais-principle-or-the-office-according-to-the-office/) it won't matter.


Interest in (meta-)rational thinking might be bigger than I expected. Maybe I'll write an introductionary post for Dutch/European readers about my take on the rationalist community.


Had a chat with a local investor at [Lumo Labs](https://lumolabs.io/). I hope he plays an infinite game. Most big companies we have in the region were spin-offs from Philips like 20-40? years ago. ASML is the biggest local player now. But what great companies have we started since then? Are we just as bad as the Canadian tech scene?


I have another failure under my belt: I can't ship a package with biosensors to Andrey in Russia. We could not get it to pass all warehouse checks. To repent, I [promised](https://github.com/brainflow-dev/brainflow/pull/270) to write BrainFlow c++ code myself in order to integrate a new biosensor. I haven't coded c since... 12 years ago? How to inspect and experiment quickly in a language without a REPL? Anyway, if I am silent for a while, the most likely reason is I am working on this.


We had an interesting Julia discussion at work about NaN vs Missing vs rejected data. In MATLAB people use `NaN`s a lot. This is easy for handling missing or removed data, but not a great practice. I should write down the arguments once and for all, including steelmanning the `NaN` position. The [Julia manual](https://docs.julialang.org/en/v1/manual/missing/) avoids taking a stance. 
Actually, we may have to explain:
* `NaN`, occurs for operations on numbers that are undefined, like `0/0`. You probably encountered an edge case in your algorithm.
* `Missing`, when there is no value, but theoretically there might be.
* `Nothing`, when there is no value and there never will be.
* `undef`, which is only used in (array) constructors to allocate memory without filling it with a specific value.
* For rejected data, please don't overwrite the value with `Missing`, but define your own type, like:
```julia
struct BooleanNumber{T<:Number} <: Number
    value::T
    valid::Bool
end
```


Two reasons why people cannot follow you:
1. They simply cannot comprehend or you cannot explain your learning journey anymore. The [inferential gap](https://www.lesswrong.com/tag/inferential-distance) is too large.
2. They find your ideas distasteful and too far from the popular norm of society. You have passed outside the [Overton window](https://en.wikipedia.org/wiki/Overton_window).


In my [previous post](https://www.functionalnoise.com/pages/2021-04-11-dark-defense/) I have effectively set up a [Schelling fence](https://www.lesswrong.com/posts/Kbm6QnJv9dgWsPHQP/schelling-fences-on-slippery-slopes) on the slippery slope to becoming ever more political. I don't know if it'll hold, but I am hoping to somehow start a coalition of resistance. 

Commenter vamarkov asked what to do with all these politically savvy micromanagers that live in any big organization. You will have to work with them, right? No, the point is to unite, remove them and build a cultural immune system against such bad practices. In the meantime it'll suck, but find some allies or move to another department or organization if you can. Zvi provides some additional ideas to [fight moral mazes](https://www.lesswrong.com/s/kNANcHLNtJt5qeuSS/p/S2Tgbve2d3vpsNtrQ), but his general advice is to [flee](https://www.lesswrong.com/s/kNANcHLNtJt5qeuSS/p/a8wjKNSGCPSzdWMMa).


Some people responded to my quest to find a good [continuous blood pressure sensor](https://www.functionalnoise.com/pages/2021-04-04-biosensor-goal/). Actually we may be closer to [blood pressure smart watches](https://www.superwatches.com/fitness-trackers-for-blood-pressure/) than I thought. Ideally it should all work well during excercise and I found a [local startup](https://ares-analytics.com/) with a somewhat related mission.


Finally, a fascinating book review of [Progress and Poverty by Henry George](https://astralcodexten.substack.com/p/your-book-review-progress-and-poverty) who asked the question _"How come all this new economic development and industrialized technology hasn't eliminated poverty and oppression?"_ in 1879. The question and answer remain valid today. Laborers create value. Capitalists create rocket fuel for laborers. But by George, The Rent Is Too Damn High, causing all of us to stay still while running faster. Perhaps laborers and capitalists should unite, declare war on the landlords and tax them to death.

{{ addcomments }}