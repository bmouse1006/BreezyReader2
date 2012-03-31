//
//  GRATOMXMLParser_new+private.h
//  SmallReader
//
//  Created by Jin Jin on 10-10-20.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "GRATOMXMLParser_new.h"

@interface GRATOMXMLParser_new (private)

- (void)startElementLocalName:(const xmlChar*)localname
					   prefix:(const xmlChar*)prefix
						  URI:(const xmlChar*)URI
				nb_namespaces:(int)nb_namespaces
				   namespaces:(const xmlChar**)namespaces
				nb_attributes:(int)nb_attributes
				 nb_defaulted:(int)nb_defaulted
				   attributes:(const xmlChar**)attributes;

- (void)endElementLocalName:(const xmlChar*)localname
					 prefix:(const xmlChar*)prefix URI:(const xmlChar*)URI;

- (void)charactersFound:(const xmlChar*)ch
					len:(int)len;

- (void)attributeHandler:(const xmlChar*)elem
				fullname:(const xmlChar*)fullname 
					type:(int)type def:(int)def 
			defaultValue:(const xmlChar*)defaultValue
					tree:(xmlEnumerationPtr)tree;

@end

static void startElementHandler(void* ctx,
								const xmlChar* localname,
								const xmlChar* prefix,
								const xmlChar* URI,
								int nb_namespaces,
								const xmlChar** namespaces,
								int nb_attributes,
								int nb_defaulted,
								const xmlChar** attributes)
{
    [(GRATOMXMLParser_new*)ctx
	 startElementLocalName:localname
	 prefix:prefix URI:URI
	 nb_namespaces:nb_namespaces
	 namespaces:namespaces
	 nb_attributes:nb_attributes
	 nb_defaulted:nb_defaulted
	 attributes:attributes];
}

static void endElementHandler(void* ctx,
							  const xmlChar* localname,
							  const xmlChar* prefix,
							  const xmlChar* URI)
{
    [(GRATOMXMLParser_new*)ctx
	 endElementLocalName:localname
	 prefix:prefix
	 URI:URI];
}

static void charactersFoundHandler(void* ctx,
								   const xmlChar* ch,
								   int len)
{
    [(GRATOMXMLParser_new*)ctx
	 charactersFound:ch len:len];
}

static void	attributeHandler(void * ctx,
							 const xmlChar * elem,
							 const xmlChar * fullname,
							 int type, 
							 int def,
							 const xmlChar * defaultValue, 
							 xmlEnumerationPtr tree){
	[(GRATOMXMLParser_new*)ctx attributeHandler:elem 
									   fullname:fullname 
										   type:type 
											def:def 
								   defaultValue:defaultValue
										   tree:tree];
}

static xmlSAXHandler _saxHandlerStruct = {
    NULL,            /* internalSubset */
    NULL,            /* isStandalone   */
    NULL,            /* hasInternalSubset */
    NULL,            /* hasExternalSubset */
    NULL,            /* resolveEntity */
    NULL,            /* getEntity */
    NULL,            /* entityDecl */
    NULL,            /* notationDecl */
    attributeHandler,            /* attributeDecl */
    NULL,            /* elementDecl */
    NULL,            /* unparsedEntityDecl */
    NULL,            /* setDocumentLocator */
    NULL,            /* startDocument */
    NULL,            /* endDocument */
    NULL,            /* startElement*/
    NULL,            /* endElement */
    NULL,            /* reference */
    charactersFoundHandler, /* characters */
    NULL,            /* ignorableWhitespace */
    NULL,            /* processingInstruction */
    NULL,            /* comment */
    NULL,            /* warning */
    NULL,            /* error */
    NULL,            /* fatalError //: unused error() get all the errors */
    NULL,            /* getParameterEntity */
    NULL,            /* cdataBlock */
    NULL,            /* externalSubset */
    XML_SAX2_MAGIC,  /* initialized */
    NULL,            /* private */
    startElementHandler,    /* startElementNs */
    endElementHandler,      /* endElementNs */
    NULL,            /* serror */
};