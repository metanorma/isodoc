require "relaton-cli"

module IsoDoc
  class BibdataConfig < ::Lutaml::Model::Serializable
    class Bibdata < ::Lutaml::Model::Serializable
      model ::Relaton::Bib::ItemData
    end

    attribute :bibdata, Bibdata

    xml do
      root "metanorma"
      map_element "bibdata", to: :bibdata, with: { from: :bibdata_from_xml,
                                                   to: :bibdata_to_xml }
    end

    def bibdata_from_xml(model, node)
      node or return
      model.bibdata = Relaton::Cli.parse_xml(node.adapter_node.native)
    end

    def bibdata_to_xml(model, parent, doc); end
  end

  class Metadata
    def bibdata(isoxml, _out)
      set(:bibdata, bibdata_hash(isoxml))
    end

    private

    def bibdata_hash(isoxml)
      b = isoxml.at("//bibdata") || isoxml.at("//xmlns:bibdata") or return
      key = b.to_xml
      # memoised by content, not unconditionally: after
      # docidentifier_boilerplate_isodoc resolves Liquid docidentifiers,
      # refresh_isodoc_bibdata re-runs this walker on the same Metadata
      # instance and must re-parse the changed bibdata
      @bibdata_hash_cache ||= {}
      @bibdata_hash_cache.key?(key) or
        @bibdata_hash_cache[key] = bibdata_hash_parse(key)
      @bibdata_hash_cache[key]
    end

    def bibdata_hash_parse(bibdata_xml)
      stripped = Nokogiri::XML(bibdata_xml)
      stripped.remove_namespaces!
      # Drop @boilerplate="true" docidentifiers before handing the
      # bibdata to Relaton::Cli.parse_xml: their content is an
      # unresolved Liquid template, and recent relaton-iho /
      # relaton-cc / etc. eagerly call pubid in their docidentifier
      # content= setter, which crashes on raw Liquid syntax. The
      # template variables for substitution come from other bibdata
      # fields (seriesabbr, docnumeric, …), not from the
      # docidentifier itself, so dropping it here does not affect
      # what we feed back into isodoc.meta. Substitution still runs
      # on the original xmldoc via standoc's
      # docidentifier_boilerplate_isodoc; afterwards
      # refresh_isodoc_bibdata re-runs this walker to seed
      # meta[:bibdata] with the resolved docidentifier.
      # See https://github.com/metanorma/metanorma/issues/558.
      stripped.xpath("//docidentifier[@boilerplate = 'true']").each(&:remove)
      bib = BibdataConfig.from_xml(
        "<metanorma>#{stripped.root.to_xml}</metanorma>",
      ).bibdata or return nil
      hash = YAML.safe_load(bib.to_yaml, permitted_classes: [Date, Symbol],
                                         symbolize_names: true)
      hash and fold_in_bibdata_ext(hash, stripped)
      hash
    rescue StandardError => e
      warn "Failed to parse bibdata for Liquid template use: #{e.message}"
      nil
    end

    # The Liquid `bibdata` object is built by round-tripping //bibdata through
    # the Relaton object model, which represents bibliographic-item fields but
    # not the Metanorma-document extension metadata under bibdata/ext
    # (coverpage-image, innercoverpage-image, ...). Relaton drops those, so
    # fold the raw ext subtree back in, using the same serialisation convention
    # Relaton uses: element text -> :content, attributes -> sibling keys,
    # repeated elements -> arrays, hyphens -> underscores (as in
    # schema-version -> schema_version). Relaton-modelled keys win on collision;
    # :ext is only populated when <ext> is present.
    def fold_in_bibdata_ext(hash, stripped)
      ext = stripped.at("//bibdata/ext") or return
      raw = xml_element_hash(ext)
      raw.is_a?(Hash) or return
      modelled = hash[:ext].is_a?(Hash) ? hash[:ext] : {}
      hash[:ext] = raw.merge(modelled)
    end

    # Generic Nokogiri element -> nested hash in Relaton's serialisation shape.
    def xml_element_hash(node)
      hash = {}
      node.attribute_nodes.each { |a| hash[ext_hash_key(a.node_name)] = a.value }
      children = node.element_children
      if children.empty?
        text = node.text.strip
        hash[:content] = text unless text.empty?
      else
        children.each do |c|
          add_ext_child(hash, ext_hash_key(c.node_name), xml_element_hash(c))
        end
      end
      hash
    end

    def add_ext_child(hash, key, value)
      if hash.key?(key)
        hash[key] = [hash[key]] unless hash[key].is_a?(Array)
        hash[key] << value
      else
        hash[key] = value
      end
    end

    def ext_hash_key(name)
      name.tr("-", "_").to_sym
    end
  end
end
