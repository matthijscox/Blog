"""
make a list of blog posts for inclusion on home page
"""
function hfun_blogposts()
    post_section = "<div>\n"
    list = readdir("pages")
    for post_file in reverse(list)
      info = get_post_info(post_file)
      post_link = "<p><a href=\"/pages/$(info.pagename)/\">$(info.title)</a> $(info.date) </p>"
      post_div = "<div class=postlink>\n $post_link\n </div>\n"
      post_section *= post_div
    end
    post_section *= "</div>\n"
    return post_section
end

"""
    {{ addcomments }}

Add a comment widget, managed by utterances <https://utteranc.es>.
Set up according to https://franklinjl.org/extras/utterances/
"""
function hfun_addcomments()
    html_str = """
        <script src="https://utteranc.es/client.js"
            repo="matthijscox/Blog"
            issue-term="pathname"
            label="Comment"
            theme="github-light"
            crossorigin="anonymous"
            async>
        </script>
    """
    return html_str
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

struct PostInfo
  title::String
  pagename::String
  date::String
end

function get_post_info(post_file)
  file_path = joinpath("pages", post_file)
  title = open(file_path) do f
      r = read(f, String)
      m = match(r"@def title = \"(.*?)\"", r)
      return string(first(m.captures))
  end
  #@info " .... processing page $title"
  pagename = first(splitext(post_file))
  postdate = pagename[1:10]
  return PostInfo(title, pagename, postdate)
end