<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gmx="http://www.isotc211.org/2005/gmx"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
  xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
  xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
  xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
  xmlns:saxon="http://saxon.sf.net/" version="2.0" extension-element-prefixes="saxon" exclude-result-prefixes="#all">

  <xsl:variable name="configuration" select="document('layout/config-editor.xml')"/>
  <xsl:variable name="editorConfig" select="document('layout/config-editor.xml')"/>

  <!-- Some utility -->
  <xsl:include href="layout/evaluate.xsl"/>
  <xsl:include href="layout/utility-tpl-multilingual.xsl"/>
  <xsl:include href="layout/utility-fn.xsl"/>

  <!-- The core formatter XSL layout -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/>

  <!-- Define the metadata to be loaded for this schema plugin-->
  <xsl:variable name="metadata" select="/root/gmd:MD_Metadata"/>
  <xsl:variable name="langId" select="gn-fn-iso19139:getLangId($metadata, $language)"/>
  <xsl:variable name="citation" select="'true'"/>
  <xsl:variable name="isSocialbarEnabled" select="false()"/>
  <xsl:variable name="sideRelated" select="''"/>
  <!-- This one is not take in account, probably overloaded by geonetwork configuration -->
  <xsl:variable name="viewMenu" select="'false'" />

  <!-- Empty template call to avoir wrong boostrap div row on 3.10 version -->
  <xsl:variable name="template" select="'empty'"/> 

  <!-- create DOI url from data-->
  <xsl:param name="doiUrl">
    <xsl:for-each select="/root/gmd:MD_Metadata/gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/gmd:CI_OnlineResource">
      <xsl:if test="gmd:protocol/gco:CharacterString='DOI'">
        <xsl:value-of select="gmd:linkage/gmd:URL"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:param>

  <!-- Ignore some fields displayed in header or in right column -->
  <xsl:template mode="render-field" match="gmd:graphicOverview|gmd:abstract|gmd:title" priority="2000"/>

  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="gmd:MD_Metadata">
    <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:title">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="gmd:MD_Metadata">
    <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- Icone Title -->
  <xsl:template mode="getMetadataHierarchyLevel" match="gmd:MD_Metadata">
    <xsl:value-of select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/>
  </xsl:template>

  <!-- Overview -->
  <xsl:template mode="getOverviews" match="gmd:MD_Metadata">
    <xsl:apply-templates mode="getData" select="$metadata"/>
    <section class="gn-md-side-overview">
      <h2>
        <i class="fa fa-fw fa-image">
          <xsl:comment select="'overview'"/>
        </i>
        <span>
          <xsl:value-of select="$schemaStrings/overviews"/>
        </span>
      </h2>

      <xsl:for-each select="gmd:identificationInfo/*/gmd:graphicOverview/*">
        <img class="gn-img-thumbnail center-block" src="{gmd:fileName/*}"/>

        <xsl:for-each select="gmd:fileDescription">
          <div class="gn-img-thumbnail-caption">
            <xsl:call-template name="localised">
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:call-template>
          </div>
        </xsl:for-each>

      </xsl:for-each>
    </section>
  </xsl:template>

  <!-- Extend on rigth side -->
  <xsl:template mode="getExtent" match="gmd:MD_Metadata">
    <section class="gn-md-side-extent">
      <h2>
        <i class="fa fa-fw fa-map-marker">
          <xsl:comment select="'etendu spatiale'"/>
        </i>
        <span>
          <xsl:comment select="name()"/>
          <xsl:value-of select="$schemaStrings/spatialExtent"/>
        </span>
      </h2>
       <div>
        <xsl:for-each select="gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/*[
                number(gmd:westBoundLongitude/gco:Decimal)
                and number(gmd:southBoundLatitude/gco:Decimal)
                and number(gmd:eastBoundLongitude/gco:Decimal)
                and number(gmd:northBoundLatitude/gco:Decimal)
                and normalize-space(gmd:westBoundLongitude/gco:Decimal) != ''
                and normalize-space(gmd:southBoundLatitude/gco:Decimal) != ''
                and normalize-space(gmd:eastBoundLongitude/gco:Decimal) != ''
                and normalize-space(gmd:northBoundLatitude/gco:Decimal) != '']">
              <xsl:copy-of select="gn-fn-render:bbox(
                                    xs:double(gmd:westBoundLongitude/gco:Decimal),
                                    xs:double(gmd:southBoundLatitude/gco:Decimal),
                                    xs:double(gmd:eastBoundLongitude/gco:Decimal),
                                    xs:double(gmd:northBoundLatitude/gco:Decimal))"/>

          </xsl:for-each>
      </div>
      <h2>
        <i class="fa fa-fw fa-clock-o">
          <xsl:comment select="'time'"/>
        </i>
        <span>
          Etendue temporelle
        </span>
      </h2>
      <div>
        <xsl:for-each select="gmd:identificationInfo/*/gmd:extent/*">
          <xsl:value-of select="gmd:temporalElement/*/gml:beginPosition" />
          <xsl:value-of select="gmd:temporalElement/*/gml:endPosition" />
        </xsl:for-each>
      </div>

    </section>
  </xsl:template>

  <!-- Display thesaurus name and the list of keywords -->
  <xsl:template mode="getTags" match="gmd:MD_Metadata">
    <section>
      <h2>
        <i class="fa fa-fw fa-tags">
          <xsl:comment select="'image'"/>
        </i>
        <span>Mots clés
        </span>
      </h2>
      <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword">
        <xsl:variable name="urlKeyword" select="normalize-space(.)"/>
        <xsl:if test="$urlKeyword != ''">   
            <a href="{$nodeUrl}fre/catalog.search#/search?keyword={$urlKeyword}">
              <span class="badge">
                <xsl:value-of select="."/>
              </span>
            </a>
        </xsl:if>
      </xsl:for-each>
    </section>
    <xsl:apply-templates mode="getRef" select="$metadata"/>
  </xsl:template>


  <xsl:template mode="getMetadataHeader" match="gmd:MD_Metadata">

    <!-- Auteur -->
    <div class="Auteur">
      <dl>
        <dt>Auteur (s)</dt>
        <dd>
          <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/*[gmd:CI_ResponsibleParty]">
            <xsl:call-template name="auteur"/>
          </xsl:for-each>
        </dd>
      </dl>
    </div>

    <!-- Date-->
    <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date">
      <div class="Date">
        <xsl:call-template name="date"/>
      </div>
    </xsl:for-each>

    <!-- Editeur -->
    <div class="Editeur">
      <dl>
        <dt>Editeur</dt>
        <dd>
          <xsl:for-each select="gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/*[gmd:CI_ResponsibleParty]">
            <xsl:call-template name="editeur"/>
          </xsl:for-each>
        </dd>
      </dl>
    </div>

    <!-- DOI -->
    <div class="doi">
      <!-- verifier si ici on ne fait pas le lien avec doi.org-->
      <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/gmd:CI_OnlineResource">
        <xsl:if test="gmd:protocol/gco:CharacterString='DOI'">
          <dl>
            <dt>DOI</dt>
            <dd>
              <a href="{$doiUrl}">
                <xsl:value-of select="$doiUrl"/>
              </a>
            </dd>
          </dl>
        </xsl:if>
      </xsl:for-each>
    </div>

    <!-- Resume -->
    <div class="Resume">
      <dl>
        <div style="padding-top: 10px;padding-left: 10px;">Résumé</div>
        <div class="alert alert-info">
          <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
            <xsl:call-template name="localised">
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:call-template>
          </xsl:for-each>
        </div>
      </dl>
    </div>

    <!-- Genealogie -->
    <div class="Genealogie">
      <dl>
        <dt>Génealogie</dt>
        <dd>
          <xsl:for-each select="gmd:dataQualityInfo/*/gmd:lineage/gmd:LI_Lineage/gmd:statement">
            <xsl:call-template name="localised">
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:call-template>
          </xsl:for-each>
        </dd>
      </dl>
    </div>

    <!-- Utilisation -->
    <div class="Utilisation">
      <dl>
        <dt>Utilisation</dt>
        <dd>
          <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation">
            <xsl:call-template name="localised">
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:call-template>
          </xsl:for-each>
        </dd>
      </dl>
    </div>

    <!-- Ressource associé -->
    <div class="Utilisation">
      <dl>
        <dt><xsl:value-of select="$schemaStrings/associatedResources"/></dt>
        <dd>
          <xsl:variable name="nodeName" select="name()"/>
            <xsl:for-each select="parent::node()/*[name() = $nodeName]">
              <li><a href="#uuid={@uuidref}" target="_blank">
                <i class="fa fa-link">&#160;</i>
                <xsl:value-of select="@uuidref"/>
              </a></li>
            </xsl:for-each>

        </dd>
      </dl>
    </div>     

  </xsl:template>

  <!-- A contact is displayed with its role as header -->
  <xsl:template name="auteur">

    <xsl:variable name="email">
      <xsl:for-each select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress">
        <xsl:apply-templates mode="render-value" select="."/>
        <xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- Display name is <individual name> ( <org name> ) -->
    <xsl:variable name="displayName">
      <xsl:choose>
        <xsl:when test="*/gmd:organisationName and */gmd:individualName">
          <!-- Org name may be multilingual -->
          <xsl:value-of select="*/gmd:individualName"/>
          <xsl:if test="*/gmd:positionName">
            ( <xsl:apply-templates mode="render-value" select="*/gmd:positionName"/>) - 
          </xsl:if>
           ( <xsl:apply-templates mode="render-value" select="*/gmd:organisationName"/>)
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="*/gmd:individualName|*/gmd:organisationName"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div>
      <xsl:choose>
        <xsl:when test="$email">
          <a href="mailto:{normalize-space($email)}">
            <xsl:value-of select="$displayName"/>&#160;
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$displayName"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template name="editeur">

    <xsl:variable name="emailEditeur">
      <xsl:for-each select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress">
        <xsl:apply-templates mode="render-value" select="."/>
        <xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- Display name is <individual name> ( <org name> ) -->
    <xsl:variable name="displayNameEditeur">
      <xsl:apply-templates mode="render-value" select="*/gmd:organisationName"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$emailEditeur">
        <a href="mailto:{normalize-space($emailEditeur)}">
          <xsl:value-of select="$displayNameEditeur"/>&#160;
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$displayNameEditeur"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Accès aux données -->
  <xsl:template mode="getData" match="gmd:MD_Metadata">
    <section>
      <h2>
        <i class="fa fa-fw fa-database">
          <xsl:comment select="'données'"/>
        </i>
        <span>Accéder aux données</span>
      </h2>
      <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/gmd:CI_OnlineResource">
        <xsl:if test="gmd:protocol[* = 'WWW:DOWNLOAD-1.0-http--download']">
          <xsl:variable name="linkUrl" select="gmd:linkage/gmd:URL"/>
          <xsl:if test="$linkUrl != ''">
            <p>
              <a href="{$linkUrl}">
                <xsl:value-of select="gmd:description"/>
              </a>
            </p>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
    </section>
  </xsl:template>

  <!-- Références -->
  <xsl:template mode="getRef" match="gmd:MD_Metadata">
    <section >
      <h2>
        <i class="fa fa-fw fa-link">
          <xsl:comment select="'références'"/>
        </i>
        <span>Références</span>
      </h2>
      <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/gmd:CI_OnlineResource">
        <xsl:if test="gmd:protocol[* = 'WWW:LINK-1.0-http--link']">
          <xsl:variable name="linkUrl" select="gmd:linkage/gmd:URL"/>
          <xsl:if test="$linkUrl != ''">
            <p>
              <a href="{$linkUrl}">
                <xsl:value-of select="gmd:description"/>
              </a>
            </p>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
    </section>
  </xsl:template>

  <xsl:template mode="getMetadataCitation" match="gmd:MD_Metadata">
    <!-- Citation -->
    <div class="Citation">
      <table class="table">
        <tr class="active">
          <td>
            <div class="pull-left text-muted">
              <i class="fa fa-quote-left fa-4x">&#160;</i>
            </div>
          </td>
          <td>
            <em title="{$schemaStrings/citationProposal-help}">
              <xsl:value-of select="$schemaStrings/citationProposal"/>
            </em>
            <br/>

            <!-- Custodians -->
            <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact/
                                  *[gmd:role/*/@codeListValue = ('custodian', 'author')]">
              <xsl:variable name="name" select="normalize-space(gmd:individualName)"/>

              <xsl:value-of select="$name"/>
              <xsl:if test="$name != ''">&#160;</xsl:if>
              <xsl:if test="position() != last()">,&#160;</xsl:if>
            </xsl:for-each>

            <!-- Publication year -->
            <xsl:variable name="publicationDate" select="gmd:identificationInfo/*/gmd:citation/*/gmd:date/*[
                                    gmd:dateType/*/@codeListValue = 'publication']/
                                      gmd:date/gco:*"/>

            <xsl:if test="$publicationDate != ''">
            (<xsl:value-of select="substring($publicationDate, 1, 4)"/>)
            </xsl:if>

            <xsl:text>. </xsl:text>

            <!-- Title -->
            <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:title">
              <xsl:call-template name="localised">
                <xsl:with-param name="langId" select="$langId"/>
              </xsl:call-template>
            </xsl:for-each>

            <xsl:text>. </xsl:text>

            <!-- Publishers -->
            <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact/
                                  *[gmd:role/*/@codeListValue = 'publisher']">
              <xsl:value-of select="gmd:organisationName/*"/>
              <xsl:if test="position() != last()">&#160;-&#160;</xsl:if>
            </xsl:for-each>

            <!-- Link -->
            <a href="{$doiUrl}">
              <xsl:value-of select="$doiUrl"/>
            </a>
          </td>
        </tr>
      </table>
    </div>
  </xsl:template>

  <!-- Date -->
  <xsl:template name="date">
    <dl class="gn-date">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        <xsl:if test="*/gmd:dateType/*[@codeListValue != '']">
          ( <xsl:apply-templates mode="render-value" select="*/gmd:dateType/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
        <xsl:variable name="date" select="*/gmd:date/*" />
        <xsl:value-of select="substring($date, 6, 2)"/>/<xsl:value-of select="substring($date, 3, 2)"/>/<xsl:value-of select="substring($date, 1, 4)"/>
      </dd>
    </dl>
  </xsl:template>

    <!-- Date -->
  <xsl:template name="empty">
    <dl class="gn-empty">
      <dt>
      </dt>
      <dd>
      </dd>
    </dl>
  </xsl:template>

  <!-- Elements to avoid render -->
  <xsl:template mode="render-field" match="gmd:PT_Locale" priority="100"/>

  <!-- Traverse the tree -->
  <xsl:template mode="render-field" match="*">
    <xsl:apply-templates mode="render-field"/>
  </xsl:template>

  <xsl:template mode="render-value" match="gmd:language/gco:CharacterString">
    <span data-translate="">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <!-- ... Codelists -->
  <xsl:template mode="render-value" match="@codeListValue">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation" select="tr:codelist-value-label(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc" select="tr:codelist-value-desc(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
        <span title="{$codelistDesc}">
          <xsl:value-of select="$codelistTranslation"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Enumeration -->
  <xsl:template mode="render-value" match="gmd:MD_TopicCategoryCode|
                        gmd:MD_ObligationCode|
                        gmd:MD_PixelOrientationCode">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation" select="tr:codelist-value-label(
                            tr:create($schema),
                            local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc" select="tr:codelist-value-desc(
                            tr:create($schema),
                            local-name(), $id)"/>
        <span title="{$codelistDesc}">
          <xsl:value-of select="$codelistTranslation"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="render-value" match="@gco:nilReason[. = 'withheld']" priority="100">
    <i class="fa fa-lock text-warning" title="{{{{'withheld' | translate}}}}">&#160;</i>
  </xsl:template>
  <xsl:template mode="render-value" match="@*"/>

</xsl:stylesheet>
