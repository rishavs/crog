# TODO: Write documentation for `Crog`

require "http/client"
require "xml"


module Crog
    VERSION = "0.1.0"

    # page = Parse.new("https://medium.com/welldone-software/an-overview-of-javascript-testing-in-2018-f68950900bc3")
    # page = Parse.new("https://raw.githubusercontent.com/niallkennedy/open-graph-protocol-examples/master/article.html")

    class MetaObj
       
            property image :        String | Nil = nil
            property image_width :  Int32 | Nil = nil
            property image_height : Int32 | Nil = nil
            property url :          String | Nil = nil
            property description :  String | Nil = nil
            property title :        String | Nil = nil
            property author :       String | Nil = nil
            property date :         String | Nil = nil
            property logo :         String | Nil = nil
            property tags         = [] of String

    end

    class Parse
        def initialize(@url : String)
            res = HTTP::Client.get(url)
            mdata = MetaObj.new()

            HTTP::Client.get(url) do |res_io|
                res_io.status_code  # => 200
                document = XML.parse_html(res_io.body_io)

                mdata.image         = get_image(document)
                mdata.image_height  = document.xpath_node("//meta[@property='og:image:height']").try &.["content"].to_i
                mdata.image_width   = document.xpath_node("//meta[@property='og:image:width']").try &.["content"].to_i
                mdata.url           = get_url(document)
                mdata.description   = document.xpath_node("//meta[@property='og:description']").try &.["content"].to_s
                mdata.title         = document.xpath_node("//meta[@property='og:title']").try &.["content"].to_s
                mdata.date          = document.xpath_node("//meta[@property='og:title']").try &.["content"].to_s
                mdata.logo          = document.xpath_node("//meta[@property='og:title']").try &.["content"].to_s
                mdata.tags          = get_tags(document)
            end
        end

        def get_image(node : XML::Node)
            image = node.xpath_node("//meta[@property='og:image:secure_url']").try &.["content"].to_s || 
                node.xpath_node("//meta[@property='og:image:url']").try &.["content"].to_s || 
                node.xpath_node("//meta[@property='og:image']").try &.["content"].to_s || 
                node.xpath_node("//meta[@name='twitter:image:src']").try &.["content"].to_s || 
                node.xpath_node("//meta[@name='twitter:image']").try &.["content"].to_s
                node.xpath_node("//meta[@itemprop='image']").try &.["content"].to_s


            # wrap($ => $filter($, $('article img[src]'), getSrc)),
            # wrap($ => $filter($, $('#content img[src]'), getSrc)),
            # wrap($ => $('img[alt*="author"]').attr('src')),
            # wrap($ => $('img[src]').attr('src'))
            image
        end

        def get_url(node : XML::Node)
            murl = node.xpath_node("//meta[@property='og:url']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='twitter:url']").try &.["content"].to_s ||
                @url

            murl
            # wrap($ => $('meta[property="og:url"]').attr('content')),
            # wrap($ => $('meta[name="twitter:url"]').attr('content')),
            # wrap($ => $('link[rel="canonical"]').attr('href')),
            # wrap($ => $('link[rel="alternate"][hreflang="x-default"]').attr('href')),
        end

        def get_author(node : XML::Node)
            author = node.xpath_node("//meta[@property='og:author']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='author']").try &.["content"].to_s ||
                node.xpath_node("//meta[@property='author']").try &.["content"].to_s ||
                node.xpath_node("//meta[@property='article:author']").try &.["content"].to_s

            author
     
            # wrap($ => $filter($, $('[itemprop*="author"] [itemprop="name"]'))),
            # wrap($ => $filter($, $('[itemprop*="author"]'))),
            # wrap($ => $filter($, $('[rel="author"]'))),
            # strict(wrap($ => $filter($, $('a[class*="author"]')))),
            # strict(wrap($ => $filter($, $('[class*="author"] a')))),
            # strict(wrap($ => $filter($, $('a[href*="/author/"]')))),
            # wrap($ => $filter($, $('a[class*="screenname"]'))),
            # strict(wrap($ => $filter($, $('[class*="author"]')))),
            # strict(wrap($ => $filter($, $('[class*="byline"]'))))
        end

        def get_description(node : XML::Node)
            description = node.xpath_node("//meta[@property='og:description']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='twitter:description']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='description']").try &.["content"].to_s ||
                node.xpath_node("//meta[@itemprop='description']").try &.["content"].to_s 
            
            description

            # wrap($ => $('#description').text()),
            # wrap($ => $filter($, $('[class*="content"] > p'))),
            # wrap($ => $filter($, $('[class*="content"] p')))
        end

        def get_title(node : XML::Node)
            title = node.xpath_node("//meta[@property='og:title']").try &.["content"].to_s ||
                node.xpath_node("//meta[@property='twitter:title']").try &.["content"].to_s ||
                node.xpath_node("//title").try &.["content"].to_s

            title

            # wrap($ => $('meta[property="og:title"]').attr('content')),
            # wrap($ => $('meta[name="twitter:title"]').attr('content')),
            # wrap($ => $('.post-title').text()),
            # wrap($ => $('.entry-title').text()),
            # wrap($ => $('h1[class*="title"] a').text()),
            # wrap($ => $('h1[class*="title"]').text()),
            # wrap($ => $filter($, $('title')))
        end

        def get_logo(node : XML::Node)
            logo = node.xpath_node("//meta[@property='og:logo']").try &.["content"].to_s ||
                node.xpath_node("//meta[@itemprop='logo']").try &.["content"].to_s ||
                node.xpath_node("//img[@itemprop='logo']").try &.["src"].to_s

            logo

            # wrap($ => $('meta[property="og:logo"]').attr('content')),
            # wrap($ => $('meta[itemprop="logo"]').attr('content')),
            # wrap($ => $('img[itemprop="logo"]').attr('src')),
        end

        def get_date(node : XML::Node)
            date = node.xpath_node("//meta[@property='article:published_time']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='dc.date']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='dc.date.issued']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='dc.date.created']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='date']").try &.["content"].to_s

            date

  
            # wrap($ => $('[itemprop="datePublished"]').attr('content')),
            # wrap($ => $('time[itemprop*="pubdate"]').attr('datetime')),
            # wrap($ => $('[property*="dc:date"]').attr('content')),
            # wrap($ => $('[property*="dc:created"]').attr('content')),
            # wrap($ => $('time[datetime][pubdate]').attr('datetime')),
            # wrap($ => $('meta[property="book:release_date"]').attr('content')),
            # wrap($ => $('time[datetime]').attr('datetime')),
            # wrap($ => $('[class*="byline"]').text()),
            # wrap($ => $('[class*="dateline"]').text()),
            # wrap($ => $('[id*="date"]').text()),
            # wrap($ => $('[class*="date"]').text()),
            # wrap($ => $('[id*="publish"]').text()),
            # wrap($ => $('[class*="publish"]').text()),
            # wrap($ => $('[id*="post-timestamp"]').text()),
            # wrap($ => $('[class*="post-timestamp"]').text()),
            # wrap($ => $('[id*="post-meta"]').text()),
            # wrap($ => $('[class*="post-meta"]').text()),
            # wrap($ => $('[id*="metadata"]').text()),
            # wrap($ => $('[class*="metadata"]').text()),
            # wrap($ => $('[id*="time"]').text()),
            # wrap($ => $('[class*="time"]').text())
        end

        def get_tags(node : XML::Node)
            tags = [] of String
            node.xpath_nodes("//meta[@property='article:tag']").try &.each do |tag|
                tags << tag.try &.["content"].to_s
            
            end


            tags

        end
    end
end

# <meta property="article:published_time" content="2018-08-29" />
# <meta property="article:modified_time" content="2018-08-29" />
# <meta property="article:author" content="https://magazine.artstation.com/author/artstationteam/" />
# <meta property="article:section" content="Job Roundup" />
# <meta property="article:tag" content="Bluepoint Games" />
# <meta property="article:tag" content="Insomniac Games" />
# <meta property="article:tag" content="NetherRealm Studios" />
# <meta property="article:tag" content="Outfit7" />
# <meta property="article:tag" content="Ubisoft Annecy" />
# <meta property="article:tag" content="Ubisoft Bordeaux" />

# something for much later;
# <meta property="fb:admins" content="12331492" />
# <meta property="fb:admins" content="12301369" />
# <meta property="fb:app_id" content="127621437303857" />
# <meta property="al:android:url" content="imgur://imgur.com/gallery/xgw6J?from=fbreferral" />
# <meta property="al:android:app_name" content="Imgur" />
# <meta property="al:android:package" content="com.imgur.mobile" />
# <meta property="al:ios:url" content="imgur://imgur.com/gallery/xgw6J?from=fbreferral" />
# <meta property="al:ios:app_store_id" content="639881495" />
# <meta property="al:ios:app_name" content="Imgur" />
# <meta property="al:web:url" content="https://imgur.com/gallery/xgw6J" />