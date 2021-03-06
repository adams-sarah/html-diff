class HtmlDiff
  attr_accessor :wd, :argv

  def initialize(argv=[])
    @wd = `pwd`.gsub("\n", "")
    @argv = argv
  end

  def stats_line
    stats=`git diff --stat #{@argv.join(" ")}`
    if stats == ""
      return "no changes"
    end
    out_stats=[]
    out_stats << stats.scan(/\d+ files? changed/).last
    out_stats << stats.scan(/\d+ insertions?\(\+\)/).last
    out_stats << stats.scan(/\d+ deletions?\(\-\)/).last
    out_stats.reject!(&:nil?)
    
    out_stats.join(", ")
  end

  def branch
    status=`git status`
    status.scan(/On branch (.*)\n/).last.last
  end

  def html_diff
    diff=`git diff #{@argv.join(" ")}`
    diff.gsub!("<", "&lt;")
    diff.gsub!(">", "&gt;")
    diff.gsub!(/^index [a-z0-9]{7}\.\.[a-z0-9]{7}$/, "")
    diff.gsub!(/^diff \-\-git a\/([^\s]*).*\n.*$/) { "<div class='diff-file'>"+$1+"</div>" }
    diff.gsub!(/^(\-\-\-\s)((?:a.*)|(?:\/dev\/null.*))$/) { "<pre class='code'><span class='delete'>"+$1+"&nbsp;"+$2+"</span>" }
    diff.gsub!(/(\n\<div class\=\'diff-file\'\>)/) { "</pre>"+$1}
    diff.gsub!(/^(\@\@.*)$/) { "<br><span class='at-linenums'>"+$1+"</span>"}

    diff.gsub!(/^(\++)(.*)$/) { "<span class='add'>"+$1+"&nbsp;"+$2+"</span>" }
    diff.gsub!(/^(\-+)(.*)$/) { "<span class='delete'>"+$1+"&nbsp;"+$2+"</span>" }
    diff
  end

  def initial_content
    '''
    <!DOCTYPE html>

    <html>
    <head>
    <title></title>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
    <style>
    body {
      font-family: "Lucida Console", Monaco, monospace;
      font-size: 13px;
      padding-bottom: 50px;
    }
    h2 {
      text-align: center;
      font-size: 1.4em;
    }
    .diff-file {
      background: -webkit-linear-gradient(#fafafa, #eaeaea);
      -ms-filter: "progid:DXImageTransform.Microsoft.gradient(startColorstr=\'#fafafa\',endColorstr=\'#eaeaea\')";
      border: 1px solid #d8d8d8;
      border-bottom: 0;
      color: #555;
      font: 14px sans-serif;
      overflow: hidden;
      padding: 12px 0px 12px 25px;
      text-shadow: 0 1px 0 white;
      width: 80%;
      margin: 50px auto 17px;
      float: none;
    }
    .code .add {
      background-color: #DDFFDD;
      padding: 2px 2% 2px 10px;
      margin-left: -25px;
      display:inline-block;
      width: 105%;
    }
    .code .delete {
      background-color: #FFDDDD;
      padding: 2px 2% 2px 10px;
      margin-left: -25px;
      display:inline-block;
      width: 105%;
    }
    .code .at-linenums {
      color: #9B9B99;
    }
    .tab {
      width: 50px;
      height: 13px;
      display: inline-block;
    }
    .code {
      border: 1px solid #cacaca;
      line-height: 1.7em;
      overflow: hidden;
      -webkit-border-radius: 0 0 3px 3px;
      -moz-border-radius: 0 0 3px 3px;
      border-radius: 0 0 3px 3px;
      -moz-background-clip: padding;
      -webkit-background-clip: padding-box;
      background-clip: padding-box;
      background-color: #FAFAFB;
      color: #393939;
      padding: 5px 0px 5px 25px;
      width: 80%;
      margin: -18px auto;
      overflow: scroll;
      float: none;
    }
    </style>
    </head>
    <body>
    '''
  end

  def content
    content = initial_content
    content += "<h2>" + branch + "<br>" + stats_line + "</h2>"
    content += html_diff+"</body></html>"
  end

  def make_diff
    File.open(@wd+"/mydiff.html", "wb+") do |f|
      f.write(content)
    end

    `open #{@wd}/mydiff.html`
    `sleep 5 && rm #{@wd}/mydiff.html`
  end
end

