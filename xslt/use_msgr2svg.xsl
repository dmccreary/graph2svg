<?xml version="1.0" encoding="windows-1250"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
	xmlns:m="http://graph2svg.googlecode.com"
	xmlns:gr="http://graph2svg.googlecode.com">
	
<xsl:include href="msgr2svg.xsl"/>

<xsl:output method="xml" encoding="utf-8"/>

<xsl:template match="gr:msgr">
	<xsl:call-template name="m:msgr2svg">
		<xsl:with-param name="graph" select="."/>
	</xsl:call-template>
</xsl:template>
</xsl:stylesheet>

