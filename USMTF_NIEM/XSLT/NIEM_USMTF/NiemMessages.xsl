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
    <xsl:variable name="baseline_msgs_xsd" select="document('../../XSD/Baseline_Schema/messages.xsd')/xsd:schema/*"/>

    <xsl:variable name="niem_sets_map" select="document('../../XSD/NIEM_MTF/NIEM_MTF_Setmaps.xml')/*"/>
    <xsl:variable name="niem_segments_map" select="document('../../XSD/NIEM_MTF/NIEM_MTF_Segmentmaps.xml')/*"/>

    <xsl:variable name="message_changes" select="document('../../XSD/Refactor_Changes/MessageChanges.xml')/*"/>
    <xsl:variable name="substGrp_Changes" select="document('../../XSD/Refactor_Changes/SubstitutionGroupChanges.xml')/SubstitionGroups"/>
    <!--Outputs-->
    <xsl:variable name="messagemapsoutput" select="'../../XSD/NIEM_MTF/NIEM_MTF_Messagemaps.xml'"/>
    <xsl:variable name="messagesxsdoutputdoc" select="'../../XSD/NIEM_MTF/NIEM_MTF_Messages.xsd'"/>
    <xsl:variable name="choiceanalysisoutputdoc" select="'../../XSD/Analysis/MessageChoices.xml'"/>

    <!-- MESSAGE XSD MAP-->
    <!-- _______________________________________________________ -->
    <xsl:variable name="messagemaps">
        <xsl:apply-templates select="$baseline_msgs_xsd" mode="messageglobal"/>
    </xsl:variable>
    <xsl:template match="xsd:element" mode="messageglobal">
        <xsl:variable name="annot">
            <xsl:apply-templates select="xsd:annotation"/>
        </xsl:variable>
        <xsl:variable name="appinfovar">
            <xsl:for-each select="$annot/*/xsd:appinfo">
                <xsl:copy-of select="*" copy-namespaces="no"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="mtfnamevar" select="@name"/>
        <xsl:variable name="messagenamevar" select="ancestor::xsd:element[parent::xsd:schema][1]/@name"/>
        <xsl:variable name="n" select="@name"/>
        <xsl:variable name="niemelementnamevar">
            <xsl:choose>
                <xsl:when test="$message_changes/Element[@mtfname = $mtfnamevar][@messagename = $messagenamevar]/@niemelementname">
                    <xsl:value-of select="$message_changes/Element[@mtfname = $mtfnamevar][@messagename = $messagenamevar]/@niemelementname"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$n"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemcomplextype">
            <xsl:value-of select="concat($niemelementnamevar, 'Type')"/>
        </xsl:variable>
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
        <xsl:variable name="mtfid">
            <xsl:value-of select="xsd:complexType/xsd:attribute[@name = 'mtfid'][1]/@fixed"/>
        </xsl:variable>
        <xsl:variable name="niemtypedocvar">
            <xsl:choose>
                <xsl:when test="$message_changes/Element[@mtfname = $mtfnamevar][@niemname = $niemelementnamevar]/@niemtypedoc">
                    <xsl:value-of select="concat('A data type for the', $message_changes/Element[@mtfname = $mtfnamevar][@niemname = $niemelementnamevar]/@niemtypedoc, 'The')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('A data type for the', substring-after($mtfdoc, 'The'))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemelementdocvar">
            <xsl:choose>
                <xsl:when test="$message_changes/Element[@mtfname = $mtfnamevar][@niemname = $niemelementnamevar]/@niemelementdoc">
                    <xsl:value-of select="$message_changes/Element[@mtfname = $mtfnamevar][@niemname = $niemelementnamevar]/@niemelementdoc"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace($niemtypedocvar, 'A data type', 'A data item')"/>
                    <!--<xsl:value-of select="normalize-space($niemtypedoc)"/>-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <Message mtfname="{@name}" mtfid="{$mtfid}" niemcomplextype="{$niemcomplextype}" niemelementname="{$niemelementnamevar}" niemelementdoc="{$niemelementdocvar}" mtfdoc="{$mtfdoc}"
            niemtypedoc="{$niemtypedocvar}">
            <appinfo>
                <xsl:for-each select="$appinfovar/*">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </appinfo>
            <xsl:apply-templates select="*[not(name() = 'xsd:annotation')]"/>
        </Message>
    </xsl:template>
    <xsl:template match="xsd:element">
        <xsl:param name="sbstgrp"/>
        <xsl:variable name="mtfnamevar" select="@name"/>
        <xsl:variable name="mtfroot">
            <xsl:choose>
                <xsl:when test="$message_changes/Element[@mtfname = $mtfnamevar]">
                    <xsl:value-of select="$mtfnamevar"/>
                </xsl:when>
                <xsl:when test="starts-with(@name, '_')">
                    <xsl:value-of select="substring-after(@name, '_')"/>
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
                <xsl:when test="starts-with($mtftype, 's:')">
                    <xsl:copy-of select="$niem_sets_map/*[@mtfname = substring-after($mtftype, 's:')]"/>
                </xsl:when>
                <xsl:when test="$niem_segments_map/*[@mtfname = $mtfnamevar]">
                    <xsl:copy-of select="$niem_segments_map/Segment[@mtfname = $mtfnamevar][1]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="setidvar">
            <xsl:value-of select="$niemmatch/*/appinfo/mtfappinfo:Set/@setid"/>
        </xsl:variable>
        <xsl:variable name="niemelement">
            <xsl:apply-templates select="@name" mode="txt"/>
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
                    <xsl:value-of select="upper-case(substring-before(niemelementname, 'GenText'))"/>
                </xsl:when>
                <xsl:when test="starts-with($mtfnamevar, 'HeadingSet')">
                    <xsl:value-of select="upper-case(substring-before(niemelementname, 'HeadingSet'))"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ffirnfud">
            <xsl:value-of select="xsd:complexType/*//xsd:attribute[@name = 'ffirnFudn']/@fixed"/>
        </xsl:variable>
        <xsl:variable name="seq">
            <xsl:choose>
                <xsl:when test="xsd:annotation/xsd:appinfo/*:InitialSetFormatPosition">
                    <xsl:value-of select="xsd:annotation/xsd:appinfo/*:InitialSetFormatPosition"/>
                </xsl:when>
                <xsl:when test="xsd:annotation/xsd:appinfo/*:SetFormatPositionNumbern">
                    <xsl:value-of select="xsd:annotation/xsd:appinfo/*:SetFormatPositionNumber"/>
                </xsl:when>
                <xsl:when test="xsd:complexType/xsd:complexContent/xsd:extension/xsd:attribute[@name = 'setSeq'][1]/@fixed">
                    <xsl:value-of select="xsd:complexType/xsd:complexContent/xsd:extension/xsd:attribute[@name = 'setSeq'][1]/@fixed"/>
                </xsl:when>
            </xsl:choose>
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
        <xsl:variable name="messagenamevar" select="ancestor::xsd:element[parent::xsd:schema][1]/@name"/>
        <xsl:variable name="niemelementnamevar">
            <xsl:choose>
                <xsl:when test="$substGrp_Changes/Element[@mtfname = $mtfroot][@substitutionGroup = $sbstgrp]/@niemname">
                    <xsl:value-of select="$substGrp_Changes/Element[@mtfname = $mtfroot][@substitutionGroup = $sbstgrp]/@niemname"/>
                </xsl:when>
                <xsl:when test="$message_changes/Element[@mtfname = $mtfroot][@messagename = $messagenamevar]/@niemelementname">
                    <xsl:value-of select="$message_changes/Element[@mtfname = $mtfroot][@messagename = $messagenamevar]/@niemelementname"/>
                </xsl:when>
                <xsl:when test="$message_changes/Element[@mtfname = $mtfnamevar]/@niemelementname">
                    <xsl:value-of select="$message_changes/Element[@mtfname = $mtfnamevar]/@niemelementname"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$niemnamevar"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemelementdocvar">
            <xsl:choose>
                <xsl:when test="$message_changes/Element[@mtfname = $mtfroot][@niemname = '']/@niemtypedoc">
                    <xsl:value-of select="$message_changes/Element[@mtfname = $mtfnamevar][@niemname = '']/@niemtypedoc"/>
                </xsl:when>
                <xsl:when test="$message_changes/Element[@mtfname = $mtfroot][@niemelementname = $niemelementnamevar]/@niemelementdoc">
                    <xsl:value-of select="$message_changes/Element[@mtfname = $mtfnamevar][@niemelementname = $niemelementnamevar]/@niemelementdoc"/>
                </xsl:when>
                <xsl:when test="$message_changes/Element[@mtfname = $mtfroot][@messagename = $messagenamevar]/@niemelementdoc">
                    <xsl:value-of select="$message_changes/Element[@mtfname = $mtfroot][@messagename = $messagenamevar]/@niemelementdoc"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('A data item for the', substring-after($mtfdoc, 'The'))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemtypedocvar">
            <xsl:choose>
                <xsl:when test="$message_changes/Element[@mtfname = $mtfnamevar][@niemname = $niemnamevar]/@niemtypedoc">
                    <xsl:value-of select="$message_changes/Element[@mtfname = $mtfnamevar][@niemname = $niemnamevar]/@niemtypedoc"/>
                </xsl:when>
                <xsl:when test="$niemmatch/*/@niemtypedoc">
                    <xsl:value-of select="$niemmatch/*/@niemtypedoc"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$mtfdoc"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <Element mtfname="{@name}" messagename="{$messagenamevar}" niemelementname="{$niemelementnamevar}" mtfdoc="{$mtfdoc}">
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
            <xsl:if test="string-length($niemmatch/*/@niemcomplextype) &gt; 0">
                <xsl:attribute name="niemtype">
                    <xsl:choose>
                        <xsl:when test="$niemmatch/*/xsd:appinfo/mtfappinfo:Segment">
                            <xsl:value-of select="concat('sg', ':', $niemmatch/*/@niemcomplextype)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$niemmatch/*/@niemcomplextype"/>
                        </xsl:otherwise>
                    </xsl:choose>
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
            <xsl:if test="string-length($seq) &gt; 0">
                <xsl:attribute name="seq">
                    <xsl:value-of select="$seq"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length($setidvar) &gt; 0">
                <xsl:attribute name="identifier">
                    <xsl:value-of select="$setidvar"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length($ffirnfud) &gt; 0">
                <xsl:attribute name="identifier">
                    <xsl:value-of select="$ffirnfud"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="@minOccurs"/>
            <xsl:copy-of select="@maxOccurs"/>
            <appinfo>
                <xsl:for-each select="$appinfovar/*">
                    <xsl:copy>
                        <xsl:if test="string-length($setidvar) &gt; 0">
                            <xsl:attribute name="identifier">
                                <xsl:value-of select="$setidvar"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="string-length($ffirnfud) &gt; 0">
                            <xsl:attribute name="identifier">
                                <xsl:value-of select="$ffirnfud"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:for-each select="@*">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </xsl:copy>
                </xsl:for-each>
            </appinfo>
            <xsl:apply-templates select="*[not(name() = 'xsd:annotation')]"/>
        </Element>
    </xsl:template>
    <xsl:template match="xsd:sequence">
        <Sequence>
            <xsl:apply-templates select="*"/>
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
        <xsl:variable name="msgnamevar">
            <xsl:value-of select="ancestor::xsd:element[parent::xsd:schema][1]/@name"/>
        </xsl:variable>
        <xsl:variable name="segnamevar">
            <xsl:value-of select="ancestor::xsd:element[xsd:annotation/xsd:appinfo/*:SegmentStructureName][1]/@name"/>
        </xsl:variable>
        <xsl:variable name="subname">
            <xsl:choose>
                <xsl:when test="xsd:element[@name = 'ExerciseIdentification']">
                    <xsl:text>ExerciseOperation</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ancestor::xsd:element[@name][1]/@name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="subgrpname">
            <xsl:choose>
                <xsl:when test="starts-with($subname, '_')">
                    <xsl:value-of select="substring-after($subname, '_')"/>
                </xsl:when>
                <xsl:when test="contains($subname, '_')">
                    <xsl:value-of select="substring-before($subname, '_')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$subname"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="msgchoicename">
            <xsl:value-of select="concat($subgrpname, 'Choice')"/>
        </xsl:variable>
        <xsl:variable name="substmatch">
            <xsl:choose>
                <xsl:when test="$substGrp_Changes/Choice[@choicename = $msgchoicename][@segmentname = $segnamevar]">
                    <xsl:copy-of select="$substGrp_Changes/Choice[@choicename = $msgchoicename][@segmentname = $segnamevar][1]"/>
                </xsl:when>
                <xsl:otherwise/>
                <!--<xsl:otherwise>
                    <xsl:copy-of select="$substGrp_Changes/Choice[@choicename = $msgchoicename][@segmentname = ''][1]"/>
                </xsl:otherwise>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="choicenamevar">
            <xsl:choose>
                <xsl:when test="$substmatch/*/@niemname">
                    <xsl:value-of select="$substmatch/*/@niemname"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$msgchoicename"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="substgrpdocvar">
            <xsl:choose>
                <xsl:when test="$subname = 'ExerciseOperation'">
                    <xsl:text>A data concept for a choice of Exercise or Operation context.</xsl:text>
                </xsl:when>
                <xsl:when test="$substmatch/*/@substgrpname">
                    <xsl:value-of select="concat('A data concept for a choice of', substring-after($substmatch/*/@substgrpdoc, 'A choice of'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('A data concept for a choice of ', $msgnamevar, ' values.')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="seq" select="xsd:element[1]//xsd:extension[1]/xsd:attribute[@name = 'setSeq']/@fixed"/>
        <Element choicename="{$choicenamevar}" msgname="{$msgnamevar}" substgrpname="{$choicenamevar}" substgrpdoc="{$substgrpdocvar}">
            <xsl:copy-of select="@minOccurs"/>
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
        <xsl:variable name="n">
            <xsl:choose>
                <xsl:when test="contains(xsd:annotation/xsd:documentation, 'GENTEXT/ACSIGN') and contains(xsd:annotation/xsd:documentation, 'airborne')">
                    <xsl:text>AirborneAcsign</xsl:text>
                </xsl:when>
                <xsl:when test="contains(xsd:annotation/xsd:documentation, 'GENTEXT/ACSIGN') and contains(xsd:annotation/xsd:documentation, 'ground')">
                    <xsl:text>GroundAcsign</xsl:text>
                </xsl:when>
                <xsl:when test="contains(xsd:annotation/xsd:documentation, 'GENTEXT/ACSIGN') and contains(xsd:annotation/xsd:documentation, 'shipborne')">
                    <xsl:text>ShipborneAcsign</xsl:text>
                </xsl:when>
                <xsl:when test="contains(xsd:annotation/xsd:documentation, 'GENTEXT/ARCHITECTURE') and contains(xsd:annotation/xsd:documentation, 'BGDBM')">
                    <xsl:text>BGDBMArchitectureConfigurationAmplification</xsl:text>
                </xsl:when>
                <xsl:when test="starts-with($CCase, '48-')">
                    <xsl:text>FortyeighthourOutlookForecast</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(replace(replace($CCase, '(TAS)', ''), '(mpa)', ''), ' ,/”()-', '')"/>
                </xsl:otherwise>
            </xsl:choose>
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

    <xsl:variable name="messagelements">
        <xsl:for-each select="$messagemaps//Sequence/Element">
            <xsl:sort select="@niemelementname"/>
            <xsl:variable name="n" select="@niemelementname"/>
            <xsl:variable name="segSeq">
                <xsl:value-of select="ancestor::Segment/@segseq"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="@niemelementname">
                    <xsd:element name="{@niemelementname}">
                        <xsl:attribute name="type">
                            <xsl:choose>
                                <xsl:when test="appinfo/mtfappinfo:Segment">
                                    <xsl:value-of select="concat('sg:', @niemtype)"/>
                                </xsl:when>
                                <xsl:when test="starts-with(@mtftype, 's:')">
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
                            <xsl:for-each select="appinfo/*">
                                <xsd:appinfo>
                                    <xsl:copy>
                                        <xsl:copy-of select="@positionName"/>
                                        <!--<xsl:copy-of select="@concept"/>
                                        <xsl:copy-of select="@usage"/>-->
                                    </xsl:copy>
                                </xsd:appinfo>
                            </xsl:for-each>
                        </xsd:annotation>
                    </xsd:element>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="$messagemaps//Element[Choice]">
            <xsl:variable name="substgrp" select="@substgrpname"/>
            <xsl:choose>
                <xsl:when test="$niem_sets_map//*[@substgrpname = $substgrp]"/>
                <xsl:when test="$niem_segments_map//*[@substgrpname = $substgrp]"/>
                <xsl:when test="@substgrpname">
                    <xsd:element name="{@substgrpname}" abstract="true">
                        <xsd:annotation>
                            <xsd:documentation>
                                <xsl:value-of select="@substgrpdoc"/>
                            </xsd:documentation>
                        </xsd:annotation>
                    </xsd:element>
                    <xsl:for-each select="Choice/Element">
                        <xsl:variable name="prefix" select="substring-before(@mtftype, ':')"/>
                        <xsl:variable name="n" select="@niemelementname"/>
                        <xsd:element name="{@niemelementname}" type="{concat($prefix,':',@niemtype)}" substitutionGroup="{$substgrp}" nillable="true">
                            <xsd:annotation>
                                <xsd:documentation>
                                    <xsl:choose>
                                        <xsl:when test="@niemtypedoc">
                                            <xsl:value-of select="@niemtypedoc"/>
                                        </xsl:when>
                                        <xsl:when test="@niemelementdoc">
                                            <xsl:value-of select="@niemelementdoc"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsd:documentation>
                            </xsd:annotation>
                        </xsd:element>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="messagesxsd">
        <xsl:for-each select="$messagemaps/Message">
            <xsl:sort select="@niemcomplextype"/>
            <xsd:complexType name="{@niemcomplextype}">
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:value-of select="@niemtypedoc"/>
                    </xsd:documentation>
                    <xsl:for-each select="appinfo/*">
                        <xsd:appinfo>
                            <xsl:copy-of select="."/>
                        </xsd:appinfo>
                    </xsl:for-each>
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
                                        <xsl:when test="$messagelements/*[@name = $n]">
                                            <xsl:value-of select="$n"/>
                                        </xsl:when>
                                        <xsl:when test="appinfo/*/mtfappinfo:Segment">
                                            <xsl:value-of select="concat('sg:', $n)"/>
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
                                                <xsl:when test="string-length(@substgrpdoc) &gt; 0">
                                                    <xsl:value-of select="@substgrpdoc"/>
                                                </xsl:when>
                                                <xsl:when test="string-length(@niemelementdoc) &gt; 0">
                                                    <xsl:value-of select="@niemelementdoc"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="@niemtypedoc"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsd:documentation>
                                        <xsl:for-each select="appinfo/*">
                                            <xsd:appinfo>
                                                <xsl:copy-of select="."/>
                                                <!--<xsl:copy>
                                                    <xsl:copy-of select="@identifier"/>
                                                    <xsl:copy-of select="@positionName"/>
                                                    <xsl:copy-of select="@position"/>
                                                    <xsl:copy-of select="@concept"/>
                                                    <xsl:copy-of select="@usage"/>
                                                </xsl:copy>-->
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
                                <!--\\-<xsl:copy-of select="@usage"/>
                                <xsl:copy-of select="@concept"/> -->
                            </xsl:copy>
                        </xsd:appinfo>
                    </xsl:for-each>
                </xsd:annotation>
            </xsd:element>
        </xsl:for-each>
        <!--Global Elements-->
        <xsl:copy-of select="$messagelements"/>
    </xsl:variable>


    <!--    OUTPUT RESULT-->
    <!-- _______________________________________________________ -->

    <xsl:template name="main">
        <xsl:result-document href="{$messagesxsdoutputdoc}">
            <xsd:schema xmlns="urn:mtf:mil:6040b:niem:mtf:messages" xmlns:ism="urn:us:gov:ic:ism:v2" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:ct="http://release.niem.gov/niem/conformanceTargets/3.0/" xmlns:structures="http://release.niem.gov/niem/structures/3.0/"
                xmlns:term="http://release.niem.gov/niem/localTerminology/3.0/" xmlns:appinfo="http://release.niem.gov/niem/appinfo/3.0/" xmlns:mtfappinfo="urn:mtf:mil:6040b:appinfo"
                xmlns:ddms="http://metadata.dod.mil/mdr/ns/DDMS/2.0/" xmlns:s="urn:mtf:mil:6040b:niem:mtf:sets" xmlns:sg="urn:mtf:mil:6040b:niem:mtf:segments"
                targetNamespace="urn:mtf:mil:6040b:niem:mtf:messages" ct:conformanceTargets="http://reference.niem.gov/niem/specification/naming-and-design-rules/3.0/#ReferenceSchemaDocument"
                xml:lang="en-US" elementFormDefault="unqualified" attributeFormDefault="unqualified" version="1.0">
                <xsd:import namespace="urn:us:gov:ic:ism:v2" schemaLocation="IC-ISM-v2.xsd"/>
                <xsd:import namespace="http://release.niem.gov/niem/structures/3.0/" schemaLocation="../NIEM/structures.xsd"/>
                <xsd:import namespace="http://release.niem.gov/niem/localTerminology/3.0/" schemaLocation="../NIEM/localTerminology.xsd"/>
                <xsd:import namespace="http://release.niem.gov/niem/appinfo/3.0/" schemaLocation="../NIEM/appinfo.xsd"/>
                <xsd:import namespace="urn:mtf:mil:6040b:appinfo" schemaLocation="../NIEM/mtfappinfo.xsd"/>
                <xsd:import namespace="urn:mtf:mil:6040b:niem:mtf:sets" schemaLocation="NIEM_MTF_Sets.xsd"/>
                <xsd:import namespace="urn:mtf:mil:6040b:niem:mtf:segments" schemaLocation="NIEM_MTF_Segments.xsd"/>
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:text>Message structures for MTF Messages</xsl:text>
                    </xsd:documentation>
                </xsd:annotation>
                <xsl:for-each select="$messagesxsd/xsd:complexType">
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
                <xsl:for-each select="$messagesxsd/xsd:element">
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
        <xsl:result-document href="{$messagemapsoutput}">
            <Messages>
                <xsl:for-each select="$messagemaps/*">
                    <xsl:sort select="@mtfname"/>
                    <xsl:copy-of select="." copy-namespaces="no"/>
                </xsl:for-each>
            </Messages>
        </xsl:result-document>
        <xsl:result-document href="{$choiceanalysisoutputdoc}">
            <Choices>
                <xsl:for-each select="$messagemaps/*//Element[Choice]">
                    <xsl:sort select="@choicename"/>
                    <Choice>
                        <xsl:copy-of select="@choicename"/>
                        <xsl:copy-of select="@substgrpname"/>
                        <xsl:attribute name="segmentname">
                            <xsl:value-of select="ancestor::Segment[1]/@mtfname"/>
                        </xsl:attribute>
                        <xsl:copy-of select="@substgrpdoc"/>
                        <xsl:for-each select="Choice/Element">
                            <xsl:sort select="@mtftype"/>
                            <xsl:copy>
                                <xsl:copy-of select="@mtftype"/>
                                <xsl:copy-of select="@mtfname"/>
                                <xsl:copy-of select="@mtfdoc"/>
                                <xsl:copy-of select="@niemtype"/>
                                <xsl:copy-of select="@niemelementname"/>
                            </xsl:copy>
                        </xsl:for-each>
                    </Choice>
                </xsl:for-each>
            </Choices>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
