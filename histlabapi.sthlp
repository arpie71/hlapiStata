{smcl}
{* 11apr2025}{...}
{hline}
help for {hi:hlapi}
{hline}

{title:Program to get data from History Lab's API.}

{p 8 14 2}
   {cmd: histlabapi} {it:option}
   {cmd:,}
   {cmd:[}
   {cmd: date}{it:(string)}{cmd: start}{it:(string)}{cmd: end}{it:(string)} {cmd:text}{it:(string)} {cmd:id}{it:(string)} {cmd:COLlection}{it:(string)} 
   {cmd:fields}{it:(string)} {cmd:entitytype}{it:(string)} {cmd:entityvalue}{it:(string)} {cmd:topicvalue}{it:(string)}
   {cmd:overview}{it:(string)} {cmd:sort}{it:(string)}  {cmd: limit}{it:(integer 25)} {cmd:orlist}{it:(string)} {cmd:]}
{p_end}

{title:Description}

{p 4 4 2}
This command will talk to and download data from History Lab's API.

{title:Collections}
{p}There are 11 collections available to query. The API and the help file will be updated as more collections are added.{p_end}
{p 4 4 2}{cmd: cpdoc} - Azeredo da Silveira Papers{p_end}
{p 4 4 2}{cmd: clinton} - Clinton E-Mail{p_end}
{p 4 4 2}{cmd: kissinger} - Kissinger Telephone Conversations{p_end}
{p 4 4 2}{cmd: cfpf} - State Department Central Foreign Policy Files{p_end}
{p 4 4 2}{cmd: frus} - Foreign Relations of the United States{p_end}
{p 4 4 2}{cmd: cia} - CIA CREST Collection{p_end}
{p 4 4 2}{cmd: cabinet} - UK Cabinet Papers{p_end}
{p 4 4 2}{cmd: briefing} - Daily intelligence briefings{p_end}
{p 4 4 2}{cmd: worldbank} - World Bank Archives{p_end}
{p 4 4 2}{cmd: nato} - NATO Archives{p_end}
{p 4 4 2}{cmd: un} - United Nations Archives{p_end}

{p}Multiple collections are allowed and names of collections can be separated with either a space or a comma.{p_end}

{title:Fields}

{p} For all of the options except {cmd:overview}, there are 12 fields available. By default, the command will return only {it:doc_id}, {it:authored}, and {it:title}. {p_end}

{p 4 4 2}{it:doc_id} - Unique document identifier{p_end}
{p 4 4 2}{it:authored} - Document date{p_end}
{p 4 4 2}{it:title} - Document title{p_end}
{p 4 4 2}{it:classification} - Original classification of document (if known){p_end}
{p 4 4 2}{it:corpus} - Collection document is from{p_end}
{p 4 4 2}{it:wikidata_ids} - Wikidata IDs of entities in document{p_end}
{p 4 4 2}{it:entgroups} - Entity types appearing in document{p_end}
{p 4 4 2}{it:entities} - Standardized entity names in document{p_end}
{p 4 4 2}{it:topic_titles} - Top 3 topic words{p_end}
{p 4 4 2}{it:topic_names} - Top 5 topic words{p_end}
{p 4 4 2}{it:topic_scores} - Topic score for each topic listed{p_end}
{p 4 4 2}{it:topic_ids} - ID number for each topic (used to search by topic){p_end}

{title:Option}
There are 6 broad types of queries allowed using the {cmd:option} parameter. 
Only one option can be specified at a time. For some of the query options, other parameters are available to filter the search.

{p 4 4 2}{it: id} - Searches the History Lab collections for a given document ID or list of document IDs. The {cmd:id} parameter is required to give an ID or list of IDs to search. The only optional parameter allowed is {cmd:fields}.{p_end}

{p 4 4 2}{it: date} - Searches the History Lab collections for all documents on a given date ({cmd: date()}) or within a range of dates ({cmd: start()} and {cmd: end()}). The search can be limited by {cmd: fields}, by {cmd: collection}, or by {cmd:limit}.{p_end}

{p 4 4 2}{it: text} - Searches the full-text of documents in the History Lab collections. Searches can be performed on either words or phrases. The {cmd:collection}, {cmd:date/start/end}, and the {cmd:fields} parameters can be used with this query.{p_end}

{p 4 4 2}{it: entity} - Searches the History Lab collections for all documents that contain a given Wikidata ID. With this option, the {cmd:entityvalue} parameters must be used to identify the entity or entities to be searched. Multiple values of entities are allowed. The {cmd:collection}, {cmd:date/start/end}, and the {cmd:fields} parameters can also be used with this query.{p_end}

{p 4 4 2}{it: topic} - Searches the History Lab collections for all documents that contain a given topic ID. With this option, the {cmd:topicvalue} parameter must be used to specify the value(s) of the topics to be searched. Note that topic IDs are not unique to a collection so this option is best used with the collection parameter. Also, as discussed below, the {cmd:find_topic_id} command will return topic IDs for a search term. The {cmd:collection}, {cmd:date/start/end}, and the {cmd:fields} parameters can also be used with this query.{p_end}

{p 4 4 2}{it: overview} - Returns an overview of collections, topics, and entities from History Lab. The {cmd:collections} option will return a summary of the different collections processed by History Lab, including the date of the oldest and most recent documents, the number of documents, and the number of pages. The {cmd:topics} option will return a list of all the topics across collections. Each collection has between 40 and 130 topics and the {cmd:collections} option can be used to limit the list of topics to a specific collection. Finally, the {cmd:entity} option returns a list of all entities detected in History Lab collections, as well as the number of times they are mentioned. The search can be limited to specific types through the {cmd:entitytype} option. There are 5 entitytypes available: {it:PERSON}, {it:ORG}, {it:LOC}, {it:GOVT}, {it:OTHER}.{p_end}

{title:Parameters}

{p 4 4 2}The {cmd:text} parameter provides words or phrases that will be used to search the History Lab collections. Multiple words or multiple phrases should be separated with a comma. The parameter can only be used with the {it:text} option.{p_end}

{p 4 4 2}The {cmd:collection} parameter restricts a {it:date}, {it:topic}, or {it:text} search to a specified collection or list of collections. Multiple collections should be separated with a comma or a space. The list of collections allowed is given above. This option can also be used with the {it:overview} search if either {it:collection} or {it:topic} is specified. {p_end}

{p 4 4 2}The {cmd:fields} parameter restricts all searches except {it:overview} to return the specified field or list of fields. Multiple fields should be separated with a comma or a space. If no fields are specified, the commands will return the {it:authored}, {it:doc_id}, and {it:title} fields only. {p_end}

{p 4 4 2}The {cmd:overview} parameter is used only with the {it:overview} option to specify the entity to return for an overview search. Acceptable values are {it:collections}, {it:topics}, or {it:entities} and only one may be specified with this option at a time. {p_end}

{p 4 4 2}The {cmd:id} parameter is used only with the {it:id} option to provide the ID or list of IDs to search. As with the {cmd:collection} and {cmd:field} parameters, a list of IDs should be separated with a comma or a space. If an invalid ID is entered, the command will not return an error. Instead, the command simply will not return any results for that ID. {p_end} 

{p 4 4 2}The {cmd:date} and {cmd:start/end} parameters can used with the {it:date} option, or with the {it:entity}, {it:topic}, or {it:text} options in order to restrict the dates of the documents retrieved to a given day or to a range of dates.  Dates should be in numeric format and use either ".","-", or "/" as separators between month, day, and year. The function first looks for a "MDY" or a "YMD" format but it will recognize a "DMY" format for days greater than 12.{p_end}

{p 4 4 2} The {cmd:entityvalue} parameter is required with an {it:entity} search and specifies the Wikidata ID of the entity to search for. {p_end}

{p 4 4 2} The {cmd:topicvalue} parameter is required with a {it:topic} search and specifies the topic ID of the topic to search for. {p_end}

{p 4 4 2} The {cmd:entitytype} parameter is used with an {it:overview} search with the {cmd:entity} option. There are 5 entitytypes available: {it:PERSON}, {it:ORG}, {it:LOC}, {it:GOVT}, {it:OTHER}{p_end}

{p 4 4 2} The {cmd:sort} option is also used with an {it:overview} search with the {cmd:entity} option. It sorts the entities returned in {cmd:A}scending or {cmd:D}escending order of the number of appearances.{p_end}

{p 4 4 2} The {cmd:orlist} option specifies whether a search should be an "or" search or an "and" search. An {cmd:or} value will search for any of the text terms, Wikidata IDs, or topic IDs specified while an {cmd:and} value finds all of the terms. This option is available only with a {it:text}, {it:entity}, or {it:topic} search.{p_end}

{p 4 4 2}The {cmd:limit} parameter tells the API how many results to return. The default value is 25 and there is a system maximum of 10,000.{p_end}


{title:Examples}

{p 4 4 4}ID search: {p_end}
{p 8 8 12}histlabapi id , id(1973LIMA07564){p_end}
{p 8 8 12}histlabapi id ,  id(frus1969-76ve05p1d11) fields(doc_id,body,title) {p_end}
{p 8 8 12}histlabapi id ,  id(1973LIMA07564,frus1969-76ve05p1d11) fields(doc_id,body,title) {p_end}

{p 4 4 4}Overview search: {p_end}
{p 8 8 12}histlabapi overview, overview(collections){p_end}
{p 8 8 12}histlabapi overview, overview(entities) sort(D){p_end}
{p 8 8 12}histlabapi overview, overview(entities) entitytype("PERSON") sort(D){p_end}
{p 8 8 12}histlabapi overview, overview(topics) collection(frus){p_end}

{p 4 4 4}Date search: {p_end}
{p 8 8 12}histlabapi date, start(1947-01-01) end(1948-12-01) fields(doc_id,authored,title) limit(100){p_end}
{p 8 8 12}histlabapi date ,  collection(cpdoc,kissinger) start(01/1/1975) end(12/01/1975)  limit(100){p_end}

** HERE 
{p 4 4 4}Entity search: {p_end}
{p 8 8 12}histlabapi entity , entity(country) entityvalue(Belize) summary
{p_end}
{p 8 8 12}histlabapi entity , entity(topic) entityvalue(Asia) collection(frus){p_end}
{p 8 8 12}histlabapi , option(entity) topic(0) fields(subject,title) start(1/1/1975) end(12/31/1980){p_end}


{p 4 4 4}Full-text search: {p_end}
{p 8 8 12}histlabapi text, collection(frus) start(01/01/1950) end(12/31/2000) text(udeac){p_end}
{p 8 8 12}histlabapi text ,  collection(frus,cfpf) start(1/1/1950) end(12/31/2000) text(udeac, asean) orlist("or")  limit(200){p_end}
{p 8 8 12}histlabapi , option(text) collection(frus,cfpf) start(1/1/1950) end(12/31/2000) text(united nations) limit(200){p_end}

{title:Notes}

{p}We also provide two commands to look up Wikidata IDs (for an entity search) and topic IDs (for a {cmd:topic} search.  {p_end}
{p 4 4 2}{cmd:find_wiki_id} {it:anything} will perform a search of the database and return all entities and Wikidata IDs that partially match a given string.{p_end}
{p 4 4 2}{cmd:find_topic_id} {it:anything} will perform a search of the database and return all topics and topic IDs that partially match a given string. The topic names are in all lower case. The command will convert search terms to lower case.{p_end}

{title:Examples}
{p 4 4 2}find_wiki_id "China" /* China Wikidata ID is Q148 */ {p_end}
{p 4 4 2}find_topic_id "iraq" {p_end}


{p_end}