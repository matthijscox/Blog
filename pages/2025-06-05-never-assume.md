@def published = Date(2025, 06, 05)
@def hascode = false
@def title = "Never Assume Anything"
@def authors = """Matthijs"""
@def rss = "Assumptions"
@def tags = ["journal", "advice"]


# Assumptions

In my years in engineering, one piece of advice echos loudly: "Never Assume Anything". It sounds wise, cautious even, but is it really practical? I've heard this advice in various flavours from different senior engineers. I know why it is given, but I think it's a gross oversimplication, so let's dive deeper into it. I'm writing this to clear my thoughts about this particular piece of advice and have my thoughts available as a future reference.

Why should you never assume anything? This is pretty simple: any assumption that is wrong can carry a big risk and derail your work. The most recent example I heard was from a software engineer who made a simple mistake. He was designing a fix for a bug. He estimated that it was going to be a big project, needing lots of work. In the middle of the project a new engineer joins. The bug is fixed in a day. Huh? What went wrong? Turns out that the senior engineer thought a function named `read_from_database` did what it said, and designed their solution around that. Except the function was wrong. It was doing something else. I don't remember the details, but that's not the point. The point is that the senior engineer assumed something (functions do what they say) and they got punished for it (weeks of self-inflicted pointless work and annoying managers asking why it was so costly).

I have heard many of these cases over the years in all forms of engineering work (and also outside engineering). So comes the advice: Never assume anything! Verify everything!

This advice is well intentioned. It's a good warning sign for others. It is also utterly silly. You can't check everything! You have to make assumptions! If you check everything then you'll spend all your time in "analysis paralysis", never getting anything done. Some things can't even be verified; _I accept my mathematical axioms_. And sometimes I just accept the risk; _I don't know if the world still exist tomorrow, but I assume so for my projects_. Often assumptions are even required to start a project, they are like a hypothesis; _if we solve this problem, then our customers will pay for the solution_.

So the advice is more nuanced: check some of your assumptions! But which assumptions? In what order? That's the real advice I'm looking for. Yet this advice is never given to me.

What I've done in the past is an "assumption assessment". Like a risk assessment, but for assumptions. It's very simple, you take an hour (by yourself or together with others) and write down all assumptions you can think for your project. They can be technical or organizational or philosophical. They can be very broad or very specific. They can feel risky or safe. Anything goes.

So you'll get a list of assumptions as statements you can falsify. This is very scientific, we're just generating hypotheses based on our current world view:
* Our customers want this product
  * Why? List all reasons as assumptions.
* Customers normally do this other thing instead and they dont like it
* Our managers agree and will fund this project for the next year
* Our tech/code is used in this way
* We have these problems to solve
  * List problems
* We can fix all of these problems with this solution
  * Or list a solution per problem
* We cannot fix this other problem, just gotta accept it
* Our functions do what they say
  * List of functions you can think of
* We have no other important assumptions hiding somewhere
* ...

In the next step, you can start finding the main assumptions to verify. Or you find a way to prioritize your assumptions. This can be done for a variety of reasons:
* High risk assumptions that can derail your project.
* Assumptions you feel very uncertain about. Assumptions that are very certain (tomorrow the sun will rise) can be ignored.
* Assumptions that are outside of your influence. For example, as junior engineer you might not influence the funding of the project.
* Assumptions that take a lot of work to verify. (This is a tricky one, but if building the product is less effort than verifying the assumption, then building the product IS the way to verify the assumption.)
* ... other reasons, just write them down.
Note these are all meta-assumptions about your assumptions and can be included in your list of assumptions, but don't take it too far.

Now you can start verifying or falsifying your assumptions to make sure you build the right thing in the right way. Go for those high risk, high uncertain items first. Or you can just accept them all, but at least you are doing so conciously now.

So the advice is not "never assume anything". The advice is more like "verify assumptions like a scientist". Or maybe like an engineer. Because scientists verify assumptions for the sake of learning, while engineers verify for the sake of building. So be a professional: assess, prioritize, and verify your assumptions with intent. That's how you build with confidence.