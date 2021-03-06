<xsl:stylesheet xmlns:math="http://exslt.org/math" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://graph2svg.googlecode.com" xmlns:gr="http://graph2svg.googlecode.com" extension-element-prefixes="math" exclude-result-prefixes="m math xs gr" version="2.0">
    <d:doc xmlns:d="http://www.dpawson.co.uk/ns#">
        <d:revhistory>
            <d:purpose>
                <d:para>This stylesheet works with XML file to produce SVG</d:para>
            </d:purpose>
            <d:revision>
                <d:revnumber>1.0</d:revnumber>
                <d:date>2009-07-23T11:06:13Z</d:date>
                <d:authorinitials>DaveP</d:authorinitials>
                <d:revdescription>
                    <d:para>Replaced 'botom' with 'bottom'</d:para>
                </d:revdescription>
                <d:revremark/>
            </d:revision>
            <d:revision>
                <d:revnumber>1.0</d:revnumber>
                <d:date>2010-01-31T15:12:33Z</d:date>
                <d:authorinitials>Jakub</d:authorinitials>
                <d:revdescription>
                    <d:para>Added dateTime option to xAxisn</d:para>
                    <d:para>Converted all comments to English</d:para>
                </d:revdescription>
                <d:revremark/>
            </d:revision>
        </d:revhistory>
    </d:doc>
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    <!--doctype-public="-//W3C//DTD SVG 1.1//EN"
"doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"-->
    <xsl:template match="gr:xygr">
        <xsl:call-template name="m:xygr2svg">
            <xsl:with-param name="graph" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="m:xygr2svg">
        <xsl:param name="graph"/>
        <xsl:variable name="gra">
            <ph>
                <xsl:apply-templates select="$graph/@*" mode="m:processValues"/>
                <xsl:attribute name="legend" select="    if (($graph/@legend) = 'right') then 'right' else    if (($graph/@legend) = 'left') then 'left' else    if (($graph/@legend) = 'top') then 'top' else    if (($graph/@legend) = 'bottom') then 'bottom' else 'none' "/>
                <xsl:apply-templates select="$graph/(*|text())" mode="m:processValues">
                    <xsl:with-param name="graph" select="$graph" tunnel="yes"/>
                </xsl:apply-templates>
            </ph>
        </xsl:variable>
        <!--xsl:copy-of select="$gra/ph"/-->

        <!-- constants -->
        <xsl:variable name="titleMargin" select="10"/>
        <xsl:variable name="titleFontSize" select="18"/>
        <xsl:variable name="labelFontSize" select="10"/>
        <xsl:variable name="labelFontWd" select="0.68"/>
        <!-- average length of letter divided a font high -->
        <xsl:variable name="curveFontSize" select="10"/>
        <xsl:variable name="graphMargin" select="15"/>
        <xsl:variable name="xAxisMarkDist" select="80"/>
        <xsl:variable name="yAxisMarkDist" select="25"/>
        <xsl:variable name="xAxisMarkAutoCount" select="5"/>
        <xsl:variable name="yAxisMarkAutoCount" select="11"/>
        <!-- automatic choice will try to be close to this values -->
        <xsl:variable name="axesAutoCoef" select="0.8"/>
        <!-- coeficient used for decision wheather display 0 whe automatically choosing axes range -->
        <xsl:variable name="axesStroke-width" select="1"/>
        <xsl:variable name="legendMargin" select="15"/>
        <xsl:variable name="legendPictureWd" select="28"/>
        <xsl:variable name="legendGap" select="5"/>
        <xsl:variable name="legendFontSize" select="10"/>
        <xsl:variable name="legendFontWd" select="0.61"/>
        <xsl:variable name="legendSpacing" select="16"/>
        <!-- high of a row in legend-->
        <xsl:variable name="majorMarkLen" select="3"/>
        <!-- 1/2 of the length of major marks on axes -->
        <xsl:variable name="majorMarkStroke-width" select="1"/>
        <xsl:variable name="minorMarkLen" select="2"/>
        <!-- 1/2 of the length of minor marks on axes-->
        <xsl:variable name="minorMarkStroke-width" select="0.5"/>
        <xsl:variable name="majorGridStroke-width" select="0.4"/>
        <xsl:variable name="majorGridColor" select=" '#222' "/>
        <xsl:variable name="minorGridStroke-width" select="0.2"/>
        <xsl:variable name="minorGridColor" select=" '#111' "/>

        <!-- color schemas definitions -->
        <xsl:variable name="colorSchemeColor" select="('#14f', '#ff1', '#f0d', '#3f1', '#f33', '#1ff', '#bbb', '#13b', '#909', '#a81', '#090', '#b01', '#555')"/>
        <xsl:variable name="colorSchemeCold" select="('#07bbbb', '#09a317', '#19009f', '#9a0084', '#6efaff', '#88f917', '#a9a7f6', '#fbbbf3', '#002dff', '#ff00bf')"/>
        <xsl:variable name="colorSchemeWarm" select="('#d82914', '#f2ee15', '#21ab03', '#c5a712', '#a4005a', '#f17a2e', '#c9f581', '#ffbcc5', '#ffffc4', '#f8887f')"/>
        <xsl:variable name="colorSchemeGrey" select="('#ccc', '#888', '#444', '#eee', '#aaa', '#666', '#222')"/>
        <xsl:variable name="colorSchemeBlack" select="('black')"/>

        <!-- variable calculations-->
        <!-- X axis -->
        <xsl:variable name="dataMaxX" select="max($gra/ph/curve/point/@x)"/>
        <xsl:variable name="dataMinX" select="min($gra/ph/curve/point/@x)"/>
        <xsl:variable name="dataXDif" select="$dataMaxX - $dataMinX"/>
        <xsl:variable name="viewMaxX" select="    if ($gra/ph/@xAxisType = 'shifted') then $dataMaxX else     (if ($gra/ph/@xAxisType = 'withZero') then max(($dataMaxX, 0)) else     (if ((- $dataXDif * $axesAutoCoef &lt; $dataMaxX) and ($dataMaxX &lt; 0)) then 0 else $dataMaxX))"/>
        <xsl:variable name="viewMinX" select="    if ($gra/ph/@xAxisType = 'shifted') then $dataMinX else     (if ($gra/ph/@xAxisType = 'withZero') then max(($dataMinX, 0)) else     (if ((0 &lt; $dataMinX) and  ($dataMinX &lt; $dataXDif * $axesAutoCoef)) then 0 else $dataMinX))"/>
        <xsl:variable name="xAxisStep" select="m:Step($viewMaxX - $viewMinX, $xAxisMarkAutoCount, $gra/ph/@xAxisType)"/>
        <xsl:variable name="xAxisMax" select="m:GMax($viewMaxX, $xAxisStep)"/>
        <xsl:variable name="xAxisMin" select="- m:GMax(- $viewMinX, $xAxisStep)"/>
        <xsl:variable name="xAxisLen" select="$xAxisMax - $xAxisMin"/>
        <xsl:variable name="xAxisMarkCount" as="xs:integer" select="round($xAxisLen div $xAxisStep) cast as xs:integer"/>
        <!--round($xAxisLen div $xAxisStep)"/-->
        <xsl:variable name="xAxisWd" select="$xAxisMarkCount * $xAxisMarkDist"/>
        <xsl:variable name="xKoef" select="$xAxisWd div $xAxisLen"/>
        <xsl:variable name="originXShift" select="    if ($gra/ph/@axesPos = 'left-bottom') then 0 else    if ($xAxisMin &gt;= 0) then 0 else min((- $xAxisMin, $xAxisLen)) * $xKoef "/>
        <xsl:variable name="maxXLabelWd" select="$labelFontSize * $labelFontWd *    max(for $a in (0 to $xAxisMarkCount) return      string-length(string(m:Round($xAxisMin + $a * $xAxisStep, $xAxisStep)))     + (if ($gra/ph/@xAxisType='log') then 2 else 0)  )"/>

        <!-- Y axis -->
        <xsl:variable name="dataMaxY" select="max($gra/ph/curve/point/@y)"/>
        <xsl:variable name="dataMinY" select="min($gra/ph/curve/point/@y)"/>
        <xsl:variable name="dataYDif" select="$dataMaxY - $dataMinY"/>
        <xsl:variable name="viewMaxY" select="    if ($gra/ph/@yAxisType = 'shifted') then $dataMaxY else     (if ($gra/ph/@yAxisType = 'withZero') then max(($dataMaxY, 0)) else     (if ((- $dataYDif * $axesAutoCoef &lt; $dataMaxY) and ($dataMaxY &lt; 0)) then 0 else $dataMaxY))"/>
        <xsl:variable name="viewMinY" select="    if ($gra/ph/@yAxisType = 'shifted') then $dataMinY else     (if ($gra/ph/@yAxisType = 'withZero') then max(($dataMinY, 0)) else     (if ((0 &lt; $dataMinY) and  ($dataMinY &lt; $dataYDif * $axesAutoCoef)) then 0 else $dataMinY))"/>
        <xsl:variable name="yAxisStep" select="m:Step($viewMaxY - $viewMinY, $yAxisMarkAutoCount, $gra/ph/@yAxisType)"/>
        <xsl:variable name="yAxisMax" select="m:GMax($viewMaxY, $yAxisStep)"/>
        <xsl:variable name="yAxisMin" select="- m:GMax(- $viewMinY, $yAxisStep)"/>
        <xsl:variable name="yAxisLen" select="$yAxisMax - $yAxisMin"/>
        <xsl:variable name="yAxisMarkCount" select="round($yAxisLen div $yAxisStep) cast as xs:integer"/>
        <xsl:variable name="yAxisHg" select="$yAxisMarkCount * $yAxisMarkDist"/>
        <xsl:variable name="yKoef" select="- $yAxisHg div $yAxisLen"/>
        <xsl:variable name="originYShift" select="    if ($gra/ph/@axesPos = 'left-bottom') then 0 else    if ($yAxisMin &gt;= 0) then 0 else - min((- $yAxisMin, $yAxisLen)) * $yKoef "/>
        <xsl:variable name="maxYLabelWd" select="$labelFontSize * $labelFontWd *    max(for $a in (0 to $yAxisMarkCount) return      string-length(string(m:Round($yAxisMin + $a * $yAxisStep, $yAxisStep)))     + (if ($gra/ph/@yAxisType='log') then 2 else 0)  )"/>

        <!-- title and legend -->
        <xsl:variable name="titleHg" select="if ($gra/ph/title) then 2*$titleMargin + $titleFontSize else 0"/>
        <xsl:variable name="legendWd" select="    if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then (     $legendMargin + $legendPictureWd + $legendGap  +     $legendFontSize * $legendFontWd *      max(((for $a in ($gra/ph/curve[not (name/@visibility='none' or name/@visibility='graph')]) return string-length($a/name)), 9))    ) else     if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then (     2*$legendMargin + sum(      for $a in ($gra/ph/curve[not (name/@visibility='none' or name/@visibility='graph')]) return        ((if ($a/name) then string-length($a/name) else 9) *         $legendFontSize * $legendFontWd + $legendPictureWd + $legendGap + $legendMargin)      )    ) else 0       "/>
        <xsl:variable name="legendHg" select="    if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then (     $legendSpacing -$legendFontSize +2*$legendMargin +$legendSpacing *      count($gra/ph/curve[name/@visibility='both' or name/@visibility='legend'])    ) else     if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then (     $legendMargin + $legendFontSize    ) else 0"/>
        <xsl:variable name="legendL" select="if ($gra/ph/@legend = 'left') then $legendWd else 0"/>
        <xsl:variable name="legendR" select="if ($gra/ph/@legend = 'right') then $legendWd else 0"/>
        <xsl:variable name="legendT" select="if ($gra/ph/@legend = 'top') then $legendHg else 0"/>
        <xsl:variable name="legendB" select="if ($gra/ph/@legend = 'bottom') then $legendHg else 0"/>

        <!-- the graph itselves -->
        <xsl:variable name="yAxisTSpace" select="$graphMargin + $labelFontSize div 2"/>
        <xsl:variable name="yAxisBSpace" select="$graphMargin +     max(($labelFontSize div 2, $labelFontSize + $majorMarkLen - $originYShift))"/>
        <xsl:variable name="xAxisLSpace" select="$graphMargin +     max((0, $maxYLabelWd - $originXShift, $maxXLabelWd div 2))"/>
        <xsl:variable name="xAxisRSpace" select="$graphMargin + ($maxXLabelWd div 2)"/>
        <xsl:variable name="graphWd" select="$xAxisLSpace + $xAxisWd + $xAxisRSpace"/>
        <xsl:variable name="graphHg" select="$yAxisTSpace + $yAxisHg + $yAxisBSpace"/>
        <xsl:variable name="xAxisLStart" select="$legendL + $xAxisLSpace +     (if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then      max(($legendWd - $graphWd, 0)) div 2     else 0)"/>
        <xsl:variable name="yAxisTStart" select="$titleHg + $legendT + $yAxisTSpace +     (if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then      max(($legendHg - $graphHg, 0)) div 2     else 0)"/>
        <xsl:variable name="originX" select="$xAxisLStart + $originXShift"/>
        <xsl:variable name="originY" select="$yAxisTStart + $yAxisHg - $originYShift"/>
        <xsl:variable name="xShift" select="$xAxisLStart - $xKoef * $xAxisMin"/>
        <xsl:variable name="yShift" select="$yAxisTStart + $yAxisHg - $yKoef * $yAxisMin"/>
        <xsl:variable name="legendX" select="(if ($gra/ph/@legend = 'right') then $graphWd else $legendMargin) +     (if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then      max(($graphWd - $legendWd, 0)) div 2    else 0)"/>
        <xsl:variable name="legendY" select="$titleHg +     (if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then      max(($graphHg - $legendHg, 0)) div 2 + $legendMargin      else (if ($gra/ph/@legend = 'bottom') then $graphHg else $legendMargin ))    "/>

        <!-- whole window -->
        <xsl:variable name="width" select="$legendL + $legendR +     (if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then max(($graphWd, $legendWd)) else $graphWd)"/>
        <xsl:variable name="height" select="$titleHg +  $legendT + $legendB +     (if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then max(($graphHg, $legendHg)) else $graphHg)"/>
        <!-- selected color schema -->
        <xsl:variable name="colorSch" select="    if ($gra/ph/@colorScheme = 'color') then $colorSchemeColor else    if ($gra/ph/@colorScheme = 'cold') then $colorSchemeCold else    if ($gra/ph/@colorScheme = 'warm') then $colorSchemeWarm else    if ($gra/ph/@colorScheme = 'grey') then $colorSchemeGrey else  $colorSchemeBlack "/>

        <!-- start of SVG document -->
        <svg:svg viewBox="0 0 {$width} {$height}">
            <svg:desc>
                <xsl:value-of select="$gra/ph/title"/>
            </svg:desc>

            <!-- type the graph title -->
            <svg:g>
                <xsl:if test="count($gra/ph/title) &gt; 0">
                    <svg:text x="{m:R($width div 2)}" y="{$titleMargin + $titleFontSize}" text-anchor="middle" font-family="Verdana" font-size="{$titleFontSize}" fill="{if ($gra/ph/title/@color) then $gra/ph/title/@color else 'black'}">
                        <xsl:value-of select="$gra/ph/title"/>
                    </svg:text>
                </xsl:if>
            </svg:g>

            <!-- variables for axis and grids -->
            <xsl:variable name="LB" select="$gra/ph/@axesPos = 'left-bottom'"/>
            <xsl:variable name="mXpom" select="        if ($LB) then      (0 to $xAxisMarkCount)    else      if ($xAxisMin &gt; 0) then (1 to $xAxisMarkCount) else     if ($xAxisMax &lt; 0) then (0 to $xAxisMarkCount - 1) else       (0 to $xAxisMarkCount)   "/>
            <xsl:variable name="mYpom" select="        if ($LB) then      (0 to $yAxisMarkCount)    else      if ($yAxisMin &gt; 0) then (1 to $yAxisMarkCount) else     if ($yAxisMax &lt; 0) then (0 to $yAxisMarkCount - 1) else       (0 to $yAxisMarkCount)   "/>
            <xsl:variable name="logDiv" select="0.301, 0.176, 0.125, 0.097, 0.079, 0.067, 0.058, 0.051, 0.046"/>
            <!-- log10(i) - log10(i-1)   for  i=2,3,..,10 -->
            <xsl:variable name="xAxisDiv" select="    if ($gra/ph/@xAxisDivision = 'none') then -1 else    if ($gra/ph/@xAxisDivision = '1') then 1 else    if ($gra/ph/@xAxisDivision = '2') then 2 else    if ($gra/ph/@xAxisDivision = '4') then 4 else    if ($gra/ph/@xAxisDivision = '5') then 5 else    if ($gra/ph/@xAxisDivision = '10') then 10 else 1  "/>
            <xsl:variable name="yAxisDiv" select="    if ($gra/ph/@yAxisDivision = 'none') then -1 else    if ($gra/ph/@yAxisDivision = '1') then 1 else    if ($gra/ph/@yAxisDivision = '2') then 2 else    if ($gra/ph/@yAxisDivision = '4') then 4 else    if ($gra/ph/@yAxisDivision = '5') then 5 else    if ($gra/ph/@yAxisDivision = '10') then 10 else 1    "/>


            <!-- major and minor grid for both axes -->
            <xsl:if test="($gra/ph/@xGrid = 'minor') and ($xAxisDiv &gt; 1)">
                <!-- minor grid of X axis -->
                <xsl:variable name="gXMinor" select="    concat('M', $xAxisLStart + $mXpom[1] * $xAxisMarkDist, ',', $yAxisTStart, ' l0,', $yAxisHg),    if ($gra/ph/@xAxisType='log') then (     for $a in $mXpom[. != 1], $b in $logDiv return       concat('m', $xAxisMarkDist *$b, ',-', $yAxisHg, ' l0,', $yAxisHg)    ) else (     for $n in (for $a in (1 to $xAxisDiv) return $mXpom[. != 1]) return       concat('m', $xAxisMarkDist div $xAxisDiv, ',-', $yAxisHg, ' l0,', $yAxisHg)    )"/>
                <svg:path d="{$gXMinor}" stroke="{$minorGridColor}" stroke-width="{$minorGridStroke-width}"/>
            </xsl:if>
            <xsl:if test="($gra/ph/@yGrid = 'minor') and ($yAxisDiv &gt; 1) ">
                <!-- minor grid of Y axis -->
                <xsl:variable name="gYMinor" select="    concat('M', $xAxisLStart, ',', $yAxisTStart+$yAxisHg - $mYpom[1]*$yAxisMarkDist, ' l', $xAxisWd, ',0 '),    if ($gra/ph/@yAxisType='log') then (     for $a in $mYpom[. != 1], $b in $logDiv return       concat('m-', $xAxisWd, ',-', $yAxisMarkDist * $b, ' l', $xAxisWd, ',0 ')    ) else (     for $n in (for $a in (1 to $yAxisDiv) return $mYpom[. != 1]) return       concat('m-', $xAxisWd, ',-', $yAxisMarkDist div $yAxisDiv, ' l', $xAxisWd, ',0 ')    )"/>
                <svg:path d="{$gYMinor}" stroke="{$minorGridColor}" stroke-width="{$minorGridStroke-width}"/>
            </xsl:if>
            <xsl:if test="($gra/ph/@xGrid = 'major' or $gra/ph/@xGrid = 'minor')      and ($xAxisDiv &gt; 0)">
                <!-- major grid of X axis -->
                <xsl:variable name="gXMajor" select="      concat('M', $xAxisLStart + $mXpom[1] * $xAxisMarkDist, ',', $yAxisTStart, ' l0,', $yAxisHg),     for $n in $mXpom[. != 1] return       concat('m', $xAxisMarkDist, ',-', $yAxisHg, ' l0,', $yAxisHg)"/>
                <svg:path d="{$gXMajor}" stroke="{$majorGridColor}" stroke-width="{$majorGridStroke-width}"/>
            </xsl:if>
            <xsl:if test="($gra/ph/@yGrid = 'major' or $gra/ph/@yGrid = 'minor')     and ($yAxisDiv &gt; 0) ">
                <!-- major grid of Y axis -->
                <xsl:variable name="gYMajor" select="     concat('M', $xAxisLStart, ',', $yAxisTStart + $yAxisHg - $mYpom[1] * $yAxisMarkDist,      ' l', $xAxisWd, ',0 '),     for $n in $mYpom[. != 1] return       concat('m-', $xAxisWd, ',-', $yAxisMarkDist, ' l', $xAxisWd, ',0 ')"/>
                <svg:path d="{$gYMajor}" stroke="{$majorGridColor}" stroke-width="{$majorGridStroke-width}"/>
            </xsl:if>

            <!-- major and minor marks for both axes -->
            <svg:g stroke="black">
                <xsl:if test="($xAxisDiv &gt; 1)">
                    <!-- minor marks for X axis -->
                    <xsl:variable name="mXMinor" select="    concat('M', m:R($xAxisLStart +$mXpom[1]*$xAxisMarkDist), ',', m:R($originY -$minorMarkLen), ' l0,', m:R(2*$minorMarkLen)),    if ($gra/ph/@xAxisType='log') then (     for $a in $mXpom[. != 1], $b in $logDiv return       concat('m', m:R($xAxisMarkDist *$b), ',-', m:R(2*$minorMarkLen), ' l0,', m:R(2*$minorMarkLen))    ) else (     for $n in (for $a in (1 to $xAxisDiv) return $mXpom[. != 1]) return       concat('m', m:R($xAxisMarkDist div $xAxisDiv), ',-', m:R(2 * $minorMarkLen), ' l0,', m:R(2 * $minorMarkLen))    )"/>
                    <svg:path d="{$mXMinor}" stroke-width="{$minorMarkStroke-width}"/>
                </xsl:if>
                <xsl:if test="($yAxisDiv &gt; 1)">
                    <!-- minor marks for Y axis -->
                    <xsl:variable name="mYMinor" select="    concat('M', m:R($originX -$minorMarkLen), ',', m:R($yAxisTStart +$yAxisHg -$mYpom[1]*$yAxisMarkDist),       ' l', m:R(2*$minorMarkLen), ',0 '),     if ($gra/ph/@yAxisType='log') then (     for $a in $mYpom[. != 1], $b in $logDiv return       concat('m-', m:R(2*$minorMarkLen), ',-', m:R($yAxisMarkDist*$b), ' l', m:R(2*$minorMarkLen), ',0 ')    ) else (     for $n in (for $a in (1 to $yAxisDiv) return $mYpom[. != 1]) return       concat('m-', m:R(2*$minorMarkLen), ',-', m:R($yAxisMarkDist div $yAxisDiv), ' l', m:R(2*$minorMarkLen), ',0 ')    )"/>
                    <svg:path d="{$mYMinor}" stroke-width="{$minorMarkStroke-width}"/>
                </xsl:if>
                <xsl:if test="($xAxisDiv &gt; 0)">
                    <!-- major marks for X axis -->
                    <xsl:variable name="mXMajor" select="      concat('M', m:R($xAxisLStart + $mXpom[1] * $xAxisMarkDist), ',', m:R($originY - $majorMarkLen), ' l0,', m:R(2 * $majorMarkLen)),     for $n in $mXpom[(.) != 1] return concat('m', m:R($xAxisMarkDist), ',-', m:R(2 * $majorMarkLen), ' l0,', m:R(2 * $majorMarkLen))"/>
                    <svg:path d="{$mXMajor}" stroke-width="{$majorMarkStroke-width}"/>
                </xsl:if>
                <xsl:if test="($yAxisDiv &gt; 0)">
                    <!-- major marks for Y axis -->
                    <xsl:variable name="mYMajor" select="      concat('M', m:R($originX - $majorMarkLen), ',', m:R($yAxisTStart + $yAxisHg - $mYpom[1] * $yAxisMarkDist),      ' l', m:R(2 * $majorMarkLen), ',0 '),     for $n in $mYpom[(.) != 1] return concat('m-', m:R(2 * $majorMarkLen), ',-', m:R($yAxisMarkDist), ' l', m:R(2 * $majorMarkLen), ',0 ')"/>
                    <svg:path d="{$mYMajor}" stroke-width="{$majorMarkStroke-width}"/>
                </xsl:if>
            </svg:g>

            <!-- X axis with labels -->
            <svg:g stroke="black" stroke-width="{$axesStroke-width}">
                <xsl:if test="$mXpom[1] != 0">
                    <svg:line stroke-dasharray="2,3" x1="{$xAxisLStart}" y1="{$originY}" x2="{$xAxisLStart + $xAxisMarkDist}" y2="{$originY}"/>
                </xsl:if>
                <svg:line x1="{$xAxisLStart + $mXpom[1] * $xAxisMarkDist}" y1="{$originY}" x2="{$xAxisLStart + $mXpom[last()]*$xAxisMarkDist}" y2="{$originY}"/>
                <xsl:if test="$mXpom[last()] != $xAxisMarkCount">
                    <svg:line stroke-dasharray="2,3" x1="{$xAxisLStart + $xAxisWd - $xAxisMarkDist}" y1="{$originY}" x2="{$xAxisLStart + $xAxisWd}" y2="{$originY}"/>
                </xsl:if>
            </svg:g>
            <!-- X axis labels -->
            <xsl:if test="($xAxisDiv &gt; 0)">
                <xsl:variable name="tpX" select="if ($yAxisMin &gt;= 0) then $mXpom else     for $a in $mXpom return if (not($LB) and (($xAxisMin + $a * $xAxisStep) = 0)) then -1 else $a"/>
                <svg:g text-anchor="middle" font-family="Verdana" font-size="{$labelFontSize}" fill="black">
                    <xsl:for-each select="(for $a in ($tpX[. &gt; -1]) return $xAxisMin + $a * $xAxisStep)">
                        <svg:text x="{m:R($xShift + $xKoef * (.))}" y="{m:R($originY + $majorMarkLen + $labelFontSize)}">
                            <xsl:value-of select="m:Round(., $xAxisStep, $gra/ph/@xAxisType)"/>
                            <xsl:if test="$gra/ph/@xAxisType='log'">
                                <svg:tspan font-size="{0.75*$labelFontSize}" dy="{-0.4*$labelFontSize}">
                                    <xsl:value-of select="."/>
                                </svg:tspan>
                            </xsl:if>
                        </svg:text>
                    </xsl:for-each>
                </svg:g>
            </xsl:if>
            <!-- if axes are crossing in origin we have to draw 0 separatelly -->
            <xsl:if test="($xAxisDiv &gt; 0) or ($yAxisDiv &gt; 0)">
                <xsl:if test="not($LB) and ($xAxisMin &lt; 0) and ($xAxisMax &gt;= 0) and          ($yAxisMin &lt; 0) and ($yAxisMax &gt;= 0)">
                    <svg:text text-anchor="end" font-family="Verdana" font-size="{$labelFontSize}" x="{m:R($originX - 3)}" y="{m:R($originY + $majorMarkLen + $labelFontSize)}">
                        <xsl:value-of select="0"/>
                    </svg:text>
                </xsl:if>
            </xsl:if>

            <!-- Y axis with labels -->
            <svg:g stroke="black" stroke-width="{$axesStroke-width}">
                <xsl:if test="$mYpom[1] != 0">
                    <svg:line stroke-dasharray="2,3" x1="{$originX}" y1="{$yAxisTStart + $yAxisHg - $yAxisMarkDist}" x2="{$originX}" y2="{$yAxisTStart + $yAxisHg}"/>
                    <!--svg:line x1="{$originX}" y1="{$yAxisTStart}" 
				x2="{$originX}" y2="{$yAxisTStart + $yAxisHg - $yAxisMarkDist}"/-->
                </xsl:if>
                <svg:line x1="{$originX}" y1="{$yAxisTStart + $yAxisHg - $mYpom[1] * $yAxisMarkDist}" x2="{$originX}" y2="{$yAxisTStart + $yAxisHg - $mYpom[last()]*$yAxisMarkDist}"/>
                <xsl:if test="$mYpom[last()] != $yAxisMarkCount">
                    <svg:line stroke-dasharray="2,3" x1="{$originX}" y1="{$yAxisTStart}" x2="{$originX}" y2="{$yAxisTStart + $yAxisMarkDist}"/>
                    <!--svg:line x1="{$originX}" y1="{$yAxisTStart}" 
				x2="{$originX}" y2="{$yAxisTStart + $yAxisHg}"/-->
                </xsl:if>
            </svg:g>
            <!-- Y axis labels -->
            <xsl:if test="($yAxisDiv &gt; 0)">
                <xsl:variable name="tpY" select="if ($xAxisMin &gt;= 0) then $mYpom else     for $a in $mYpom return if (not($LB) and ($yAxisMin + $a * $yAxisStep) = 0) then -1 else $a"/>
                <svg:g text-anchor="end" font-family="Verdana" font-size="{$labelFontSize}" fill="black">
                    <xsl:for-each select="(for $a in ($tpY[. &gt; -1]) return $yAxisMin + $a * $yAxisStep)">
                        <svg:text x="{m:R($originX - $majorMarkLen - 3)}" y="{m:R($yShift + $yKoef * (.) + 0.35 * $labelFontSize)}">
                            <xsl:value-of select="m:Round(., $yAxisStep, $gra/ph/@yAxisType)"/>
                            <xsl:if test="$gra/ph/@yAxisType='log'">
                                <svg:tspan font-size="{0.75*$labelFontSize}" dy="{-0.4*$labelFontSize}">
                                    <xsl:value-of select="."/>
                                </svg:tspan>
                            </xsl:if>
                        </svg:text>
                    </xsl:for-each>
                </svg:g>
            </xsl:if>

            <!-- legend -->
            <xsl:if test="($gra/ph/@legend != 'none')">
                <svg:g text-anchor="start" font-family="Verdana" font-size="{$legendFontSize}" fill="black">
                    <xsl:for-each select="$gra/ph/curve[(name) and not (name/@visibility='none' or name/@visibility='graph')]">
                        <xsl:variable name="nn" select="count(preceding-sibling::curve[(name) and not (name/@visibility='none' or name/@visibility='graph')])"/>
                        <xsl:variable name="cn" select="count(preceding-sibling::curve) mod count($colorSch)+1"/>
                        <xsl:variable name="cc" select="      if (name/@color) then (name/@color) else       if (@color) then (@color) else $colorSch[$cn]"/>
                        <xsl:if test="($gra/ph/@legend = 'right') or ($gra/ph/@legend = 'left')">
                            <svg:text x="{$legendX + $legendPictureWd + $legendGap}" y="{$legendY + $legendSpacing * ($nn + 1)}" fill="{$cc}">
                                <xsl:value-of select="if (./name) then (./name) else ('series', $nn +1)"/>
                            </svg:text>
                        </xsl:if>
                        <xsl:if test="($gra/ph/@legend = 'top') or ($gra/ph/@legend = 'bottom')">
                            <svg:text x="{$legendX + $legendPictureWd + $legendGap +       sum( for $a in (preceding-sibling::curve[name/@visibility='both' or name/@visibility='legend']) return        ((if ($a/name) then string-length($a/name) else 9) *         $legendFontSize * $legendFontWd + $legendPictureWd + $legendGap + $legendMargin)  ) }" y="{$legendY+ $legendFontSize}" fill="{$cc}">
                                <xsl:value-of select="if (./name) then (./name) else ('series', $nn +1)"/>
                            </svg:text>
                        </xsl:if>
                    </xsl:for-each>
                </svg:g>
            </xsl:if>

            <!-- drawing of curves -->
            <xsl:if test="not ($gra/ph/@lineType) or (some $a in ($gra/ph/curve/@lineType, $gra/ph/@lineType) satisfies $a != 'none')">
                <svg:g stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round">
                    <xsl:if test="$gra/ph/@lineType != 'solid'">
                        <xsl:attribute name="stroke-dasharray" select="m:LineType($gra/ph/@lineType)"/>
                    </xsl:if>
                    <xsl:for-each select="$gra/ph/curve[not (./@lineType = 'none') and      ((./@lineType) or not ($gra/ph/@lineType = 'none'))]">
                        <!-- do until the lineT is not none or until we didn't inheritied from graph -->
                        <xsl:variable name="nn" select="count(preceding-sibling::curve[name/@visibility='both' or name/@visibility='legend'])"/>
                        <xsl:variable name="cn" select="count(preceding-sibling::curve) mod count($colorSch)+1"/>
                        <xsl:variable name="sk" select="0.18"/>
                        <xsl:variable name="line" select="     concat('M', m:R($xShift + $xKoef * point[1]/@x), ',', m:R($yShift + $yKoef * point[1]/@y)),      if (./@smooth = 'yes') then (      (for $a in (2 to (count(point) -1))  return        concat(' S ', m:R($xShift + $xKoef *(point[$a]/@x - (point[$a+1]/@x -point[$a -1]/@x)*$sk)),       ',', m:R($yShift + $yKoef *(point[$a]/@y - (point[$a+1]/@y - point[$a -1]/@y)*$sk)),       ' ',  m:R($xShift + $xKoef * point[$a]/@x), ',',  m:R($yShift + $yKoef * point[$a]/@y) )),      concat (' S ', m:R($xShift + $xKoef * point[last()]/@x), ',', m:R($yShift + $yKoef * point[last()]/@y)),       concat (m:R($xShift + $xKoef * point[last()]/@x), ',', m:R($yShift + $yKoef * point[last()]/@y))     ) else (      for $a in (2 to count(point))  return        concat('L', m:R($xShift + $xKoef * point[$a]/@x), ',', m:R($yShift + $yKoef *point[$a]/@y))     )"/>
                        <svg:path d="{$line}" stroke="{if (./@color) then (./@color) else $colorSch[$cn]}">
                            <xsl:if test="./@lineType">
                                <xsl:attribute name="stroke-dasharray" select="m:LineType(./@lineType)"/>
                            </xsl:if>
                        </svg:path>
                        <xsl:if test="($gra/ph/@legend != 'none') and (name/@visibility='both' or name/@visibility='legend')">
                            <xsl:if test="($gra/ph/@legend = 'right') or ($gra/ph/@legend = 'left')">
                                <svg:path stroke="{if (./@color) then (./@color) else $colorSch[$cn]}" d="M{$legendX},{$legendY + $legendSpacing * ($nn + 1) - 0.38 * $legendFontSize}         l{$legendPictureWd},{0}">
                                    <xsl:if test="./@lineType">
                                        <xsl:attribute name="stroke-dasharray" select="m:LineType(./@lineType)"/>
                                    </xsl:if>
                                </svg:path>
                            </xsl:if>
                            <xsl:if test="($gra/ph/@legend = 'top') or ($gra/ph/@legend = 'bottom')">
                                <svg:path stroke="{if (./@color) then (./@color) else $colorSch[$cn]}" d="M{$legendX +           sum( for $a in (preceding-sibling::curve[name/@visibility='both' or name/@visibility='legend']) return            ((if ($a/name) then string-length($a/name) else 9) *            $legendFontSize * $legendFontWd + $legendPictureWd + $legendGap + $legendMargin)          ) },{$legendY +(1 - 0.38)* $legendFontSize}         l{$legendPictureWd},{0}">
                                    <xsl:if test="./@lineType">
                                        <xsl:attribute name="stroke-dasharray" select="m:LineType(./@lineType)"/>
                                    </xsl:if>
                                </svg:path>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </svg:g>
            </xsl:if>

            <!-- draw points -->
            <xsl:for-each select="$gra/ph/curve">
                <xsl:variable name="nn" select="count(preceding-sibling::curve[name/@visibility='both' or name/@visibility='legend'])"/>
                <xsl:variable name="cn" select="count(preceding-sibling::curve) mod count($colorSch)+1"/>
                <xsl:variable name="cc" select="if (@color) then (@color) else $colorSch[$cn]"/>
                <xsl:if test="some $a in (./point/@pointType, ./@pointType, $gra/ph/@pointType)      satisfies $a != 'none'">
                    <svg:g stroke-width="1.5" fill="none" color="{$cc}" stroke="{$cc}" stroke-linecap="round">
                        <xsl:for-each select="point[some $a in (@pointType, ../@pointType, $gra/ph/@pointType)      satisfies $a != 'none']">
                            <xsl:call-template name="m:drawPoint">
                                <!-- draw a point (mark) of a given type -->
                                <xsl:with-param name="type" select="        if (@pointType) then @pointType else        if (../@pointType) then ../@pointType else        if ($gra/ph/@pointType) then $gra/ph/@pointType else 'none'"/>
                                <xsl:with-param name="x" select="m:R($xShift + $xKoef * @x)"/>
                                <xsl:with-param name="y" select="m:R($yShift + $yKoef * @y)"/>
                                <xsl:with-param name="color" select=" if (@color) then @color else 'inh'"/>
                            </xsl:call-template>
                        </xsl:for-each>

                        <!-- point of a given type for the legend -->
                        <xsl:if test="($gra/ph/@legend != 'none') and (name) and      not (name/@visibility='none' or name/@visibility='graph')">
                            <xsl:call-template name="m:drawPoint">
                                <xsl:with-param name="type" select="        if (./@pointType) then ./@pointType else        if ($gra/ph/@pointType) then $gra/ph/@pointType else 'none'"/>
                                <xsl:with-param name="x" select="$legendX + $legendPictureWd div 2 + (        if ($gra/ph/@legend = 'top' or $gra/ph/@legend = 'bottom') then          sum( for $a in (preceding-sibling::curve[name/@visibility='both' or name/@visibility='legend']) return           ((if ($a/name) then string-length($a/name) else 9) *           $legendFontSize * $legendFontWd + $legendPictureWd + $legendGap + $legendMargin) )        else 0        )"/>
                                <xsl:with-param name="y" select="$legendY  - 0.38 * $legendFontSize + (        if ($gra/ph/@legend = 'right' or $gra/ph/@legend = 'left') then         $legendSpacing *($nn +1)         else          $legendFontSize        )"/>
                                <xsl:with-param name="color" select="'inh'"/>
                            </xsl:call-template>
                        </xsl:if>
                    </svg:g>
                </xsl:if>
            </xsl:for-each>

            <!-- curve titles -->
            <xsl:if test="some $a in $gra/ph/curve satisfies (($a/name) and     not ($a/name/@visibility='none' or $a/name/@visibility='legend'))">
                <svg:g text-anchor="start" font-family="Verdana" font-size="{$curveFontSize}" fill="black">
                    <xsl:for-each select="$gra/ph/curve[(name) and not (name/@visibility='none' or name/@visibility='legend')]">
                        <xsl:variable name="cn" select="count(preceding-sibling::curve) mod count($colorSch)+1"/>
                        <xsl:variable name="cc" select="if (name/@color) then (name/@color) else $colorSch[$cn]"/>
                        <svg:text x="{m:R($xShift + $xKoef * (if (./name/@x) then (./name/@x) else (./point[last()]/@x)))}" y="{m:R($yShift + $yKoef *(if (./name/@y) then (./name/@y) else (./point[last()]/@y)) - 3)}" fill="{$cc}">
                            <xsl:value-of select="./name"/>
                        </svg:text>
                    </xsl:for-each>
                </svg:g>
            </xsl:if>
            <svg:rect x="0.5" y="0.5" width="{m:R($width - 1)}" height="{m:R($height - 1)}" stroke="black" fill="none" stroke-width="1"/>
            <!-- frame around the whole graph-->

            <!-- debuging prints -->
            <!--
	<svg:text x="{$originX}" y="{$originY - 20}" font-family="Verdana" font-size="{$labelFontSize}">
		<xsl:value-of select="m:Log10(1000)"/><xsl:text> || </xsl:text>
		<xsl:value-of select="m:Log10(20.08554)"/><xsl:text> || </xsl:text>
		<xsl:value-of select="m:Round(4321.1234, 25)"/>
		<xsl:value-of select="/graph/@xAxisType"/>
	</svg:text>-->
            <!--svg:text x="{$legendX}" y="{$legendY}" font-family="Verdana" font-size="{$labelFontSize}">
		<xsl:value-of select="m:Round(3999.99, 20)"/>
		<xsl:variable name="tokens" select="tokenize($gra/ph/@xAxisType, '~')"/>
		<xsl:value-of select="$tokens"/><xsl:text> || </xsl:text>
		<xsl:value-of select="$tokens[1]"/><xsl:text> || </xsl:text>
		<xsl:value-of select="$tokens[2]"/><xsl:text> || </xsl:text>
		<xsl:value-of select="$tokens[3]"/><xsl:text> || </xsl:text>
		<xsl:value-of select="$tokens[4]"/><xsl:text> || </xsl:text>
	</svg:text-->

            <!--svg:line x1="{$xAxisLStart}" y1="{$originY}" 
			x2="{$originX}" y2="{$yAxisTStart}" 
			stroke="pink" stroke-width="2"/>  -->

            <!-- debuging frames >
	<svg:rect x="1" y="1" width="{$width - 2}" height="{$titleHg - 2}"  
			stroke="blue" fill="none" stroke-width="1"/> 
	<svg:rect x="{$legendL + 1}" y="{$titleHg + $legendT +1}" width="{$graphWd - 2}" height="{$graphHg - 2}"  
			stroke="red" fill="none" stroke-width="1"/> 
	<svg:rect x="{$legendX - $legendMargin + 1}" y="{$legendY - $legendMargin + 1}" width="{$legendWd - 2}" height="{$legendHg - 2}"  
			stroke="blue" fill="none" stroke-width="1"/> 
	<svg:rect x="0.5" y="{$titleMargin}" width="{$width - 0.5}" height="{$titleFontSize}"  
			stroke="grey" fill="none" stroke-width="1"/>  -->
        </svg:svg>
    </xsl:template>

    <!--******************************************************************************-->
    <!--************************************ end of the main template ************************-->
    <!--******************************************************************************-->
    <xsl:template match="@x" mode="m:processValues">
        <xsl:param name="graph" tunnel="yes"/>
        <xsl:attribute name="x" select="m:ProcessValue($graph/@xAxisType, .)"/>
    </xsl:template>
    <xsl:template match="@y" mode="m:processValues">
        <xsl:param name="graph" tunnel="yes"/>
        <xsl:attribute name="y" select="m:ProcessValue($graph/@yAxisType, .)"/>
    </xsl:template>
    <xsl:template match="gr:*" mode="m:processValues">
        <!-- copy gr element -->
        <xsl:element name="{local-name(.)}">
            <xsl:apply-templates select="@*|*|text()" mode="m:processValues"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*|text()|@*" mode="m:processValues">
        <!-- copy attributes, text and foreign elements -->
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:function name="m:LineType">
        <!-- return "dasharay" for given curve (line) type -->
        <xsl:param name="t"/>
        <xsl:value-of select="   if ($t='dot') then '0.2,3' else    if ($t='dash') then '8,3' else    if ($t='longDash') then '14,3' else    if ($t='dash-dot') then '6,3,0.2,3' else    if ($t='longDash-dot') then '14,3,0.2,3' else    if ($t='dash-dot-dot') then '6,3,0.2,3,0.2,3' else    if ($t='dash-dash-dot-dot') then '6,3,6,3,0.2,3,0.2,3' else    if ($t='longDash-dash') then '14,3,6,3' else 'none'"/>
    </xsl:function>
    <xsl:template name="m:drawPoint">
        <!--draw a point (mark) of a given type -->
        <xsl:param name="type"/>
        <xsl:param name="x" select="0"/>
        <xsl:param name="y" select="0"/>
        <xsl:param name="color" select="black"/>
        <xsl:variable name="poS" select="1.5"/>
        <xsl:variable name="crS" select="3"/>
        <xsl:variable name="plS" select="4"/>
        <xsl:variable name="miS" select="3"/>
        <xsl:variable name="stS" select="4"/>
        <xsl:variable name="sqS" select="3"/>
        <xsl:variable name="ciS" select="4"/>
        <xsl:variable name="trS" select="4"/>
        <xsl:variable name="rhS" select="4"/>
        <xsl:choose>
            <xsl:when test="$type = 'point'">
                <svg:circle cx="{$x}" cy="{$y}" r="{$poS}" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </svg:circle>
            </xsl:when>
            <xsl:when test="$type = 'cross' ">
                <svg:path d="M {$x},{$y} m {- $crS},{- $crS} l {2 * $crS},{2 * $crS} m 0,{- 2 * $crS} l {- 2 * $crS},{2 * $crS}">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <xsl:when test="$type = 'plus' ">
                <svg:path d="M {$x},{$y} m {- $plS},0 l {2 * $plS},0 m {- $plS},{- $plS} l 0,{2 * $plS}">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <xsl:when test="$type = 'minus' ">
                <svg:path d="M{$x},{$y} m{-$miS},0 h{2*$miS}">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <xsl:when test="$type = 'star'">
                <svg:path d="M {$x},{$y} m 0,{- $stS} l 0,{2 * $stS} m {- $stS * 0.87},{- $stS * 1.5} l {$stS * 1.73},{$stS}      m {- $stS * 1.73},0 l {$stS * 1.73},{-$stS}">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <!--xsl:when test="$type = 'star2'">
			<svg:path d="M {$x},{$y} m {- $stS},0 l {2 * $stS},0 m {- $stS * 1.5},{- $stS * 0.87} l {$stS},{$stS * 1.73}
					m 0,{- $stS * 1.73} l {-$stS},{$stS * 1.73}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when-->
            <xsl:when test="$type = 'square'">
                <svg:path d="M {$x},{$y} m {- $sqS},{- $sqS} l {2 * $sqS},0 l 0,{2 * $sqS} l {- 2 * $sqS},0 z">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <xsl:when test="$type = 'circle'">
                <svg:circle cx="{$x}" cy="{$y}" r="{$ciS}">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </svg:circle>
            </xsl:when>
            <xsl:when test="$type = 'triangle'">
                <svg:path d="M {$x},{$y} m {$trS},{- $trS * 0.58} l {-2 * $trS},0 l {$trS},{$trS * 1.73} z">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <xsl:when test="$type = 'rhomb'">
                <svg:path d="M {$x},{$y} m 0,{- $rhS} l {$rhS},{$rhS} l {- $rhS},{$rhS} l {- $rhS},{- $rhS} z">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <xsl:when test="$type = 'pyramid'">
                <svg:path d="M {$x},{$y} m {$trS},{$trS * 0.58} l {-2 * $trS},0 l {$trS},{- $trS * 1.73} z">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <xsl:when test="$type = 'squareF'">
                <svg:path d="M {$x},{$y} m {- $sqS},{- $sqS} l {2 * $sqS},0 l 0,{2 * $sqS} l {- 2 * $sqS},0 z" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <xsl:when test="$type = 'circleF'">
                <svg:circle cx="{$x}" cy="{$y}" r="{$ciS}" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </svg:circle>
            </xsl:when>
            <xsl:when test="$type = 'triangleF'">
                <svg:path d="M {$x},{$y} m {$trS},{- $trS * 0.58} l {-2 * $trS},0 l {$trS},{$trS * 1.73} z" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <xsl:when test="$type = 'rhombF'">
                <svg:path d="M {$x},{$y} m 0,{- $rhS} l {$rhS},{$rhS} l {- $rhS},{$rhS} l {- $rhS},{- $rhS} z" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <xsl:when test="$type = 'pyramidF'">
                <svg:path d="M {$x},{$y} m {$trS},{$trS * 0.58} l {-2 * $trS},0 l {$trS},{- $trS * 1.73} z" fill="currentColor">
                    <xsl:if test="($color != 'inh')">
                        <xsl:attribute name="stroke" select="$color"/>
                        <xsl:attribute name="color" select="$color"/>
                    </xsl:if>
                </svg:path>
            </xsl:when>
            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:function name="m:GMax">
        <!-- truncates up the maximum (of an axis) to the whole axis steps -->
        <xsl:param name="max"/>
        <xsl:param name="step"/>
        <xsl:variable name="pom" select="$step * ceiling($max div $step)"/>
        <xsl:value-of select="    if (($pom = 0)  or (($pom &gt; 0) and ($pom != $max))) then $pom else ($pom +$step) "/>
    </xsl:function>
    <xsl:function name="m:Step10Base">
        <xsl:param name="dif"/>
        <xsl:param name="count"/>
        <xsl:variable name="ps" select="($dif) div $count"/>
        <xsl:variable name="rad" select="floor(m:Log10($ps))"/>
        <xsl:variable name="cif" select="$ps div math:power(10, $rad)"/>
        <xsl:variable name="st" select="   if ($cif &lt; 1.6) then 1 else   if ($cif &lt; 2.2) then 2 else   if ($cif &lt; 4) then 2.5 else   if ($cif &lt; 9) then 5 else 10"/>
        <xsl:value-of select="$st * math:power(10, $rad)"/>
    </xsl:function>
    <xsl:function name="m:Step10BaseInteger">
        <xsl:param name="step"/>
        <xsl:variable name="rad" select="floor(m:Log10($step))"/>
        <xsl:variable name="cif" select="$step div math:power(10, $rad)"/>
        <xsl:variable name="st" select="   if ($cif &lt; 1.33333) then 1 else   if ($cif &lt; 2.85714) then 2 else   if ($cif &lt; 6.66667) then 5 else 10"/>
        <xsl:value-of select="$st * math:power(10, $rad)"/>
    </xsl:function>
    <xsl:function name="m:Step24Base">
        <xsl:param name="step"/>
        <xsl:value-of select="   if ($step &lt; 1.33333) then 1 else   if ($step &lt; 2.4) then 2 else   if ($step &lt; 3.42857) then 3 else   if ($step &lt; 4.8) then 4 else   if ($step &lt; 6.85714) then 6 else   if ($step &lt; 9.6) then 8 else   if ($step &lt; 16) then 12 else 24"/>
    </xsl:function>
    <xsl:function name="m:Step60Base">
        <xsl:param name="step"/>
        <xsl:value-of select="   if ($step &lt; 1.33333) then 1 else   if ($step &lt; 2.4) then 2 else   if ($step &lt; 3.42857) then 3 else   if ($step &lt; 4.44444) then 4 else   if ($step &lt; 5.45455) then 5 else   if ($step &lt; 7.5) then 6 else   if ($step &lt; 10.90909) then 10 else   if ($step &lt; 13.33333) then 12 else   if ($step &lt; 17.14286) then 15 else   if ($step &lt; 24) then 20 else   if ($step &lt; 40) then 30 else 60"/>
    </xsl:function>


    <!-- returns a length of axes step -->
    <xsl:function name="m:Step">
        <xsl:param name="dif"/>
        <xsl:param name="count"/>
        <xsl:param name="axisType"/>
        <xsl:choose>
            <xsl:when test="$axisType='log'">
                <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:when test="starts-with($axisType,'dateTime')">
                <xsl:variable name="ps" select="($dif) div $count"/>
                <xsl:variable name="days" select="$ps div 86400"/>
                <xsl:variable name="hours" select="($ps mod 86400) div 3600"/>
                <xsl:variable name="minutes" select="($ps mod 3600) div 60"/>
                <xsl:variable name="seconds" select="$ps mod 60"/>
                <xsl:value-of select="                             if ($days &gt; 1) then round($days)*86400 else                             if ($hours &gt; 1) then m:Step24Base($hours)*3600 else                             if ($minutes &gt; 1) then m:Step60Base($minutes)*60 else                             m:Step60Base($seconds)                             "/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="m:Step10Base(if ($dif != 0) then $dif                              else 0.0000001, $count)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!-- rounds the value on same number of decimal places as has the
step, used for printing values on axes -->

    <!-- format examples: http://www.w3.org/TR/xslt20/#date-time-examples
-->
    <xsl:function name="m:Round">
        <xsl:param name="val"/>
        <xsl:param name="step"/>
        <xsl:param name="axisType"/>
        <xsl:choose>
            <xsl:when test="$axisType='log'">
                <xsl:value-of select="10"/>
            </xsl:when>
            <xsl:when test="starts-with($axisType,'dateTime')">
                <xsl:variable name="dateTime" select="xs:dateTime('0001-01-01T00:00:00') + m:NumberToDuration($val)"/>
                <!--
          <xsl:variable name="dateTime"
            select="xs:dateTime('2010-01-29T11:05:00') + 
                    functx:dayTimeDuration(0, 0, 0, $val)"/>
          -->
                <xsl:variable name="tokens" select="tokenize($axisType, '~')"/>
                <xsl:value-of select="format-dateTime($dateTime, $tokens[2],                                  $tokens[3], $tokens[4], $tokens[5])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="rad" select="floor(m:Log10($step))"/>
                <xsl:variable name="pom" select="round($val * math:power(10,                                             - $rad +1)) * math:power(10, $rad - 1)"/>
                <xsl:value-of select="if ($pom != 0) then                                  format-number($pom, '#.##############') else $pom"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>



    <!-- rounds the value on same number of decimal places as has the step, used for printing values on axes -->
    <xsl:function name="m:Round">
        <xsl:param name="val"/>
        <xsl:param name="step"/>
        <xsl:variable name="rad" select="floor(m:Log10($step))"/>
        <xsl:variable name="pom" select="round($val * math:power(10, - $rad +1)) * math:power(10, $rad - 1)"/>
        <xsl:value-of select="if ($pom != 0) then format-number($pom, '#.##############') else $pom"/>
    </xsl:function>

    <!-- rounds the value on 2 decimal places, used for coordinates -->
    <xsl:function name="m:R">
        <xsl:param name="val"/>
        <xsl:value-of select="round($val * 100) div 100"/>
    </xsl:function>

    <!-- calculate logarithm to the base 10 -->
    <xsl:function name="m:Log10">
        <xsl:param name="val"/>
        <xsl:variable name="const" select="0.43429448190325182765112891891661"/>
        <!--log_10 (e)-->
        <xsl:value-of select="$const*math:log($val)"/>
    </xsl:function>
    <xsl:function name="m:ProcessValue">
        <xsl:param name="axisType"/>
        <xsl:param name="val"/>
        <xsl:choose>
            <xsl:when test="$axisType='log'">
                <xsl:value-of select="m:Log10(if (($val) != 0) then math:abs($val) else 1) "/>
            </xsl:when>
            <xsl:when test="starts-with($axisType,'dateTime')">
                <xsl:variable name="timeZero" select="xs:dateTime('0001-01-01T00:00:00')"/>
                <xsl:value-of select="m:DurationToNumber(xs:dateTime($val) - $timeZero)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$val"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="m:NumberToDuration" as="xs:dayTimeDuration">
        <xsl:param name="num"/>
        <xsl:value-of select="xs:dayTimeDuration('PT1S') * $num"/>
    </xsl:function>
    <xsl:function name="m:DurationToNumber">
        <xsl:param name="dur"/>
        <xsl:value-of select="$dur div xs:dayTimeDuration('PT1S')"/>
    </xsl:function>
</xsl:stylesheet><!--
 # Software distributed under the License is distributed on an "AS IS" basis,
 # WITHOUT WARRANTY OF ANY KIND, either express or implied.
 # See the License for rights and limitations under the License.
 # xygr2svg.xsl enerates an SVG file from an xml file valid to xygr.rng
 # Copyright (C) 2007,2008,2009,2010  Jakub Vojtisek
 # Contribution: Dave Pawson
 #
 # This program is free software; you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation; either version 2 of the License, or (at
 # your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software
 # Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 # 02110-1301, USA.
 #
 # Software distributed under the License is distributed on an "AS IS" basis,
 # WITHOUT WARRANTY OF ANY KIND, either express or implied.
 # See the License for rights and limitations under the License.
 -->