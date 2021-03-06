<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsd="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsd"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="USMTF_MESSAGES" select="document('../xml/xsd/USMTF/GoE_messages.xsd')"/>
    <xsl:variable name="NATO_MESSAGES" select="document('../xml/xsd/NATOMTF/natomtf_goe_messages.xsd')"/>
    <xsl:variable name="usmtf_messages_out" select="'../xml/xml/usmtf_messages_ui.xml'"/>
    <xsl:variable name="nato_messages_out" select="'../xml/xml/nato_messages_ui.xml'"/>
    <xsl:template name="allmessagesUI">
        <xsl:result-document href="{$usmtf_messages_out}">
            <xsl:call-template name="messagesUI">
                <xsl:with-param name="mtf_messages" select="$USMTF_MESSAGES"/>
            </xsl:call-template>
        </xsl:result-document>
        <xsl:result-document href="{$nato_messages_out}">
            <xsl:call-template name="messagesUI">
                <xsl:with-param name="mtf_messages" select="$NATO_MESSAGES"/>
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>
    <xsl:template name="messagesUI">
        <xsl:param name="mtf_messages"/>
        <xsl:variable name="messages">
            <xsl:apply-templates select="$mtf_messages/xsd:schema/xsd:element"/>
        </xsl:variable>
        <xsl:element name="Messages">
            <xsl:for-each select="$messages/*">
                <xsl:sort select="name()"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="/">
        <xsl:element name="Messages">
            <xsl:apply-templates select="xsd:schema/xsd:element">
                <xsl:sort select="@name"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xsd:schema/xsd:element">
        <xsl:variable name="t">
            <xsl:value-of select="@type"/>
        </xsl:variable>
        <xsl:element name="{@name}">
            <!--<xsl:attribute name="tag">
                <xsl:value-of select="@name"/>
            </xsl:attribute>-->
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:apply-templates select="ancestor::xsd:schema/xsd:complexType[@name = $t]"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xsd:schema/xsd:complexType">
        <xsl:apply-templates select="xsd:annotation/xsd:appinfo/*:Msg" mode="info"/>
        <xsl:apply-templates select="xsd:annotation/xsd:appinfo/*:Rule" mode="info"/>
        <xsl:apply-templates select="xsd:sequence"/>
    </xsl:template>
    <xsl:template match="*:Msg" mode="info">
        <xsl:element name="Info">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates select="*" mode="copy"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*:Rule" mode="info">
        <xsl:element name="Rule">
            <xsl:apply-templates select="@*" mode="copy"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*:Segment" mode="info">
        <xsl:element name="Info">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates select="*" mode="copy"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*:Set" mode="info">
        <xsl:element name="Info">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates select="*" mode="copy"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*:Field" mode="info">
        <xsl:element name="Info">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates select="*" mode="copy"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xsd:sequence">
        <xsl:element name="Sequence">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xsd:choice">
        <xsl:element name="Choice">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xsd:sequence/xsd:element[@name][not(starts-with(@type, 'field:'))][xsd:annotation/xsd:appinfo/*:Set]">
        <xsl:element name="{@name}">
            <!--<xsl:attribute name="tag">
                <xsl:value-of select="@name"/>
            </xsl:attribute>-->
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*[not(name() = 'name')][not(name() = 'type')]" mode="copy"/>
            <xsl:apply-templates select="xsd:annotation/xsd:appinfo/*:Set" mode="info"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xsd:sequence/xsd:element[@name][xsd:annotation/xsd:appinfo/*:Field]">
        <xsl:element name="{@name}">
            <!--<xsl:attribute name="tag" select="@name"/>-->
            <xsl:apply-templates select="@*[not(name() = 'name')]" mode="copy"/>
            <xsl:apply-templates select=".//@base[1]" mode="copy"/>
            <xsl:apply-templates select=".//xsd:restriction[1]/*" mode="attr"/>
            <xsl:apply-templates select="xsd:annotation/xsd:appinfo/*:Field" mode="info"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xsd:element[@ref][starts-with(@ref, 'set:')]">
        <xsl:element name="{substring-after(@ref, 'set:')}">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates select="xsd:documentation" mode="doc"/>
            <xsl:apply-templates select="xsd:annotation/xsd:appinfo/*:Set" mode="info"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xsd:element[@ref][starts-with(@ref, 'seg:')]">
        <xsl:element name="{substring-after(@ref, 'seg:')}">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates select="xsd:annotation/xsd:appinfo/*:Segment" mode="info"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xsd:element[@ref][not(contains(@ref, ':'))][xsd:annotation/xsd:appinfo/*:Segment]">
        <xsl:element name="{@ref}">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates select="xsd:annotation/xsd:appinfo/*:Segment" mode="info"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xsd:element[@name][starts-with(@type, 'field:')]">
        <xsl:element name="{@name}">
            <!--<xsl:attribute name="tag">
                <xsl:value-of select="@name"/>
            </xsl:attribute>-->
            <xsl:apply-templates select="@*" mode="copy"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xsd:minLength | xsd:maxLength | xsd:length | xsd:minInclusive | xsd:maxInclusive" mode="attr">
        <xsl:attribute name="{substring-after(name(),'xsd:')}">
            <xsl:value-of select="@value"/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="xsd:documentation" mode="doc">
        <xsl:attribute name="doc">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="*:Document">
        <xsl:apply-templates select="." mode="copy"/>
    </xsl:template>
    <xsl:template match="*">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <xsl:template match="*" mode="copy">
        <xsl:element name="{name()}">
            <xsl:value-of select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@*" mode="copy">
        <xsl:attribute name="{name()}">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:attribute>
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="*:Field">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <xsl:template match="*:Set">
        <xsl:apply-templates select="*"/>
    </xsl:template>
</xsl:stylesheet>
