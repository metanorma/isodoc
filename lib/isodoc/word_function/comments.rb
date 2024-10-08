module IsoDoc
  module WordFunction
    module Comments
      def comments(div)
        return if @comments.empty?

        div.div style: "mso-element:comment-list" do |div1|
          @comments.each { |fn| div1.parent << fn }
        end
      end

      def review_note_parse(node, out)
        fn = @comments.length + 1
        make_comment_link(out, fn, node)
        @in_comment = true
        @comments << make_comment_text(node, fn)
        @in_comment = false
      end

      def comment_link_attrs(fnote, node)
        { style: "MsoCommentReference", target: fnote,
          class: "commentLink", from: node["from"],
          to: node["to"] }
      end

      # add in from and to links to move the comment into place
      def make_comment_link(out, fnote, node)
        out.span(**comment_link_attrs(fnote, node)) do |s1|
          s1.span lang: "EN-GB", style: "font-size:9.0pt" do |s2|
            s2.a style: "mso-comment-reference:SMC_#{fnote};" \
                            "mso-comment-date:#{node['date'].gsub(/[:-]+/,
                                                                  '')}"
            s2.span style: "mso-special-character:comment", target: fnote # do |s|
          end
        end
      end

      def make_comment_target(out)
        out.span style: "MsoCommentReference" do |s1|
          s1.span lang: "EN-GB", style: "font-size:9.0pt" do |s2|
            s2.span style: "mso-special-character:comment"
          end
        end
      end

      def make_comment_text(node, fnote)
        noko do |xml|
          xml.div style: "mso-element:comment", id: fnote do |div|
            div.span style: %{mso-comment-author:"#{node['reviewer']}"}
            make_comment_target(div)
            node.children.each { |n| parse(n, div) }
          end
        end.join("\n")
      end

      def comment_cleanup(docxml)
        move_comment_link_to_from(docxml)
        reorder_comments_by_comment_link(docxml)
        embed_comment_in_comment_list(docxml)
      end

      COMMENT_IN_COMMENT_LIST1 =
        '//div[@style="mso-element:comment-list"]//' \
        'span[@style="MsoCommentReference"]'.freeze

      def embed_comment_in_comment_list(docxml)
        docxml.xpath(COMMENT_IN_COMMENT_LIST1).each do |x|
          n = x.next_element
          n&.children&.first&.add_previous_sibling(x.remove)
        end
        docxml
      end

      def move_comment_link_to_from1(tolink, fromlink)
        tolink.remove
        link = tolink.at(".//a")
        fromlink.replace(tolink)
        link.children = fromlink
      end

      def comment_attributes(docxml, span)
        fromlink = docxml.at("//*[@id='#{span['from']}']")
        return(nil) if fromlink.nil?

        tolink = docxml.at("//*[@id='#{span['to']}']") || fromlink
        target = docxml.at("//*[@id='#{span['target']}']")
        { from: fromlink, to: tolink, target: target }
      end

      def wrap_comment_cont(from, target)
        if %w(ol ul li div p).include?(from.name)
          from.children.each do |c|
            wrap_comment_cont(c, target)
          end
        else
          s = from.replace("<span style='mso-comment-continuation:#{target}'>")
          s.first.children = from
        end
      end

      def skip_comment_wrap(from)
        from["style"] != "mso-special-character:comment"
      end

      def insert_comment_cont(from, upto, target)
        # includes_to = from.at(".//*[@id='#{upto}']")
        while !from.nil? && from["id"] != upto
          following = from.xpath("./following::*")
          (from = following.shift) && incl_to = from.at(".//*[@id='#{upto}']")
          while !incl_to.nil? && !from.nil? && skip_comment_wrap(from)
            (from = following.shift) && incl_to = from.at(".//*[@id='#{upto}']")
          end
          wrap_comment_cont(from, target) if !from.nil?
        end
      end

      def move_comment_link_to_from(docxml)
        docxml.xpath('//span[@style="MsoCommentReference"][@from]').each do |x|
          attrs = comment_attributes(docxml, x) || next
          move_comment_link_to_from1(x, attrs[:from])
          insert_comment_cont(attrs[:from], x["to"], x["target"])
        end
      end

      def get_comments_from_text(docxml, link_order)
        comments = []
        docxml.xpath("//div[@style='mso-element:comment']").each do |c|
          next unless c["id"] && !link_order[c["id"]].nil?

          comments << { text: c.remove.to_s, id: c["id"] }
        end
        comments.sort! { |a, b| link_order[a[:id]] <=> link_order[b[:id]] }
        # comments
      end

      COMMENT_TARGET_XREFS1 =
        "//span[@style='mso-special-character:comment']/@target".freeze

      def reorder_comments_by_comment_link(docxml)
        link_order = {}
        docxml.xpath(COMMENT_TARGET_XREFS1).each_with_index do |target, i|
          link_order[target.value] = i
        end
        comments = get_comments_from_text(docxml, link_order)
        list = docxml.at("//*[@style='mso-element:comment-list']") || return
        list.children = comments.map { |c| c[:text] }.join("\n")
      end
    end
  end
end
