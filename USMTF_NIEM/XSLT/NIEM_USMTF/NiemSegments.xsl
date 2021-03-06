<?xml version="1.0" encoding="UTF-8"?>
<!--
/* 
 * Copyright (C) 2017 JD NEUSHUL
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:term="http://release.niem.gov/niem/localTerminology/3.0/"
    xmlns:ism="urn:us:gov:ic:ism:v2" xmlns:appinfo="http://release.niem.gov/niem/appinfo/3.0/" xmlns:mtfappinfo="urn:mtf:mil:6040b:appinfo" xmlns:ddms="http://metadata.dod.mil/mdr/ns/DDMS/2.0/"
    exclude-result-prefixes="xsd" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="USMTF_Utility.xsl"/>

    <!--Baseline Fields XML Schema document-->
    <xsl:variable name="baseline_msgs_xsd" select="document('../../XSD/Baseline_Schema/messages.xsd')"/>
    <xsl:variable name="baseline_segments_xsd" select="$baseline_msgs_xsd/*//xsd:element[xsd:annotation/xsd:appinfo/*:SegmentStructureName]"/>

    <xsl:variable name="niem_fields_map" select="document('../../XSD/NIEM_MTF/NIEM_MTF_Fieldmaps.xml')/*"/>
    <xsl:variable name="niem_composites_map" select="document('../../XSD/NIEM_MTF/NIEM_MTF_Compositemaps.xml')/*"/>
    <xsl:variable name="niem_sets_map" select="document('../../XSD/NIEM_MTF/NIEM_MTF_Setmaps.xml')/*"/>

    <xsl:variable name="segment_changes" select="document('../../XSD/Refactor_Changes/SegmentChanges.xml')/*"/>
    <xsl:variable name="substGrp_Changes" select="document('../../XSD/Refactor_Changes/SubstitutionGroupChanges.xml')/SubstitionGroups"/>
    <!--Outputs-->
    <xsl:variable name="segmentmapsoutput" select="'../../XSD/NIEM_MTF/NIEM_MTF_Segmentmaps.xml'"/>
    <xsl:variable name="segmentsxsdoutputdoc" select="'../../XSD/NIEM_MTF/NIEM_MTF_Segments.xsd'"/>
    <xsl:variable name="choiceanalysisoutputdoc" select="'../../XSD/Analysis/SegmentChoices.xml'"/>



    <!-- XSD MAP-->
    <!-- _______________________________________________________ -->
    <xsl:variable name="segmentmaps">
        <xsl:apply-templates select="$baseline_segments_xsd" mode="segmentglobal"/>
    </xsl:variable>
    <xsl:template match="xsd:element" mode="segmentglobal">
        <xsl:variable name="annot">
            <xsl:apply-templates select="xsd:annotation"/>
        </xsl:variable>
        <xsl:variable name="mtfname" select="@name"/>
        <xsl:variable name="mtfmsg" select="ancestor::xsd:element[parent::xsd:schema]/@name"/>
        <xsl:variable name="n" select="@name"/>
        <xsl:variable name="changename" select="$segment_changes/Segment[@mtfname = $mtfname][@mtfmsg = $mtfmsg]"/>
        <xsl:variable name="niemelementnamevar">
            <xsl:choose>
                <xsl:when test="$changename/@niemelementname">
                    <xsl:value-of select="$changename/@niemelementname"/>
                </xsl:when>
                <xsl:when test="ends-with($n, 'Segment')">
                    <xsl:value-of select="$n"/>
                </xsl:when>
                <xsl:when test="contains($n, 'Segment_')">
                    <xsl:value-of select="concat(substring-before($n, 'Segment_'), 'Segment')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($n, 'Segment')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemcomplextype">
            <xsl:value-of select="concat($niemelementnamevar, 'Type')"/>
        </xsl:variable>
        <xsl:variable name="changedoc" select="$segment_changes/Segment[@mtfname = $mtfname][@niemcomplextype = $niemcomplextype]"/>
        <xsl:variable name="mtfdoc">
            <xsl:choose>
                <xsl:when test="xsd:annotation/xsd:documentation">
                    <xsl:value-of select="normalize-space(xsd:annotation/xsd:documentation)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space($annot/*/xsd:documentation)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="segseq">
            <xsl:value-of select="xsd:complexType/xsd:attribute[@name = 'segSeq'][1]/@fixed"/>
        </xsl:variable>
        <xsl:variable name="niemtypedocvar">
            <xsl:choose>
                <xsl:when test="$changedoc/@niemtypedoc">
                    <xsl:value-of select="concat('A data type for the', $changedoc/@niemtypedoc, 'The')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('A data type for the', substring-after($mtfdoc, 'The'))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemelementdocvar">
            <xsl:choose>
                <xsl:when test="$changedoc/@niemelementdoc">
                    <xsl:value-of select="$changedoc/@niemelementdoc"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace($niemtypedocvar, 'A data type for', 'A data item for')"/>
                    <!--<xsl:value-of select="normalize-space($niemtypedoc)"/>-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="appinfovar">
            <xsl:for-each select="$annot/*/xsd:appinfo">
                <xsl:copy-of select="*:Segment" copy-namespaces="no"/>
            </xsl:for-each>
        </xsl:variable>
        <Segment mtfname="{@name}" mtfmsg="{$mtfmsg}" niemcomplextype="{$niemcomplextype}" niemelementname="{$niemelementnamevar}" niemelementdoc="{$niemelementdocvar}" mtfdoc="{$mtfdoc}"
            niemtypedoc="{$niemtypedocvar}">
            <xsl:if test="string-length($segseq) &gt; 0">
                <xsl:attribute name="segseq">
                    <xsl:value-of select="$segseq"/>
                </xsl:attribute>
            </xsl:if>
            <appinfo>
                <xsl:for-each select="$appinfovar/*">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </appinfo>
            <xsl:apply-templates select="*[not(name() = 'xsd:annotation')]"/>
        </Segment>
    </xsl:template>
    <xsl:template match="xsd:element">
        <xsl:param name="sbstgrp"/>
        <xsl:variable name="mtfnamevar" select="@name"/>
        <xsl:variable name="mtfroot">
            <xsl:choose>
                <xsl:when test="$segment_changes/Element[@mtfname = $mtfnamevar]">
                    <xsl:value-of select="$mtfnamevar"/>
                </xsl:when>
                <xsl:when test="contains(@name, '_')">
                    <xsl:value-of select="substring-before(@name, '_')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="annot">
            <xsl:apply-templates select="xsd:annotation"/>
        </xsl:variable>
        <xsl:variable name="appinfovar">
            <xsl:for-each select="$annot/*/xsd:appinfo">
                <xsl:copy-of select="*" copy-namespaces="no"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="mtftype">
            <xsl:value-of select="xsd:complexType/*/xsd:extension/@base"/>
        </xsl:variable>
        <xsl:variable name="n">
            <xsl:apply-templates select="@name" mode="fromtype"/>
        </xsl:variable>
        <xsl:variable name="niemmatch">
            <xsl:choose>
                <xsl:when test="starts-with($mtftype, 'f:')">
                    <xsl:copy-of select="$niem_fields_map/*[@mtfname = substring-after($mtftype, 'f:')]"/>
                </xsl:when>
                <xsl:when test="starts-with($mtftype, 'c:')">
                    <xsl:copy-of select="$niem_composites_map/*[@mtfname = substring-after($mtftype, 'c:')]"/>
                </xsl:when>
                <xsl:when test="starts-with($mtftype, 's:')">
                    <xsl:copy-of select="$niem_sets_map/*[@mtfname = substring-after($mtftype, 's:')]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemtypevar">
            <xsl:choose>
                <xsl:when test="string-length($niemmatch/*/@niemcomplextype) &gt; 0">
                    <xsl:value-of select="$niemmatch/*/@niemcomplextype"/>
                </xsl:when>
                <!--<xsl:when test="starts-with($mtfnamevar, 'TrackManagementFilterSettingsSegment')">
                    <xsl:text>TrackManagementFilterSettingsSegmentType</xsl:text>
                </xsl:when>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemelement">
            <xsl:choose>
                <xsl:when test="string-length($sbstgrp) &gt; 0">
                    <xsl:variable name="niemel" select="$niemmatch/*/@niemelementname"/>
                    <xsl:variable name="subgrp">
                        <xsl:value-of select="substring-before($sbstgrp, 'Choice')"/>
                    </xsl:variable>
                    <!-- <xsl:value-of select="concat($subgrp, $niemel)"/>-->
                    <xsl:value-of select="$niemel"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$mtfnamevar"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="UseDesc">
            <xsl:value-of select="translate(upper-case($appinfovar/*/@usage), '.', '')"/>
        </xsl:variable>
        <xsl:variable name="TextIndicator">
            <xsl:if test="contains($UseDesc, 'MUST EQUAL')">
                <xsl:value-of select="normalize-space(substring-after($UseDesc, 'MUST EQUAL'))"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="niemnamevar">
            <xsl:choose>
                <xsl:when test="starts-with($mtfnamevar, 'GeneralText')">
                    <xsl:call-template name="GenTextName">
                        <xsl:with-param name="textind" select="$TextIndicator"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="starts-with($mtfnamevar, 'HeadingInformation')">
                    <xsl:call-template name="HeadingInformation">
                        <xsl:with-param name="textind" select="$TextIndicator"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="contains($niemelement, '_')">
                    <xsl:value-of select="substring-before($niemelement, '_')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace($niemelement, 'Indicator', 'Code')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="fixedval">
            <xsl:choose>
                <xsl:when test="starts-with($mtfnamevar, 'GeneralText')">
                    <xsl:value-of select="upper-case(substring-before(@niemelementname, 'GenText'))"/>
                </xsl:when>
                <xsl:when test="starts-with($mtfnamevar, 'HeadingSet')">
                    <xsl:value-of select="upper-case(substring-before(@niemelementname, 'GenText'))"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ffirnfud">
            <xsl:value-of select="xsd:complexType/*//xsd:attribute[@name = 'ffirnFudn']/@fixed"/>
        </xsl:variable>
        <xsl:variable name="setseq">
            <xsl:value-of select="xsd:complexType/xsd:complexContent/xsd:extension/xsd:attribute[@name = 'setSeq'][1]/@fixed"/>
        </xsl:variable>
        <xsl:variable name="mtfdoc">
            <xsl:choose>
                <xsl:when test="xsd:annotation/xsd:documentation">
                    <xsl:value-of select="normalize-space(xsd:annotation/xsd:documentation)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space($annot/xsd:documentation)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="segmentname" select="ancestor::xsd:element[ends-with(@name, 'Segment')][1]/@name"/>
        <xsl:variable name="docchange" select="$segment_changes/Element[@mtfname = $mtfroot][@niemname = '']"/>
        <xsl:variable name="contxtchange" select="$segment_changes/Element[@mtfname = $mtfroot][@segmentname = $segmentname]"/>
        <xsl:variable name="niemelementnamevar">
            <xsl:choose>
                <xsl:when test="$substGrp_Changes/Element[@mtfname = $mtfroot][@substitutionGroup = $sbstgrp]/@niemname">
                    <xsl:value-of select="$substGrp_Changes/Element[@mtfname = $mtfroot][@substitutionGroup = $sbstgrp]/@niemname"/>
                </xsl:when>
                <xsl:when test="$docchange/@niemelementname">
                    <xsl:value-of select="$docchange/@niemelementname"/>
                </xsl:when>
                <xsl:when test="$contxtchange/@niemelementname">
                    <xsl:value-of select="$contxtchange/@niemelementname"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$niemnamevar"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemelementdocvar">
            <xsl:choose>
                <xsl:when test="$docchange/@niemelementdoc">
                    <xsl:value-of select="$docchange/@niemelementdoc"/>
                </xsl:when>
                <xsl:when test="$contxtchange/@niemelementdoc">
                    <xsl:value-of select="$contxtchange/@niemelementdoc"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('A data item for the', substring-after($mtfdoc, 'The'))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemtypedocvar">
            <xsl:choose>
                <xsl:when test="$niemmatch/*/@niemtypedoc">
                    <xsl:value-of select="
                            $niemmatch/*/@niemtypedoc
                            "/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$mtfdoc"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <Element mtfname="{@name}" segmentname="{$segmentname}" niemelementname="{$niemelementnamevar}" mtfdoc="{$mtfdoc}">
            <xsl:if test="string-length($mtftype) &gt; 0">
                <xsl:attribute name="mtftype">
                    <xsl:value-of select="$mtftype"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length($niemelementdocvar) &gt; 0">
                <xsl:attribute name="niemelementdoc">
                    <xsl:value-of select="$niemelementdocvar"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length($niemtypevar) &gt; 0">
                <xsl:attribute name="niemtype">
                    <xsl:value-of select="$niemtypevar"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length($niemtypedocvar) &gt; 0">
                <xsl:attribute name="niemtypedoc">
                    <xsl:value-of select="$niemtypedocvar"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length($appinfovar/*/@usage) &gt; 0">
                <xsl:attribute name="usage">
                    <xsl:value-of select="$appinfovar/*/@usage"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length($TextIndicator) &gt; 0">
                <xsl:attribute name="textindicator">
                    <xsl:value-of select="$TextIndicator"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length($setseq) &gt; 0">
                <xsl:attribute name="setseq">
                    <xsl:value-of select="$setseq"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="@minOccurs"/>
            <xsl:copy-of select="@maxOccurs"/>
            <appinfo>
                <xsl:for-each select="$appinfovar/*">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </appinfo>
            <xsl:apply-templates select="*[not(name() = 'xsd:annotation')]"/>
        </Element>
    </xsl:template>
    <xsl:template match="xsd:sequence">
        <Sequence>
            <xsl:apply-templates select="xsd:*"/>
        </Sequence>
    </xsl:template>
    <xsl:template match="xsd:complexType">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <xsl:template match="xsd:simpleContent">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <xsl:template match="xsd:complexContent">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <xsl:template match="xsd:extension">
        <xsl:apply-templates select="*[not(name() = 'xsd:annotation')]"/>
    </xsl:template>
    <xsl:template match="xsd:attribute"/>
    <!--  Choice / Substitution Groups Map -->
    <xsl:template match="xsd:choice">
        <xsl:variable name="segname">
            <xsl:value-of select="ancestor::xsd:element[@name][1]/@name"/>
        </xsl:variable>
        <xsl:variable name="segmentnamevar">
            <xsl:choose>
                <xsl:when test="$segname = 'SpecialOptionDataAsrSegment'">
                    <xsl:choose>
                        <xsl:when test="xsd:element[@name = 'UnitDesignationData']">
                            <xsl:text>Designation</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>SupplyRate</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="starts-with($segname, '_')">
                    <xsl:value-of select="substring-after($segname, '_')"/>
                </xsl:when>
                <xsl:when test="contains($segname, '_')">
                    <xsl:value-of select="substring-before($segname, '_')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$segname"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="segchoicename">
            <xsl:value-of select="concat($segmentnamevar, 'Choice')"/>
        </xsl:variable>
        <xsl:variable name="substmatch">
            <xsl:copy-of select="$substGrp_Changes/Choice[@choicename = $segchoicename][@segmentname = $segmentnamevar][1]"/>
        </xsl:variable>
        <xsl:variable name="choicenamevar">
            <xsl:choose>
                <xsl:when test="$substmatch/*/@niemname">
                    <xsl:value-of select="$substmatch/*/@niemname"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$segchoicename"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="substgrpdocvar">
            <xsl:value-of select="concat('A data concept for a choice of', substring-after($substmatch/*/@substgrpdoc, 'A choice of'))"/>
        </xsl:variable>
        <xsl:variable name="seq" select="xsd:element[1]//xsd:extension[1]/xsd:attribute[@name = 'setSeq']/@fixed"/>
        <Element choicename="{$choicenamevar}" segmentname="{$segmentnamevar}" substgrpname="{$choicenamevar}" substgrpdoc="{$substgrpdocvar}" seq="{$seq}">
            <xsl:choose>
                <!--THIS MITIGATES AN ACTUAL INCONSISTENCY IN THE MIL STD-->
                <xsl:when test="$choicenamevar = 'Link16UnitSegmentChoice'">
                    <xsl:attribute name="minOccurs">
                        <xsl:text>0</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="MTFISSUEminOccurs">
                        <xsl:text>1</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <!-- _____________________________________-->
                <xsl:otherwise>
                    <xsl:copy-of select="@minOccurs"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="@maxOccurs"/>
            <Choice name="{$choicenamevar}">
                <xsl:apply-templates select="*[not(name() = 'xsd:annotation')]">
                    <xsl:with-param name="sbstgrp">
                        <xsl:value-of select="$choicenamevar"/>
                    </xsl:with-param>
                </xsl:apply-templates>
            </Choice>
        </Element>
    </xsl:template>
    <xsl:template name="GenTextName">
        <xsl:param name="textind"/>
        <xsl:variable name="per">&#46;</xsl:variable>
        <xsl:variable name="qot">&#34;</xsl:variable>
        <xsl:variable name="apos">&#39;</xsl:variable>
        <xsl:variable name="lparen">&#40;</xsl:variable>
        <xsl:variable name="rparen">&#41;</xsl:variable>
        <xsl:variable name="CCase">
            <xsl:call-template name="CamelCase">
                <xsl:with-param name="text">
                    <xsl:value-of select="replace($textind, $apos, '')"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <!--Name .. handle 2 special cases with parens-->
        <xsl:variable name="n">
            <xsl:value-of select="translate(replace(replace($CCase, '(TAS)', ''), '(mpa)', ''), ' ()', '')"/>
        </xsl:variable>
        <xsl:choose>
            <!--THIS IS FROM AN ACTUAL INCONSISTENCY IN THE MIL STD-->
            <xsl:when test="$n = 'SecurityAndDefenseRemarks'">
                <xsl:text>SecurityAndDefensesRemarksGenText</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($n, 'GenText')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="HeadingInformation">
        <xsl:param name="textind"/>
        <xsl:variable name="per">&#46;</xsl:variable>
        <xsl:variable name="qot">&#34;</xsl:variable>
        <xsl:variable name="apos">&#39;</xsl:variable>
        <xsl:variable name="lparen">&#40;</xsl:variable>
        <xsl:variable name="rparen">&#41;</xsl:variable>
        <xsl:variable name="CCase">
            <xsl:call-template name="CamelCase">
                <xsl:with-param name="text">
                    <xsl:value-of select="replace($textind, $apos, '')"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="n">
            <xsl:value-of select="translate(replace(replace($CCase, '(TAS)', ''), '(mpa)', ''), ' ,/”()', '')"/>
        </xsl:variable>
        <xsl:variable name="fixed">
            <xsl:value-of select="translate(replace($textind, $apos, ''), '”', '')"/>
        </xsl:variable>
        <xsl:value-of select="concat($n, 'HeadingSet')"/>
    </xsl:template>
    <!-- _______________________________________________________ -->

    <!--XSD GENERATION-->
    <!-- _______________________________________________________ -->

    <xsl:variable name="segmentelements">
        <xsl:for-each select="$segmentmaps//Sequence/Element">
            <xsl:sort select="@niemelementname"/>
            <xsl:variable name="n" select="@niemelementname"/>
            <xsl:variable name="segSeq">
                <xsl:value-of select="ancestor::Segment/@segseq"/>
            </xsl:variable>
            <xsl:choose>
                <!--<xsl:when test="appinfo/mtfappinfo:Segment"/>-->
                <xsl:when test="$niem_sets_map//*[@niemelementname = $n]"/>
                <xsl:when test="@niemelementname and @niemtype">
                    <xsd:element name="{@niemelementname}">
                        <xsl:attribute name="type">
                            <xsl:choose>
                                <xsl:when test="starts-with(@mtftype, 's')">
                                    <xsl:value-of select="concat('s:', @niemtype)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@niemtype"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="nillable">
                            <xsl:text>true</xsl:text>
                        </xsl:attribute>
                        <xsd:annotation>
                            <xsd:documentation>
                                <xsl:choose>
                                    <xsl:when test="@niemtypedoc">
                                        <xsl:value-of select="@niemtypedoc"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@niemelementdoc"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsd:documentation>
                            <xsl:choose>
                                <xsl:when test="appinfo/mtfappinfo:Segment">
                                    <xsd:appinfo>
                                        <xsl:copy-of select="appinfo/mtfappinfo:Segment"/>
                                    </xsd:appinfo>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="appinfo/*">
                                        <xsd:appinfo>
                                            <xsl:copy>
                                                <xsl:copy-of select="@positionName"/>
                                                <!--<xsl:copy-of select="@concept"/>-->
                                                <!--<xsl:copy-of select="@usage"/>-->
                                            </xsl:copy>
                                        </xsd:appinfo>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsd:annotation>
                    </xsd:element>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="$segmentmaps//Element[Choice]">
            <xsl:variable name="substgrp" select="@substgrpname"/>
            <xsd:element name="{@substgrpname}" abstract="true">
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:value-of select="@substgrpdoc"/>
                    </xsd:documentation>
                </xsd:annotation>
            </xsd:element>
            <xsl:for-each select="Choice/Element">
                <xsl:variable name="prefix" select="substring-before(@mtftype, ':')"/>
                <xsl:variable name="niemelementdoc">
                    <xsl:choose>
                        <xsl:when test="string-length(@niemelementdoc) &gt; 0">
                            <xsl:value-of select="@niemelementdoc"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@mtfdoc"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="n" select="@niemelementname"/>
                <xsl:if test="not($niem_sets_map//*[@niemelementname = $n])">
                    <!--<xsd:element name="{@niemelementname}" type="{@niemtype}" substitutionGroup="{$substgrp}" nillable="true">-->
                    <xsd:element name="{@niemelementname}" type="{concat($prefix,':',@niemtype)}" substitutionGroup="{$substgrp}" nillable="true">
                        <xsd:annotation>
                            <xsd:documentation>
                                <xsl:value-of select="@niemelementdoc"/>
                            </xsd:documentation>
                        </xsd:annotation>
                    </xsd:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="segmentsxsd">
        <xsl:for-each select="$segmentmaps/Segment">
            <xsl:sort select="@niemcomplextype"/>
            <xsd:complexType name="{@niemcomplextype}">
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:value-of select="@niemtypedoc"/>
                    </xsd:documentation>
                </xsd:annotation>
                <xsd:complexContent>
                    <xsd:extension base="structures:ObjectType">
                        <xsd:sequence>
                            <xsl:for-each select="*:Sequence/Element">
                                <xsl:variable name="n" select="@niemelementname"/>
                                <xsl:variable name="p" select="substring-before(@mtftype, ':')"/>
                                <xsl:variable name="refname">
                                    <xsl:choose>
                                        <xsl:when test="@substgrpname">
                                            <xsl:value-of select="@substgrpname"/>
                                        </xsl:when>
                                        <xsl:when test="$segmentelements/*[@name = $n]">
                                            <xsl:value-of select="$n"/>
                                        </xsl:when>
                                        <xsl:when test="$p">
                                            <xsl:value-of select="concat($p, ':', $n)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$n"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsd:element ref="{$refname}">
                                    <xsl:copy-of select="@minOccurs"/>
                                    <xsl:copy-of select="@maxOccurs"/>
                                    <xsd:annotation>
                                        <xsd:documentation>
                                            <xsl:choose>
                                                <xsl:when test="string-length(@mtfdoc) &gt; 0">
                                                    <xsl:value-of select="replace(@mtfdoc, 'A data type', 'A data item')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="@niemelementdoc"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsd:documentation>
                                        <xsl:for-each select="appinfo/*">
                                            <xsd:appinfo>
                                                <xsl:copy>
                                                    <xsl:copy-of select="@positionName"/>
                                                    <xsl:copy-of select="@concept"/>
                                                    <xsl:copy-of select="@usage"/>
                                                </xsl:copy>
                                            </xsd:appinfo>
                                        </xsl:for-each>
                                    </xsd:annotation>
                                </xsd:element>
                            </xsl:for-each>
                            <xsd:element ref="{concat(substring(@niemcomplextype,0,string-length(@niemcomplextype)-3),'AugmentationPoint')}" minOccurs="0" maxOccurs="unbounded"/>
                        </xsd:sequence>
                    </xsd:extension>
                </xsd:complexContent>
            </xsd:complexType>
            <xsd:element name="{concat(substring(@niemcomplextype,0,string-length(@niemcomplextype)-3),'AugmentationPoint')}" abstract="true">
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:value-of select="concat('An augmentation point for ', @niemcomplextype)"/>
                    </xsd:documentation>
                </xsd:annotation>
            </xsd:element>
            <xsd:element name="{@niemelementname}" type="{@niemcomplextype}" nillable="true">
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:value-of select="@niemelementdoc"/>
                    </xsd:documentation>
                    <xsl:for-each select="appinfo/*">
                        <xsd:appinfo>
                            <xsl:copy>
                                <xsl:copy-of select="@name"/>
                                <xsl:copy-of select="@positionName"/>
                                <!--<xsl:copy-of select="@usage"/>
                                <xsl:copy-of select="@concept"/>-->
                            </xsl:copy>
                        </xsd:appinfo>
                    </xsl:for-each>
                </xsd:annotation>
            </xsd:element>
        </xsl:for-each>
        <!--Global Set Elements-->
        <xsl:copy-of select="$segmentelements"/>
        <!--Set Elements with Choice to Substitution Groups-->
        <xsl:for-each select="$segmentmaps//Element[Choice]">
            <xsl:variable name="substgrp" select="@substgrpname"/>
            <xsd:element name="{@substgrpname}" abstract="true">
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:value-of select="normalize-space(@substgrpdoc)"/>
                    </xsd:documentation>
                </xsd:annotation>
            </xsd:element>
            <xsl:for-each select="Choice/Element">
                <xsl:variable name="prefix" select="substring-before(@mtftype, ':')"/>
                <xsd:element name="{@niemelementname}" type="{concat($prefix,':',@niemtype)}" substitutionGroup="{$substgrp}" nillable="true">
                    <xsd:annotation>
                        <xsd:documentation>
                            <xsl:value-of select="normalize-space(@niemelementdoc)"/>
                        </xsd:documentation>
                    </xsd:annotation>
                </xsd:element>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>

    <!--    OUTPUT RESULT-->
    <!-- _______________________________________________________ -->

    <xsl:template name="main">
        <xsl:result-document href="{$segmentsxsdoutputdoc}">
            <xsd:schema xmlns="urn:mtf:mil:6040b:niem:mtf:segments" xmlns:ism="urn:us:gov:ic:ism:v2" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:ct="http://release.niem.gov/niem/conformanceTargets/3.0/" xmlns:structures="http://release.niem.gov/niem/structures/3.0/"
                xmlns:term="http://release.niem.gov/niem/localTerminology/3.0/" xmlns:appinfo="http://release.niem.gov/niem/appinfo/3.0/" xmlns:mtfappinfo="urn:mtf:mil:6040b:appinfo"
                xmlns:ddms="http://metadata.dod.mil/mdr/ns/DDMS/2.0/" xmlns:s="urn:mtf:mil:6040b:niem:mtf:sets" targetNamespace="urn:mtf:mil:6040b:niem:mtf:segments"
                ct:conformanceTargets="http://reference.niem.gov/niem/specification/naming-and-design-rules/3.0/#ReferenceSchemaDocument" xml:lang="en-US" elementFormDefault="unqualified"
                attributeFormDefault="unqualified" version="1.0">
                <xsd:import namespace="urn:us:gov:ic:ism:v2" schemaLocation="IC-ISM-v2.xsd"/>
                <xsd:import namespace="http://release.niem.gov/niem/structures/3.0/" schemaLocation="../NIEM/structures.xsd"/>
                <xsd:import namespace="http://release.niem.gov/niem/localTerminology/3.0/" schemaLocation="../NIEM/localTerminology.xsd"/>
                <xsd:import namespace="http://release.niem.gov/niem/appinfo/3.0/" schemaLocation="../NIEM/appinfo.xsd"/>
                <xsd:import namespace="urn:mtf:mil:6040b:appinfo" schemaLocation="../NIEM/mtfappinfo.xsd"/>
                <xsd:import namespace="urn:mtf:mil:6040b:niem:mtf:sets" schemaLocation="NIEM_MTF_Sets.xsd"/>
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:text>Segment structures for MTF Messages</xsl:text>
                    </xsd:documentation>
                </xsd:annotation>
                <xsl:for-each select="$segmentsxsd/xsd:complexType">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:variable name="pre1" select="preceding-sibling::xsd:complexType[@name = $n][1]"/>
                    <xsl:variable name="pre2" select="preceding-sibling::xsd:complexType[@name = $n][2]"/>
                    <xsl:choose>
                        <xsl:when test="$n = $pre1/@name"/>
                        <xsl:when test="deep-equal(., $pre2)"/>
                        <xsl:when test="deep-equal(., $pre2)"/>
                        <xsl:otherwise>
                            <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:for-each select="$segmentsxsd/xsd:element">
                    <xsl:sort select="@name"/>
                    <xsl:sort select="@type"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:variable name="t" select="@type"/>
                    <xsl:variable name="pre1" select="preceding-sibling::xsd:element[@name = $n][1]"/>
                    <xsl:variable name="pre2" select="preceding-sibling::xsd:element[@name = $n][2]"/>
                    <xsl:choose>
                        <xsl:when test="deep-equal(., $pre1)"/>
                        <xsl:when test="deep-equal(., $pre2)"/>
                        <xsl:otherwise>
                            <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsd:schema>
        </xsl:result-document>
        <xsl:result-document href="{$segmentmapsoutput}">
            <Segments>
                <xsl:for-each select="$segmentmaps/*">
                    <xsl:sort select="@mtfname"/>
                    <xsl:copy-of select="." copy-namespaces="no"/>
                </xsl:for-each>
            </Segments>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
