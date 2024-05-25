<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="tei">
  <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes" indent="no"/>
  <xsl:strip-space elements="*"/>

  <xsl:variable name="language">
    <xsl:value-of select="//tei:body/@xml:lang"/>
  </xsl:variable>
  <xsl:variable name="abbrev">
    <xsl:value-of select="//tei:TEI/@n"/>
  </xsl:variable>
  <xsl:variable name="cRefPattern">
    <xsl:value-of select="//tei:cRefPattern[1]/@matchPattern"/>
  </xsl:variable>

  <!-- BODY !-->
  <xsl:template match="tei:body">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- teiHeader !-->
  <xsl:template match="tei:teiHeader"/>
  <!-- titleStmt !-->
  <xsl:template match="tei:titleStmt">
    <xsl:element name="h1">
      <xsl:attribute name="id">teiHeading</xsl:attribute>
      <xsl:element name="span">
	<xsl:attribute name="class">translit</xsl:attribute>
	<xsl:if test="tei:title[1]/@xml:lang">
	  <xsl:attribute name="lang">
	    <xsl:value-of select="tei:title[1]/@xml:lang"/>
	  </xsl:attribute>
	</xsl:if>
	<xsl:attribute name="id">worktitle</xsl:attribute>
	<xsl:apply-templates select="tei:title[1]"/>
      </xsl:element>
      <xsl:if test="tei:author">
	<xsl:element name="span">
	  <xsl:attribute name="class">translit</xsl:attribute>
	  <xsl:if test="tei:author[1]/@xml:lang">
	    <xsl:attribute name="lang">
	      <xsl:value-of select="tei:author[1]/@xml:lang"/>
	    </xsl:attribute>
	  </xsl:if>
	  <xsl:attribute name="id">authorname</xsl:attribute>
	  <xsl:apply-templates select="tei:author[1]"/>
	</xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- section divisions !-->
  <xsl:template match="tei:body/tei:div">
    <xsl:apply-templates/>
    <xsl:text>
</xsl:text>
<xsl:if test="count(following-sibling::tei:div) > 0">
  <xsl:text>
---------------------------------------------------------------------
</xsl:text>
</xsl:if>
  </xsl:template>

  <!-- paragraphs !-->
  <xsl:template match="tei:p">
    <xsl:apply-templates/>
    <xsl:text>

</xsl:text>
  </xsl:template>

  <!-- sentences !-->
  <xsl:template match="tei:s">
    <xsl:apply-templates/>
    <xsl:if test="substring(./text()[last()], string-length(.), 1) != '?'">
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- quotations of sūtras !-->
  <xsl:template match="tei:quote[@type='sūtra']">
    <xsl:text>SŪTRA </xsl:text>
    <xsl:value-of select="ancestor-or-self::tei:div[@type='adhyāya'][1][@n]"/>
    <xsl:text>.</xsl:text>
    <xsl:value-of select="ancestor-or-self::tei:div[@type='pāda'][1][@n]"/>
    <xsl:text>.</xsl:text>
    <xsl:value-of select="./@n"/>
    <xsl:text>: </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>

</xsl:text>
  </xsl:template>

  <!-- headers !-->
  <xsl:template match="tei:head[not(@type='toc')]">
    <xsl:text>[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]

</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:head[@type='toc']"/>

  <!-- trailers !-->
  <xsl:template match="tei:trailer">
    <xsl:text>
</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="tei:pb">
    <xsl:text>[page </xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:text>]
</xsl:text>
  </xsl:template>

  <xsl:template match="tei:lb">
    <xsl:if test=".[@break='no']">
      <xsl:text>-</xsl:text>
    </xsl:if>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <!-- verses !-->
  <xsl:template match="tei:lg">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:l">
    <xsl:call-template name="make-abbrev">
      <xsl:with-param name="title" select="$abbrev"/>
      <xsl:with-param name="chapter" select="./ancestor::tei:div[@n][1]/@n"/>
      <xsl:with-param name="verse" select="./ancestor::tei:lg[@n][1]/@n"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="position()=1">
	<xsl:text>ab: </xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>cd: </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
    <xsl:choose>
      <xsl:when test="not(following-sibling::tei:l)">
	<xsl:text> ||</xsl:text>
	<xsl:if test="../@met">
	  <xsl:text> [</xsl:text><xsl:value-of select="../@met"/><xsl:text>]</xsl:text>
	</xsl:if>
      </xsl:when>
    </xsl:choose>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>


  <xsl:template name="make-abbrev">
    <xsl:param name="title"/>
    <xsl:param name="chapter"/>
    <xsl:param name="verse"/>
    <xsl:value-of select="$title"/>
    <xsl:text>.</xsl:text>
    <xsl:choose>
      <xsl:when test="count(tokenize($cRefPattern,'\.')) = 3">
	<xsl:value-of select="$chapter"/>
	<xsl:text>.</xsl:text>
	<xsl:value-of select="$verse"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$verse"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
