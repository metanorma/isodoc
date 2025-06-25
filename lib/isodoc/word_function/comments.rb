module IsoDoc
  module WordFunction
    module Comments
      def comments(docxml, out)
        c = docxml.xpath(ns("//fmt-annotation-body"))
        c.empty? and return
        out.div style: "mso-element:comment-list" do |div|
          @in_comment = true
          c.each { |fn| parse(fn, div) }
          @in_comment = false
        end
      end

      def comment_link_attrs(fnote, node)
        { style: "MsoCommentReference", target: fnote,
          class: "commentLink", from: node["source"],
          to: node["end"] }
      end

      def fmt_annotation_start_parse(node, out)
        make_comment_link(out, node["target"], node)
      end

      # TODO: CONSOLIDATE
      # add in from and to links to move the comment into place
      def make_comment_link(out, fnote, node)
        out.span(**comment_link_attrs(fnote, node)) do |s1|
          s1.span lang: "EN-GB", style: "font-size:9.0pt" do |s2|
            s2.a style: "mso-comment-reference:SMC_#{fnote};" \
                            "mso-comment-date:#{node['date'].gsub(/[:-]+/,
                                                                  '')}"
            s2.span style: "mso-special-character:comment", target: fnote
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

      def fmt_annotation_body_parse(node, out)
        out.div style: "mso-element:comment", id: node["id"] do |div|
          div.span style: %{mso-comment-author:"#{node['reviewer']}"}
          make_comment_target(div)
          children_parse(node, div)
        end
      end

      def comment_cleanup(docxml)
        number_comments(docxml)
        move_comment_link_to_from(docxml)
        reorder_comments_by_comment_link(docxml)
        embed_comment_in_comment_list(docxml)
      end

      def number_comments(docxml)
        map = comment_id_to_number(docxml)
        docxml.xpath("//span[@style='MsoCommentReference' or " \
        "'mso-special-character:comment']").each do |x|
          x["target"] &&= map[x["target"]]
        end
        docxml.xpath("//div[@style='mso-element:comment']").each do |x|
          x["id"] = map[x["id"]]
        end
        docxml.xpath("//a[@style]").each do |x|
          m = /mso-comment-reference:SMC_([^;]+);/.match(x["style"]) or next
          x["style"] = x["style"].sub(/mso-comment-reference:SMC_#{m[1]}/,
                                      "mso-comment-reference:SMC_#{map[m[1]]}")
        end
      end

      def comment_id_to_number(docxml)
        ids = docxml.xpath("//span[@style='MsoCommentReference']").map do |x|
          x["target"]
        end
        ids.uniq.each_with_index.with_object({}) do |(id, i), m|
          m[id] = i + 1
        end
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
        comments = docxml.xpath("//div[@style='mso-element:comment']")
          .each_with_object([]) do |c, m|
          c["id"] && !link_order[c["id"]].nil? or next
          m << { text: c.remove.to_s, id: c["id"] }
        end
        comments.sort { |a, b| link_order[a[:id]] <=> link_order[b[:id]] }
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
