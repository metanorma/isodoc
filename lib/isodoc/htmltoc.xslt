<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="html">
        <ul>
            <xsl:apply-templates mode="indice" select="//h1">
            <xsl:sort/>
            </xsl:apply-templates>
        </ul>
</xsl:template>


<xsl:template mode="indice" match="h1">
    <li>
            <xsl:value-of select="text()"/>
    </li>

    <ol>
        <xsl:for-each select="section">
            <li>
                <a href="#{@id}">
                    <xsl:value-of select="title"/>
                </a>
                <ol>
                <xsl:for-each select="subsection">
                        <li>
                            <a href="#{@id}">
                                <xsl:value-of select="title"/>
                            </a>
                            <ol>
                                <xsl:for-each select="subsubsection">
                                    <li>
                                        <a href="#{@id}">
                                            <xsl:value-of select="title"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ol>
                        </li>
                </xsl:for-each>
                </ol>
            </li>
        </xsl:for-each>
    </ol>
</xsl:template>
</xsl:stylesheet>
