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
      YAML.safe_load(bib.to_yaml, permitted_classes: [Date, Symbol],
                                  symbolize_names: true)
    rescue StandardError => e
      warn "Failed to parse bibdata for Liquid template use: #{e.message}"
      nil
    end
  end
end
