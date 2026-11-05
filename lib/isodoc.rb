require_relative "isodoc/version"

require "nokogiri"
require "uuidtools"
require "base64"
require "image_size"
require "html2doc"
require "liquid"
require "htmlentities"
require "relaton/render"
# The render engine's batch render_all skips bibitems whose citation
# template resolves to nothing by rescuing Relaton::Render::Unrenderable
# — a marker defined by the hyphenated gem entry, which the consolidated
# "relaton/render" entry does not load. Without it the rescue itself
# raises NameError on every such bibitem (any formattedref-only
# reference). Both the standalone relaton-render gem and the
# consolidated relaton gem ship the marker under this entry.
require "relaton-render"

require "isodoc/common"
require "isodoc/convert"
require "isodoc/metadata"
require "isodoc/html_convert"
require "isodoc/word_convert"
require "isodoc/xslfo_convert"
require "isodoc/pdf_convert"
require "isodoc/headlesshtml_convert"
require "isodoc/presentation_xml_convert"
require "isodoc/xref"
require "isodoc/i18n"
require "isodoc/css_border_parser"
require "metanorma/output"
require "relaton/render-isodoc/general"

module IsoDoc
end
