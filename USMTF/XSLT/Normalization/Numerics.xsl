<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsd" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <!--Baseline xsd:simpleTypes-->
    <xsl:variable name="integers_xsd"
        select="document('../../XSD/Baseline_Schema/fields.xsd')/xsd:schema/xsd:simpleType[xsd:restriction[@base = 'xsd:integer']]"/>
    <xsl:variable name="decimals_xsd"
        select="document('../../XSD/Baseline_Schema/fields.xsd')/xsd:schema/xsd:simpleType[xsd:restriction[@base = 'xsd:decimal']]"/>
    <!--Normalized Types-->
    <xsl:variable name="integerSimpleTypes"
        select="document('../../XSD/Normalized/NormalizedSimpleTypes.xsd')/xsd:schema/xsd:simpleType[xsd:restriction[@base = 'xsd:integer']]"/>
    <xsl:variable name="decimalSimpleTypes"
        select="document('../../XSD/Normalized/NormalizedSimpleTypes.xsd')/xsd:schema/xsd:simpleType[xsd:restriction[@base = 'xsd:decimal']]"/>
    <!--Output-->
    <xsl:variable name="integersoutputdoc" select="'../../XSD/Normalized/Integers.xsd'"/>
    <xsl:variable name="decimalsoutputdoc" select="'../../XSD/Normalized/Decimals.xsd'"/>

    <xsl:variable name="integers">
        <xsl:apply-templates select="$integers_xsd" mode="int"/>
    </xsl:variable>

    <xsl:variable name="decimals">
        <xsl:apply-templates select="$decimals_xsd" mode="dec"/>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:result-document href="{$integersoutputdoc}">
            <xsd:schema xmlns="urn:mtf:mil:6040b:fields"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                targetNamespace="urn:mtf:mil:6040b:fields" xml:lang="en-US"
                elementFormDefault="unqualified" attributeFormDefault="unqualified">
                <xsl:for-each select="$integerSimpleTypes">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="$integers/*">
                    <xsl:sort select="@name"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsd:schema>
        </xsl:result-document>
        <xsl:result-document href="{$decimalsoutputdoc}">
            <xsd:schema xmlns="urn:mtf:mil:6040b:fields"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                targetNamespace="urn:mtf:mil:6040b:fields" xml:lang="en-US"
                elementFormDefault="unqualified" attributeFormDefault="unqualified">
                <xsl:for-each select="$decimalSimpleTypes">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="$decimals/*">
                    <xsl:sort select="@name"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsd:schema>
        </xsl:result-document>
    </xsl:template>

    <!-- ******************** Integer Types ******************** -->
    <xsl:template match="xsd:simpleType" mode="int">
        <xsl:variable name="nm">
            <xsl:value-of select="substring(@name, 0, string-length(@name) - 3)"/>
        </xsl:variable>
        <xsl:variable name="min" select="xsd:restriction/xsd:minInclusive/@value"/>
        <xsl:variable name="max" select="xsd:restriction/xsd:maxInclusive/@value"/>
        <xsl:element name="xsd:element">
            <xsl:attribute name="name">
                <xsl:value-of select="$nm"/>
            </xsl:attribute>
            <xsl:apply-templates select="xsd:annotation"/>
            <xsd:simpleType>
                <xsl:element name="xsd:restriction">
                    <xsl:attribute name="base">
                        <xsl:text>xsd:integer</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="xsd:restriction/xsd:minInclusive" copy-namespaces="no"/>
                    <xsl:copy-of select="xsd:restriction/xsd:maxInclusive" copy-namespaces="no"/>
                    <xsl:copy-of select="xsd:restriction/xsd:pattern" copy-namespaces="no"/>
                </xsl:element>
            </xsd:simpleType>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="text()"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:copy-of select="normalize-space(.)"/>
    </xsl:template>

    <!-- ******************** Decimal Types ******************** -->
    <xsl:template match="xsd:simpleType" mode="dec">
        <xsl:variable name="nm">
            <xsl:value-of select="substring(@name, 0, string-length(@name) - 3)"/>
        </xsl:variable>
        <xsl:variable name="min" select="xsd:restriction/xsd:minInclusive/@value"/>
        <xsl:variable name="max" select="xsd:restriction/xsd:maxInclusive/@value"/>
        <xsl:variable name="length">
            <xsl:value-of select="xsd:restriction/xsd:length"/>
        </xsl:variable>
        <xsl:variable name="minlen">
            <xsl:value-of select="xsd:annotation/xsd:appinfo/*:MinimumLength"/>
        </xsl:variable>
        <xsl:variable name="maxlen">
            <xsl:value-of select="xsd:annotation/xsd:appinfo/*:MaximumLength"/>
        </xsl:variable>
        <xsl:variable name="mindec">
            <xsl:value-of select="xsd:annotation/xsd:appinfo/*:MinimumDecimalPlaces"/>
        </xsl:variable>
        <xsl:variable name="maxdec">
            <xsl:value-of select="xsd:annotation/xsd:appinfo/*:MaximumDecimalPlaces"/>
        </xsl:variable>
        <xsl:variable name="fractionDigits">
            <xsl:call-template name="FindMaxDecimals">
                <xsl:with-param name="value1">
                    <xsl:value-of select="$min"/>
                </xsl:with-param>
                <xsl:with-param name="value2">
                    <xsl:value-of select="$max"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="totalDigitCount">
            <xsl:call-template name="FindTotalDigitCount">
                <xsl:with-param name="value1">
                    <xsl:value-of select="$min"/>
                </xsl:with-param>
                <xsl:with-param name="value2">
                    <xsl:value-of select="$max"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="xsd:element">
            <xsl:attribute name="name">
                <xsl:value-of select="$nm"/>
            </xsl:attribute>
            <xsl:apply-templates select="xsd:annotation"/>
            <xsd:simpleType>
                <xsl:element name="xsd:restriction">
                    <xsl:attribute name="base">
                        <xsl:text>xsd:decimal</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="xsd:restriction/xsd:minInclusive" copy-namespaces="no"/>
                    <xsl:copy-of select="xsd:restriction/xsd:maxInclusive" copy-namespaces="no"/>
                    <xsl:element name="xsd:fractionDigits">
                        <xsl:attribute name="value">
                            <xsl:value-of select="$fractionDigits"/>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="xsd:totalDigits">
                        <xsl:attribute name="value">
                            <xsl:value-of select="number($maxlen) - 1"/>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:copy-of select="xsd:restriction/xsd:pattern" copy-namespaces="no"/>
                </xsl:element>

            </xsd:simpleType>
        </xsl:element>
    </xsl:template>

    <!-- Determine how many placeholders are represented in the decimal value -->
    <xsl:template name="FindMaxDecimals">
        <xsl:param name="value1"/>
        <xsl:param name="value2"/>
        <xsl:choose>
            <xsl:when test="contains($value1, '.') and contains($value2, '.')">
                <xsl:if
                    test="
                        (string-length(substring-after($value1, '.')) >
                        string-length(substring-after($value2, '.')))">
                    <xsl:value-of select="string-length(substring-after($value1, '.'))"/>
                </xsl:if>
                <xsl:if
                    test="
                        (string-length(substring-after($value1, '.')) &lt;
                        string-length(substring-after($value2, '.')))">
                    <xsl:value-of select="string-length(substring-after($value2, '.'))"/>
                </xsl:if>
                <xsl:if
                    test="
                        (string-length(substring-after($value1, '.')) =
                        string-length(substring-after($value2, '.')))">
                    <xsl:value-of select="string-length(substring-after($value1, '.'))"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($value1, '.')">
                <xsl:value-of select="string-length(substring-after($value1, '.'))"/>
            </xsl:when>
            <xsl:when test="contains($value2, '.')">
                <xsl:value-of select="string-length(substring-after($value2, '.'))"/>
            </xsl:when>
            <xsl:when test="(not(contains($value1, '.')) and not(contains($value2, '.')))">
                <xsl:if test="string-length($value1) > string-length($value2)">
                    <xsl:value-of select="string-length(substring-after($value1, '.'))"/>
                </xsl:if>
                <xsl:if test="string-length($value1) &lt; string-length($value2)">
                    <xsl:value-of select="string-length(substring-after($value2, '.'))"/>
                </xsl:if>
                <xsl:if test="string-length($value2) = string-length($value1)">
                    <xsl:value-of select="string-length(substring-after($value1, '.'))"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'Error'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Determine how many digits are represented in the decimal value -->
    <xsl:template name="FindTotalDigitCount">
        <xsl:param name="value1"/>
        <xsl:param name="value2"/>
        <xsl:variable name="value1nodecimal">
            <xsl:choose>
                <xsl:when test="contains($value1, '.') and contains($value1, '-')">
                    <xsl:value-of
                        select="substring-after(concat(substring-before($value1, '.'), substring-after($value1, '.')), '-')"
                    />
                </xsl:when>
                <xsl:when test="contains($value1, '.')">
                    <xsl:value-of
                        select="concat(substring-before($value1, '.'), substring-after($value1, '.'))"
                    />
                </xsl:when>
                <xsl:when test="contains($value1, '-')">
                    <xsl:value-of select="substring-after($value1, '-')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$value1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="value2nodecimal">
            <xsl:choose>
                <xsl:when test="contains($value2, '.') and contains($value2, '-')">
                    <xsl:value-of
                        select="substring-after(concat(substring-before($value2, '.'), substring-after($value2, '.')), '-')"
                    />
                </xsl:when>
                <xsl:when test="contains($value2, '.')">
                    <xsl:value-of
                        select="concat(substring-before($value2, '.'), substring-after($value2, '.'))"
                    />
                </xsl:when>
                <xsl:when test="contains($value2, '-')">
                    <xsl:value-of select="substring-after($value2, '-')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$value2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($value1nodecimal) > string-length($value2nodecimal)">
                <xsl:value-of select="string-length($value1nodecimal)"/>
            </xsl:when>
            <xsl:when test="string-length($value1nodecimal) &lt; string-length($value2nodecimal)">
                <xsl:value-of select="string-length($value2nodecimal)"/>
            </xsl:when>
            <xsl:when test="string-length($value1nodecimal) = string-length($value2nodecimal)">
                <xsl:value-of select="string-length($value1nodecimal)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'Error'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- _______________________________________________________ -->


    <!--Convert elements in xsd:appinfo to attributes-->
    <xsl:template match="*" mode="attr">
        <xsl:variable name="txt" select="normalize-space(text())"/>
        <xsl:if test="not($txt = ' ') and not(*) and not($txt = '')">
            <xsl:attribute name="{name()}">
                <xsl:value-of select="normalize-space(text())"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*:FudName">
        <Field name="{text()}"/>
    </xsl:template>
    <xsl:template match="*:FudExplanation"/>
    <xsl:template match="*:FieldFormatIndexReferenceNumber"/>
    <xsl:template match="*:FudNumber"/>
    <xsl:template match="*:VersionIndicator"/>
    <xsl:template match="*:MinimumLength"/>
    <xsl:template match="*:MaximumLength"/>
    <xsl:template match="*:LengthLimitation"/>
    <xsl:template match="*:UnitOfMeasure"/>
    <xsl:template match="*:Type"/>
    <xsl:template match="*:FudSponsor"/>
    <xsl:template match="*:FudRelatedDocument"/>
    <xsl:template match="*:DataType"/>
    <xsl:template match="*:EntryType"/>
    <xsl:template match="*:Explanation"/>
    <xsl:template match="*:MinimumInclusiveValue"/>
    <xsl:template match="*:MaximumInclusiveValue"/>
    <xsl:template match="*:LengthVariable"/>
</xsl:stylesheet>