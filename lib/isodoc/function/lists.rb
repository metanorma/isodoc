module IsoDoc
  module Function
    module Lists
      def list_title_parse(node, out)
        name = node.at(ns("./fmt-name")) or return
        out.p class: "ListTitle" do |p|
          name.children&.each { |n| parse(n, p) }
        end
      end

      def ul_attrs(node)
        { id: node["id"], style: keep_style(node) }
      end

      def ul_parse(node, out)
        out.div **attr_code(class: "ul_wrap") do |div|
          list_title_parse(node, div)
          div.ul **attr_code(ul_attrs(node)) do |ul|
            node.children.each { |n| n.name == "fmt-name" or parse(n, ul) }
          end
        end
      end

      OL_STYLE = {
        arabic: "1",
        roman: "i",
        alphabet: "a",
        roman_upper: "I",
        alphabet_upper: "A",
      }.freeze

      def ol_style(type)
        type ||= :alphabet
        OL_STYLE[type.to_sym]
      end

      def ol_attrs(node)
        { # type: node["type"] ? ol_style(node["type"].to_sym) : ol_depth(node),
          type: ol_style(node["type"]&.to_sym),
          start: node["start"],
          id: node["id"], style: keep_style(node) }
      end

      def ol_parse(node, out)
        out.div **attr_code(class: "ol_wrap") do |div|
          list_title_parse(node, div)
          div.ol **attr_code(ol_attrs(node)) do |ol|
            node.children.each { |n| n.name == "fmt-name" or parse(n, ol) }
          end
        end
      end

      def li_checkbox(node)
        if node["uncheckedcheckbox"] == "true"
          '<span class="zzMoveToFollowing">' \
                '<input type="checkbox" checked="checked"/></span>'
        elsif node["checkedcheckbox"] == "true"
          '<span class="zzMoveToFollowing">' \
                '<input type="checkbox"/></span>'
        else ""
        end
      end

      def li_parse(node, out)
        out.li **attr_code(id: node["id"]) do |li|
          li << li_checkbox(node)
          node.children.each do |n|
            n.name == "fmt-name" and next
            parse(n, li)
          end
        end
      end

      def dt_parse(dterm, term)
        if dterm.elements.empty?
          term.p do |p|
            dterm.children.each { |n| parse(n, p) }
          end
        else
          dterm.children.each { |n| parse(n, term) }
        end
      end

      def dt_dd?(node)
        %w{dt dd}.include? node.name
      end

      def dl_attrs(node)
        attr_code(id: node["id"], style: keep_style(node), class: node["class"])
      end

      def dl_parse(node, out)
        out.div **attr_code(class: "figdl") do |div|
          list_title_parse(node, div)
          div.dl **dl_attrs(node) do |v|
            node.elements.select { |n| dt_dd? n }.each_slice(2) do |dt, dd|
              dl_parse1(v, dt, dd)
            end
          end
          dl_parse_notes(node, div)
        end
      end

      def dl_parse_notes(node, out)
        node.elements.reject { |n| dt_dd?(n) || n.name == "fmt-name" }
          .each { |n| parse(n, out) }
      end

      def dl_parse1(dlist, dterm, ddef)
        dlist.dt **attr_code(id: dterm["id"]) do |term|
          dt_parse(dterm, term)
        end
        dlist.dd **attr_code(id: ddef["id"]) do |listitem|
          ddef.children.each { |n| parse(n, listitem) }
        end
      end
    end
  end
end
