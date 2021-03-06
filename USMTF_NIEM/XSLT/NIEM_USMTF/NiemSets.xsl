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
    <xsl:variable name="baseline_sets_xsd" select="document('../../XSD/Baseline_Schema/sets.xsd')"/>
    <xsl:variable name="niem_fields_map" select="document('../../XSD/NIEM_MTF/NIEM_MTF_Fieldmaps.xml')/*"/>
    <xsl:variable name="niem_composites_map" select="document('../../XSD/NIEM_MTF/NIEM_MTF_Compositemaps.xml')/*"/>
    <!--Set deconfliction and annotation changes-->
    <xsl:variable name="set_Changes" select="document('../../XSD/Refactor_Changes/SetChanges.xml')/SetChanges"/>
    <xsl:variable name="substGrp_Changes" select="document('../../XSD/Refactor_Changes/SubstitutionGroupChanges.xml')/SubstitionGroups"/>
    <!--Outputs-->
    <xsl:variable name="setmapsoutput" select="'../../XSD/NIEM_MTF/NIEM_MTF_Setmaps.xml'"/>
    <xsl:variable name="setxsdoutputdoc" select="'../../XSD/NIEM_MTF/NIEM_MTF_Sets.xsd'"/>

    <!-- SET XSD MAP-->
    <!-- _______________________________________________________ -->

    <xsl:variable name="setmaps">
        <xsl:apply-templates select="$baseline_sets_xsd/xsd:schema/xsd:complexType" mode="setglobal"/>
    </xsl:variable>
    <xsl:template match="xsd:schema/xsd:complexType" mode="setglobal">
        <xsl:variable name="annot">
            <xsl:apply-templates select="xsd:annotation"/>
        </xsl:variable>
        <xsl:variable name="mtfname" select="@name"/>
        <xsl:variable name="change" select="$set_Changes/Set[@mtfname = $mtfname]"/>
        <xsl:variable name="n">
            <xsl:apply-templates select="@name" mode="fromtype"/>
        </xsl:variable>
        <xsl:variable name="niemelementnamevar">
            <xsl:choose>
                <xsl:when test="$change/@niemelementname">
                    <xsl:value-of select="$change/@niemelementname"/>
                </xsl:when>
                <!--<xsl:when test="ends-with($n, 'Set')">
                    <xsl:value-of select="$n"/>
                </xsl:when>-->
                <xsl:otherwise>
                    <!--<xsl:value-of select="concat($n, 'Set')"/>-->
                    <xsl:value-of select="$n"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemcomplextypevar">
            <xsl:choose>
                <xsl:when test="$change/@niemcomplextype">
                    <xsl:value-of select="$change/@niemcomplextype"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($niemelementnamevar, 'Type')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mtfdocvar">
            <xsl:value-of select="$annot/*/xsd:documentation"/>
        </xsl:variable>
        <xsl:variable name="niemtypedocvar">
            <xsl:choose>
                <xsl:when test="$change/@niemtypedoc">
                    <xsl:value-of select="concat('A data type for the',substring($change/@niemtypedoc,4))"/>
                </xsl:when>
                <xsl:when test="starts-with($mtfdocvar,'A data ')">
                    <xsl:value-of select="$mtfdocvar"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('A data type for the',substring($mtfdocvar,4))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemelementdocvar">
            <xsl:choose>
                <xsl:when test="starts-with($niemtypedocvar,'A data ')">
                    <xsl:value-of select="$niemtypedocvar"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace($niemtypedocvar, 'A data type', 'A data item')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="appinfovar">
            <xsl:for-each select="$annot/*/xsd:appinfo">
                <xsl:copy-of select="*:Set" copy-namespaces="no"/>
            </xsl:for-each>
        </xsl:variable>
        <Set mtfname="{@name}" niemcomplextype="{$niemcomplextypevar}" niemelementname="{$niemelementnamevar}" niemelementdoc="{$niemelementdocvar}" mtfdoc="{$mtfdocvar}"
            niemtypedoc="{$niemtypedocvar}">
            <appinfo>
                <xsl:for-each select="$appinfovar">
                    <xsl:copy-of select="." copy-namespaces="no"/>
                </xsl:for-each>
            </appinfo>
            <xsl:apply-templates select="*[not(name() = 'xsd:annotation')]"/>
        </Set>
    </xsl:template>
    <xsl:template match="xsd:element">
        <xsl:param name="sbstgrp"/>
        <xsl:variable name="n">
            <xsl:apply-templates select="@name" mode="fromtype"/>
        </xsl:variable>
        <xsl:variable name="mtfnamevar">
            <xsl:apply-templates select="@name" mode="txt"/>
        </xsl:variable>
        <xsl:variable name="settypevar">
            <xsl:apply-templates select="ancestor::xsd:complexType[@name][1]/@name" mode="txt"/>
        </xsl:variable>
        <xsl:variable name="mtftypevar">
            <xsl:value-of select="xsd:complexType/*/xsd:extension/@base"/>
        </xsl:variable>
        <xsl:variable name="ffirnfud">
            <xsl:value-of select="xsd:complexType/*//xsd:attribute[@name = 'ffirnFudn']/@fixed"/>
        </xsl:variable>
        <xsl:variable name="ffirnvar">
            <xsl:value-of select="substring-before(substring-after($ffirnfud, 'FF'), '-')"/>
        </xsl:variable>
        <xsl:variable name="fudvar">
            <xsl:value-of select="substring-after(substring-after($ffirnfud, 'FF'), '-')"/>
        </xsl:variable>
        <xsl:variable name="niemmatch">
            <xsl:choose>
                <xsl:when test="starts-with($mtftypevar, 'f:')">
                    <xsl:choose>
                        <xsl:when test="$niem_fields_map/*[@mtfname = substring-after($mtftypevar, 'f:')]">
                            <xsl:copy-of select="$niem_fields_map/*[@mtfname = substring-after($mtftypevar, 'f:')]"/>
                        </xsl:when>
                        <xsl:when test="$niem_fields_map/*[@niemcomplextype = substring-after($mtftypevar, 'f:')]">
                            <xsl:copy-of select="$niem_fields_map/*[@niemcomplextype = substring-after($mtftypevar, 'f:')]"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="starts-with($mtftypevar, 'c:')">
                    <xsl:copy-of select="$niem_composites_map/*[@mtfname = substring-after($mtftypevar, 'c:')]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$baseline_sets_xsd/xsd:schema/xsd:complexType[@name = $mtftypevar]" mode="setglobal"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="niemtypedocvar">
            <xsl:value-of select="$niemmatch/*/@niemtypedoc"/>
        </xsl:variable>
        <xsl:variable name="niemtypevar">
            <xsl:value-of select="$niemmatch/*/@niemcomplextype"/>
        </xsl:variable>
        <xsl:variable name="setnamevar">
            <xsl:value-of select="substring-before($settypevar, 'Type')"/>
        </xsl:variable>
        <xsl:variable name="niemelementnamevar">
            <xsl:choose>
                <xsl:when test="$set_Changes/Element[@mtfname = $mtfnamevar][@mtftype = $mtftypevar]/@niemelementname">
                    <xsl:value-of select="$set_Changes/Element[@mtfname = $mtfnamevar][@mtftype = $mtftypevar]/@niemelementname"/>
                </xsl:when>
                <xsl:when test="string-length($sbstgrp) &gt; 0">
                    <xsl:choose>
                        <xsl:when test="$substGrp_Changes/Element[@mtfname = $mtfnamevar][@substitutionGroup = $sbstgrp]/@niemname">
                            <xsl:value-of select="$substGrp_Changes/Element[@mtfname = $mtfnamevar][@substitutionGroup = $sbstgrp]/@niemname"/>
                        </xsl:when>
                        <xsl:when test="$set_Changes/Element[@mtfname = $mtfnamevar][@setname = $setnamevar]/@niemelementname">
                            <xsl:value-of select="$set_Changes/Element[@mtfname = $mtfnamevar][@setname = $setnamevar]/@niemelementname"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$mtfnamevar"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$mtfnamevar"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="seq">
            <xsl:choose>
                <xsl:when test="xsd:complexType/xsd:attribute[@name = 'ffSeq']">
                    <xsl:value-of select="xsd:complexType/xsd:attribute[@name = 'ffSeq'][1]/@fixed"/>
                </xsl:when>
                <xsl:when test="xsd:complexType/xsd:simpleContent/xsd:extension/xsd:attribute[@name = 'ffSeq']">
                    <xsl:value-of select="xsd:complexType/xsd:simpleContent/xsd:extension/xsd:attribute[@name = 'ffSeq'][1]/@fixed"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="annot">
            <xsl:apply-templates select="xsd:annotation"/>
        </xsl:variable>
        <xsl:variable name="typeannot">
            <xsl:apply-templates select="xsd:complexType/*/xsd:extension/xsd:annotation"/>
        </xsl:variable>
        <xsl:variable name="mtfdoc">
            <xsl:value-of select="$annot/*/xsd:documentation"/>
        </xsl:variable>
        <xsl:variable name="mtftypedoc">
            <xsl:value-of select="$typeannot/*/xsd:documentation"/>
        </xsl:variable>
        <xsl:variable name="niemelementdocvar">
            <xsl:choose>
                <xsl:when test="$set_Changes/Element[@mtfname = $mtfnamevar][@mtftype = $mtftypevar]/@niemelementdoc">
                    <xsl:value-of select="$set_Changes/Element[@mtfname = $mtfnamevar][@mtftype = $mtftypevar]/@niemelementdoc"/>
                </xsl:when>
                <xsl:when test="$annot/*/xsd:documentation and contains($niemelementnamevar, 'Name')">
                    <xsl:value-of select="replace($mtfdoc, 'A data type ', 'A data item for the name ')"/>
                </xsl:when>
                <xsl:when test="$annot/*/xsd:documentation">
                    <xsl:value-of select="replace($mtfdoc, 'A data type ', 'A data item ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace($niemmatch/*/@niemtypedoc, 'A data type for the', 'A data item for the')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="appinfovar">
            <xsl:for-each select="$annot/*/xsd:appinfo">
                <xsl:copy-of select="*" copy-namespaces="no"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="typeappinfo">
            <xsl:for-each select="$typeannot/*/xsd:appinfo">
                <xsl:copy-of select="*:Field" copy-namespaces="no"/>
            </xsl:for-each>
        </xsl:variable>
        <Element mtfname="{@name}" mtftype="{$mtftypevar}" setname="{$setnamevar}" niemelementname="{$niemelementnamevar}" niemtype="{$niemtypevar}" mtfdoc="{$mtfdoc}" mtftypedoc="{$mtftypedoc}"
            niemtypedoc="{$niemtypedocvar}" niemelementdoc="{$niemelementdocvar}" seq="{$seq}" ffirn="{$ffirnvar}" fud="{$fudvar}">
            <xsl:if test="string-length($sbstgrp) &gt; 0">
                <xsl:attribute name="substitutiongroup">
                    <xsl:value-of select="$sbstgrp"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:for-each select="@*[not(name() = 'name')]">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <appinfo>
                <xsl:for-each select="$appinfovar">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </appinfo>
            <typeappinfo>
                <xsl:for-each select="$typeappinfo">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </typeappinfo>
            <xsl:apply-templates select="*[not(name() = 'xsd:annotation')]"/>
        </Element>
    </xsl:template>
    <!--  Choice / Substitution Groups Map -->
    <xsl:template match="xsd:element[xsd:complexType/xsd:choice]">
        <xsl:variable name="n" select="@name"/>
        <xsl:variable name="annot">
            <xsl:apply-templates select="xsd:annotation"/>
        </xsl:variable>
        <xsl:variable name="typeannot">
            <xsl:apply-templates select="xsd:element[1]/*/xsd:extension/xsd:annotation"/>
        </xsl:variable>
        <xsl:variable name="mtftypedoc">
            <xsl:value-of select="$typeannot/xsd:documentation"/>
        </xsl:variable>
        <xsl:variable name="seq">
            <xsl:choose>
                <xsl:when test="xsd:complexType/xsd:attribute[@name = 'ffSeq']">
                    <xsl:value-of select="xsd:complexType/xsd:attribute[@name = 'ffSeq'][1]/@fixed"/>
                </xsl:when>
                <xsl:when test="xsd:complexType/xsd:simpleContent/xsd:extension/xsd:attribute[@name = 'ffSeq']">
                    <xsl:value-of select="xsd:complexType/xsd:simpleContent/xsd:extension/xsd:attribute[@name = 'ffSeq'][1]/@fixed"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="appinfovar">
            <xsl:for-each select="$annot/*/xsd:appinfo">
                <xsl:copy-of select="*:Field" copy-namespaces="no"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="setnamevar">
            <xsl:value-of select="ancestor::xsd:complexType[@name]/@name"/>
        </xsl:variable>
        <xsl:variable name="substgrpname">
            <xsl:choose>
                <xsl:when test="string-length($substGrp_Changes/Choice[@mtfname = $n][@setname = $setnamevar]/@niemname) &gt; 0">
                    <xsl:value-of select="$substGrp_Changes/Choice[@mtfname = $n][@setname = $setnamevar]/@niemname"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($n, 'Choice')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--<xsl:variable name="substgrpchg">
            <xsl:choose>
                <xsl:when test="$substGrp_Changes/Choice[@mtfname = $n][@setname = $setnamevar]">
                    <xsl:copy-of select="$substGrp_Changes/Choice[@mtfname = $n][@setname = $setnamevar][1]"/>
                </xsl:when>
                <xsl:when test="$substGrp_Changes/Choice[@mtfname = $n][@setname = '']">
                    <xsl:copy-of select="$substGrp_Changes/Choice[@mtfname = $n][@setname = ''][1]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="substgrpchgdoc">
            <xsl:choose>
                <xsl:when test="string-length($substgrpchg/*/@concept) &gt; 0">
                    <xsl:value-of select="normalize-space($substgrpchg/*/@concept)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>-->
        <xsl:variable name="substgrpdoc">
            <xsl:choose>
                <xsl:when test="$substGrp_Changes/Choice[@mtfname = $n][@setname = $setnamevar]">
                    <xsl:value-of select="$substGrp_Changes/Choice[@mtfname = $n][@setname = $setnamevar][1]/@concept"/>
                </xsl:when>
                <xsl:when test="$substGrp_Changes/Choice[@mtfname = $n][@setname = '']">
                    <xsl:value-of select="$substGrp_Changes/Choice[@mtfname = $n][@setname = ''][1]/@concept"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="splitname">
                        <xsl:call-template name="breakIntoWords">
                            <xsl:with-param name="string" select="$n"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="concat('A data concept for a substitution group for ', lower-case($splitname))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="substgrpniemdoc">
            <xsl:choose>
                <xsl:when test="starts-with($substgrpdoc, 'A data concept for')">
                    <xsl:value-of select="$substgrpdoc"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('A data concept for a substitution group for ', lower-case($substgrpdoc))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <Element mtfname="{@name}" substgrpname="{$substgrpname}" setname="{$setnamevar}" mtftypedoc="{$mtftypedoc}" substgrpdoc="{$substgrpniemdoc}" seq="{$seq}">
            <xsl:for-each select="@*[not(name() = 'name')]">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <appinfo>
                <xsl:for-each select="$appinfovar">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </appinfo>
            <Choice name="{$substgrpname}">
                <xsl:apply-templates select="xsd:complexType/xsd:choice/xsd:element">
                    <xsl:with-param name="sbstgrp">
                        <xsl:value-of select="$substgrpname"/>
                    </xsl:with-param>
                </xsl:apply-templates>
            </Choice>
        </Element>
    </xsl:template>
    <xsl:template match="xsd:element[@name = 'GroupOfFields']">
        <Sequence name="GroupOfFields">
            <xsl:for-each select="@*">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="xsd:complexType/xsd:sequence/*"/>
        </Sequence>
    </xsl:template>
    <xsl:template match="xsd:choice">
        <Choice>
            <xsl:apply-templates select="*"/>
        </Choice>
    </xsl:template>
    <xsl:template match="xsd:sequence[xsd:element[1][@name = 'GroupOfFields']][not(xsd:element[not(@name = 'GroupOfFields')])]">
        <xsl:apply-templates select="*"/>
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

    <!-- XSD GENERATION-->
    <!-- _______________________________________________________ -->

    <xsl:variable name="setfields">
        <xsl:for-each select="$setmaps//Sequence[@name = 'GroupOfFields']">
            <xsl:variable name="setname">
                <!--<xsl:value-of select="substring-before(ancestor::Set/@niemelementname, 'Set')"/>-->
                <xsl:value-of select="ancestor::Set/@niemelementname"/>
            </xsl:variable>
            <xsl:variable name="setdocname">
                <xsl:value-of select="ancestor::Set/appinfo/mtfappinfo:Set/@name"/>
            </xsl:variable>
            <xsl:variable name="fielddocname">
                <xsl:value-of select="Element[1]/appinfo/mtfappinfo:Field/@positionName"/>
            </xsl:variable>
            <xsl:variable name="fgname">
                <xsl:choose>
                    <xsl:when test="exists(Element[1]/@niemelementname) and count(Element) = 1">
                        <xsl:value-of select="concat(Element[1]/@niemelementname, 'FieldGroup')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($setname, 'FieldGroup')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="doc">
                <xsl:choose>
                    <xsl:when test="exists(Element[1]/@niemelementname) and count(Element) = 1">
                        <xsl:value-of select="Element[1]/@niemtypedoc"/>
                    </xsl:when>
                    <xsl:when test="count(Element) = 1">
                        <xsl:value-of select="concat($fielddocname, ' FIELD GROUP')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($setdocname, ' FIELD GROUP')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="datadefdoc">
                <xsl:choose>
                    <xsl:when test="starts-with($doc, 'A data type')">
                        <xsl:value-of select="$doc"/>
                    </xsl:when>
                    <xsl:when test="starts-with($doc, 'A ')">
                        <xsl:value-of select="concat('A ', substring(lower-case($doc), 1))"/>
                    </xsl:when>
                    <xsl:when test="starts-with($doc, 'An ')">
                        <xsl:value-of select="concat('A ', substring(lower-case($doc), 1))"/>
                    </xsl:when>
                    <xsl:when test="contains('AEIOU', substring($doc, 0, 1))">
                        <xsl:value-of select="concat('An ', lower-case($doc))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('A ', lower-case($doc))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsd:element name="{$fgname}" type="{concat($fgname,'Type')}" nillable="true">
                <!--<xsl:copy-of select="@minOccurs"/>
                        <xsl:copy-of select="@maxOccurs"/>-->
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:value-of select="$datadefdoc"/>
                    </xsd:documentation>
                </xsd:annotation>
            </xsd:element>
            <xsd:complexType name="{concat($fgname,'Type')}">
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:value-of select="concat('A data type for ', lower-case($datadefdoc))"/>
                    </xsd:documentation>
                </xsd:annotation>
                <xsd:complexContent>
                    <xsd:extension base="structures:ObjectType">
                        <xsd:sequence>
                            <xsl:for-each select="Element">
                                <xsl:variable name="refname">
                                    <xsl:choose>
                                        <xsl:when test="@substgrpname">
                                            <xsl:value-of select="@substgrpname"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@niemelementname"/>
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
                                                <xsl:copy-of select="."/>
                                            </xsd:appinfo>
                                        </xsl:for-each>
                                    </xsd:annotation>
                                </xsd:element>
                            </xsl:for-each>
                            <xsd:element ref="{concat($fgname,'AugmentationPoint')}" minOccurs="0" maxOccurs="unbounded"/>
                        </xsd:sequence>
                    </xsd:extension>
                </xsd:complexContent>
            </xsd:complexType>
            <xsd:element name="{concat($fgname,'AugmentationPoint')}" abstract="true">
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:value-of select="concat('An augmentation point for ', lower-case($datadefdoc))"/>
                    </xsd:documentation>
                </xsd:annotation>
            </xsd:element>
        </xsl:for-each>
        <xsl:for-each select="$setmaps//Sequence/Element">
            <xsl:sort select="@niemelementname"/>
            <xsl:variable name="n" select="@niemelementname"/>
            <xsl:choose>
                <!--<xsl:when test="$niem_fields_map/*/@niemelementname = $n"/>
                <xsl:when test="$niem_composites_map/*/@niemelementname = $n"/>-->
                <xsl:when test="@niemelementname">
                    <xsd:element name="{@niemelementname}">
                        <xsl:attribute name="type">
                            <xsl:choose>
                                <xsl:when test="contains(@mtftype, ':')">
                                    <xsl:value-of select="concat(substring-before(@mtftype, ':'), ':', @niemtype)"/>
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
                                    <xsl:when test="string-length(@substgrpdoc) &gt; 0">
                                        <xsl:value-of select="@substgrpdoc"/>
                                    </xsl:when>
                                    <xsl:when test="string-length(@niemelementdoc) &gt; 0">
                                        <xsl:value-of select="@niemelementdoc"/>
                                    </xsl:when>
                                    <xsl:when test="string-length(@niemtypedoc) &gt; 0">
                                        <xsl:value-of select="@niemtypedoc"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@mtfdoc"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsd:documentation>
                            <xsl:for-each select="appinfo/*">
                                <xsd:appinfo>
                                    <xsl:copy-of select="."/>
                                </xsd:appinfo>
                            </xsl:for-each>
                        </xsd:annotation>
                    </xsd:element>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="setsxsd">
        <xsl:for-each select="$setmaps/Set">
            <xsl:sort select="@niemcomplextype"/>
            <xsl:variable name="setname">
                <!--<xsl:value-of select="substring-before(@niemelementname, 'Set')"/>-->
                <xsl:value-of select="@niemelementname"/>
            </xsl:variable>
            <xsl:variable name="basetype">
                <xsl:choose>
                    <xsl:when test="@mtfname = 'SetBaseType'">
                        <xsl:text>structures:ObjectType</xsl:text>
                    </xsl:when>
                    <xsl:when test="@mtfname = 'OperationIdentificationDataType'">
                        <xsl:text>structures:ObjectType</xsl:text>
                    </xsl:when>
                    <xsl:when test="@mtfname = 'ExerciseIdentificationType'">
                        <xsl:text>structures:ObjectType</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>SetBaseType</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
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
                    <xsd:extension base="{$basetype}">
                        <xsd:sequence>
                            <xsl:for-each select="*:Sequence/*">
                                <xsl:variable name="refname">
                                    <xsl:choose>
                                        <xsl:when test="@name = 'GroupOfFields'">
                                            <xsl:choose>
                                                <xsl:when test="count(Element) = 1">
                                                    <xsl:choose>
                                                        <xsl:when test="string-length(Element/@substgrpname) &gt; 0">
                                                            <xsl:value-of select="Element/@substgrpname"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="Element/@niemelementname"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat($setname, 'FieldGroup')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:when test="@substgrpname">
                                            <xsl:value-of select="@substgrpname"/>
                                        </xsl:when>
                                        <!--<xsl:when test="contains(@mtftype, ':')">
                                            <xsl:value-of select="concat(substring-before(@mtftype, ':'), ':', @niemelementname)"/>
                                        </xsl:when>-->
                                        <xsl:otherwise>
                                            <xsl:value-of select="@niemelementname"/>
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
                                                <xsl:when test="string-length(Element[1]/@substgrpdoc) &gt; 0">
                                                    <xsl:value-of select="Element[1]/@substgrpdoc"/>
                                                </xsl:when>
                                                <xsl:when test="string-length(@niemelementdoc) &gt; 0">
                                                    <xsl:value-of select="@niemelementdoc"/>
                                                </xsl:when>
                                                <xsl:when test="string-length(Element[1]/@niemelementdoc) &gt; 0">
                                                    <xsl:value-of select="Element[1]/@niemelementdoc"/>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsd:documentation>
                                        <xsl:for-each select="appinfo/*">
                                            <xsd:appinfo>
                                                <xsl:copy-of select="."/>
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
            <xsl:choose>
                <xsl:when test="@niemelementname = 'SetBase'"/>
                <xsl:when test="@niemcomplextype">
                    <xsd:element name="{@niemelementname}" type="{@niemcomplextype}" nillable="true">
                        <xsd:annotation>
                            <xsd:documentation>
                                <xsl:choose>
                                    <xsl:when test="string-length(@substgrpdoc) &gt; 0">
                                        <xsl:value-of select="@substgrpdoc"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@niemelementdoc"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsd:documentation>
                        </xsd:annotation>
                    </xsd:element>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <!--Global Set Elements-->
        <xsl:copy-of select="$setfields"/>
        <!--Set Elements with Choice to Substitution Groups-->
        <xsl:for-each select="$setmaps//Element[Choice]">
            <xsl:variable name="substgrp" select="@substgrpname"/>
            <xsd:element name="{@substgrpname}" abstract="true">
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:value-of select="@substgrpdoc"/>
                    </xsd:documentation>
                </xsd:annotation>
            </xsd:element>
            <xsl:for-each select="Choice/Element">
                <xsl:variable name="n" select="@niemelementname"/>
                <xsl:choose>
                    <xsl:when test="@niemelementname != 'ReferenceTimeOfPublication'"/>
                    <xsl:when test="$niem_fields_map/*/@niemelementname = $n"/>
                    <xsl:when test="$niem_composites_map/*/@niemelementname = $n"/>
                    <xsl:otherwise>
                        <xsl:variable name="prefix" select="substring-before(@mtftype, ':')"/>
                        <xsd:element name="{@niemelementname}" type="{concat($prefix,':',@niemtype)}" substitutionGroup="{$substgrp}" nillable="true">
                            <!--<xsd:element name="{@niemelementname}" type="{@niemtype}" substitutionGroup="{$substgrp}" nillable="true">-->
                            <xsd:annotation>
                                <xsd:documentation>
                                    <xsl:choose>
                                        <xsl:when test="string-length(@substgrpdoc) &gt; 0">
                                            <xsl:value-of select="@substgrpdoc"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@niemelementdoc"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsd:documentation>
                            </xsd:annotation>
                        </xsd:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>

    <!-- _______________________________________________________ -->
    <!--    OUTPUT RESULT-->
    <xsl:template name="main">
        <xsl:result-document href="{$setxsdoutputdoc}">
            <xsd:schema xmlns="urn:mtf:mil:6040b:niem:mtf:sets" 
                xmlns:ism="urn:us:gov:ic:ism:v2" 
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:ct="http://release.niem.gov/niem/conformanceTargets/3.0/" 
                xmlns:structures="http://release.niem.gov/niem/structures/3.0/"
                xmlns:term="http://release.niem.gov/niem/localTerminology/3.0/" 
                xmlns:appinfo="http://release.niem.gov/niem/appinfo/3.0/" 
                xmlns:mtfappinfo="urn:mtf:mil:6040b:appinfo"
                xmlns:ddms="http://metadata.dod.mil/mdr/ns/DDMS/2.0/" 
                xmlns:f="urn:mtf:mil:6040b:niem:mtf:fields" 
                xmlns:c="urn:mtf:mil:6040b:niem:mtf:composites" 
                targetNamespace="urn:mtf:mil:6040b:niem:mtf:sets"
                ct:conformanceTargets="http://reference.niem.gov/niem/specification/naming-and-design-rules/3.0/#ReferenceSchemaDocument" 
                xml:lang="en-US" elementFormDefault="unqualified"
                attributeFormDefault="unqualified" version="1.0">
                <xsd:import namespace="urn:us:gov:ic:ism:v2" schemaLocation="IC-ISM-v2.xsd"/>
                <xsd:import namespace="http://release.niem.gov/niem/structures/3.0/" schemaLocation="../NIEM/structures.xsd"/>
                <xsd:import namespace="http://release.niem.gov/niem/localTerminology/3.0/" schemaLocation="../NIEM/localTerminology.xsd"/>
                <xsd:import namespace="http://release.niem.gov/niem/appinfo/3.0/" schemaLocation="../NIEM/appinfo.xsd"/>
                <xsd:import namespace="urn:mtf:mil:6040b:appinfo" schemaLocation="../NIEM/mtfappinfo.xsd"/>
                <xsd:import namespace="urn:mtf:mil:6040b:niem:mtf:fields" schemaLocation="NIEM_MTF_Fields.xsd"/>
                <xsd:import namespace="urn:mtf:mil:6040b:niem:mtf:composites" schemaLocation="NIEM_MTF_Composites.xsd"/>
                <xsd:annotation>
                    <xsd:documentation>
                        <xsl:text>Set structures for MTF Messages</xsl:text>
                    </xsd:documentation>
                </xsd:annotation>
                <xsl:for-each select="$setsxsd/xsd:complexType">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:if test="not(preceding-sibling::xsd:complexType/@name = $n)">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="$setsxsd/xsd:element">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:variable name="t" select="@type"/>
                    <xsl:variable name="pre1" select="preceding-sibling::xsd:element[@name = $n][1]"/>
                    <xsl:variable name="pre2" select="preceding-sibling::xsd:element[@name = $n][2]"/>
                    <xsl:variable name="pre3" select="preceding-sibling::xsd:element[@name = $n][3]"/>
                    <xsl:choose>
                        <xsl:when test="deep-equal(., $pre1)"/>
                        <xsl:when test="deep-equal(., $pre2)"/>
                        <xsl:when test="deep-equal(., $pre3)"/>
                        <xsl:when test="preceding-sibling::xsd:element[@name = $n] and preceding-sibling::xsd:element[@type = $t]"/>
                        <xsl:otherwise>
                            <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsd:schema>
        </xsl:result-document>
        <xsl:result-document href="{$setmapsoutput}">
            <Sets>
                <xsl:for-each select="$setmaps/*">
                    <xsl:sort select="@mtfname"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </Sets>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
