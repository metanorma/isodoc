module IsoDoc
  class Common
    def ul_parse(node, out)
      out.ul do |ul|
        node.children.each { |n| parse(n, ul) }
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
      type = :alphabet unless type
      OL_STYLE[type.to_sym]
    end

    # We don't really want users to specify type of ordered list;
    # we will use a fixed hierarchy as practiced by ISO (though not
    # fully spelled out): a) 1) i) A) I) 
   
    def ol_depth(node)
      depth = node.ancestors("ul, ol").size + 1
      type = :alphabet
      type = :arabic if [2, 7].include? depth
      type = :roman if [3, 8].include? depth
      type = :alphabet_upper if [4, 9].include? depth
      type = :roman_upper if [5, 10].include? depth
      ol_style(type)
    end

    def ol_parse(node, out)
      # style = ol_style(node["type"])
      style = ol_depth(node)
      out.ol **attr_code(type: style) do |ol|
        node.children.each { |n| parse(n, ol) }
      end
    end

    def li_parse(node, out)
      out.li do |li|
        node.children.each { |n| parse(n, li) }
      end
    end

    def dt_parse(dt, term)
      if dt.elements.empty?
        term.p **attr_code(class: note? ? "Note" : nil) do |p|
          p << dt.text
        end
      else
        dt.children.each { |n| parse(n, term) }
      end
    end

    def dt_dd?(n)
      %w{dt dd}.include? n.name
    end

    def dl_parse(node, out)
      out.dl do |v|
        node.elements.select { |n| dt_dd? n }.each_slice(2) do |dt, dd|
          v.dt { |term| dt_parse(dt, term) }
          v.dd do |listitem|
            dd.children.each { |n| parse(n, listitem) }
          end
        end
      end
      node.elements.reject { |n| dt_dd? n }.each { |n| parse(n, out) }
    end
  end
end
