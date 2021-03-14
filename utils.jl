"""
make a list of blog posts for inclusion on home page
"""
function hfun_blogposts()
    list = readdir("pages")
    post_file = list[1]
    title = open(joinpath("pages", post_file)) do f
        r = read(f, String)
        m = match(r"@def title = \"(.*?)\"", r)
        return string(first(m.captures))
    end
    #@info " .... processing page $title"
    pagename = first(splitext(post_file))
    postdate = pagename[1:10]
    post_url = "<p><a href=\"/pages/$(pagename)/\">$(title)</a> $(postdate) </p>"
    return "<div>\n $post_url\n </div>\n\n"
end

function hfun_bar(vname)
  val = Meta.parse(vname[1])
  return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end

function lx_baz(com, _)
  # keep this first line
  brace_content = Franklin.content(com.braces[1]) # input string
  # do whatever you want here
  return uppercase(brace_content)
end
