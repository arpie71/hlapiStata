# Stata interface for History Lab API 

This Stata package offers a command to use the History Lab API in order to download data from our collections. 

## Collections

The History Lab API has documents available from 11 different collections, as detailed below. The R functions will search across all collections, unless a specific collection or set of collections is specified. 

|corpus|title|starts|ends|documents
|----|----|----|----|----|
|frus|Foreign Relations of the United States|1620|1989|311866|
|cia|CIA CREST Collection|1941|2005|935716|
|clinton|Clinton E-Mail|2009|2013|54149|
|briefing|Presidential Daily Briefings|1946|1977|9680|
|cfpf|State Department Central Foreign Policy Files|1973|1979|3214293|
|kissinger|Kissinger Telephone Conversations|1973|1976|4552|
|nato|NATO Archives|1949|2013|46002|
|un|United Nations Archives|1997|2016|192541|
|worldbank|World Bank McNamara Records|1942|2020|128254|
|cabinet|UK Cabinet Papers|1907|1990|42539|
|cpdoc|Azeredo da Silveira Papers|1973|1979|10279|

## Fields
The API can return many different fields which are described in the table below. By default, the command will only return _doc_id_, _authored_, and _title_. 

|field|title|
|----|----|
|authored|Document date|
|wikidata_ids|Wikidata IDs of entities in document|
|entgroups|Entity types appearing in document|
|entities|Standardized entity names in document|
|topic_names|Top 5 tokens for each topic|
|topic_scores|Topic score for each topic listed|
|topic_ids|ID number for each topic (used to search by topic)|
|title|Document title|
|classification|Original classification of document (if known)|
|corpus|Collection document is from|
|doc_id|Unique document identifier|


## Command

The command has a number of different options to conduct various types of searches on History Lab documents.

### Syntax
   ```histlabapi option ,[date(string) start(string) end(string) text(string) id(string) COLlection(string) fields(string) entitytype(string) entityvalue(string) topicvalue(string) overview(string) sort(string)  limit(integer 25) orlist(string)]```


## Options
There are 6 broad types of queries allowed using the `option` parameter. 
Only one option can be specified at a time. For some of the query options, other parameters are available to filter the search.

`id` - Searches the History Lab collections for a given document ID or list of document IDs. The `id` parameter is required to give an ID or list of IDs to search. The only optional parameter allowed is `fields`.

`date` - Searches the History Lab collections for all documents on a given date (`date()`) or within a range of dates (`start()` and `end()`). The search can be limited by `fields`, by `collection`, or by `limit`.

`text` - Searches the full-text of documents in the History Lab collections. Searches can be performed on either words or phrases. The `collection`, `date/start/end`, and the `fields` parameters can be used with this query.

`entity` - Searches the History Lab collections for all documents that contain a given Wikidata ID. With this option, the `entityvalue` parameters must be used to identify the entity or entities to be searched. Multiple values of entities are allowed. The `collection`, `date/start/end` and the `fields` parameters can also be used with this query.

`topic` - Searches the History Lab collections for all documents that contain a given topic ID. With this option, the `topicvalue` parameter must be used to specify the value(s) of the topics to be searched. Note that topic IDs are not unique to a collection so this option is best used with the collection parameter. Also, as discussed below, the `find_topic_id` command will return topic IDs for a search term. The `collection`, `date/start/end`, and the `fields` parameters can also be used with this query.

`overview` - Returns an overview of collections, topics, and entities from History Lab. The `collections` option will return a summary of the different collections processed by History Lab, including the date of the oldest and most recent documents, the number of documents, and the number of pages. The `topics` option will return a list of all the topics across collections. Each collection has between 40 and 130 topics and the `collections` option can be used to limit the list of topics to a specific collection. Finally, the `entity` option returns a list of all entities detected in History Lab collections, as well as the number of times they are mentioned. The search can be limited to specific types through the `entitytype` option. There are 5 entitytypes available: _PERSON_, _ORG_, _LOC_, _GOVT_, _OTHER_.

## Parameters

The `text` parameter provides words or phrases that will be used to search the History Lab collections. Multiple words or multiple phrases should be separated with a comma. The parameter can only be used with the _text_ option.

The `collection` parameter restricts a _date_, _topic_, or _text_ search to a specified collection or list of collections. Multiple collections should be separated with a comma or a space. The list of collections allowed is given above. This option can also be used with the _overview_ search if either _collection_ or _topic_ is specified. 

The `fields` parameter restricts all searches except _overview_ to return the specified field or list of fields. Multiple fields should be separated with a comma or a space. If no fields are specified, the commands will return the _authored_, _doc_id_, and _title_ fields only.

The `overview` parameter is used only with the _overview_ option to specify the entity to return for an overview search. Acceptable values are _collections_, _topics_, or _entities_ and only one may be specified with this option at a time.

The `id` parameter is used only with the _id_ option to provide the ID or list of IDs to search. As with the `collection` and `field` parameters, a list of IDs should be separated with a comma or a space. If an invalid ID is entered, the command will not return an error. Instead, the command simply will not return any results for that ID.

The `date` and `start/end` parameters can used with the _date_ option, or with the _entity_, _topic_, or _text_ options in order to restrict the dates of the documents retrieved to a given day or to a range of dates.  Dates should be in numeric format and use either ".","-", or "/" as separators between month, day, and year. The function first looks for a "MDY" or a "YMD" format but it will recognize a "DMY" format for days greater than 12.

The `entityvalue` parameter is required with an _entity_ search and specifies the Wikidata ID of the entity to search for. 

The `topicvalue` parameter is required with a _topic_ search and specifies the topic ID of the topic to search for. 

The `entitytype` parameter is used with an _overview_ search with the `entity` option. There are 5 entitytypes available: _PERSON_, _ORG_, _LOC_, _GOVT_, _OTHER_.

The `sort` option is also used with an _overview_ search with the `entity` option. It sorts the entities returned in `A`scending or `D`escending order of the number of appearances.

The `orlist` option specifies whether a search should be an "or" search or an "and" search. An `or` value will search for any of the text terms, Wikidata IDs, or topic IDs specified while an `and` value finds all of the terms. This option is available only with a _text_, _entity_, or _topic_ search.

The `limit` parameter tells the API how many results to return. The default value is 25 and there is a system maximum of 10,000.


## Examples

_ID search:_

- ```histlabapi id , id(1973LIMA07564)```
- ```histlabapi id ,  id(frus1969-76ve05p1d11) fields(doc_id,body,title)```
- ```histlabapi id ,  id(1973LIMA07564,frus1969-76ve05p1d11) fields(doc_id,body,title)```

_Overview search:_

- ```histlabapi overview, overview(collections)```
- ```histlabapi overview, overview(entities) sort(D)```
- ```histlabapi overview, overview(entities) entitytype("PERSON") sort(D)```
- ```histlabapi overview, overview(topics) collection(frus)```

_Date search:_
- ```histlabapi date, start(1947-01-01) end(1948-12-01) fields(doc_id,authored,title) limit(100)```
- ```histlabapi date ,  collection(cpdoc,kissinger) start(01/1/1975) end(12/01/1975)  limit(100)```

_Entity search:_
- ```histlabapi entity , collection(frus) entityvalue(Q242)``` 
- ```histlabapi entity , entityvalue(Q9588) collection(kissinger)```

_Full-text search:_
- ```histlabapi text, collection(cfpf) start(01/01/1950) end(12/31/2000) text(udeac)```
- ```histlabapi text ,  collection(frus,cfpf) start(1/1/1950) end(12/31/2000) text(udeac, asean) orlist("or")  limit(20)```

- ```histlabapi text , collection(frus,cfpf) start(1/1/1950) end(12/31/2000) text(united nations) limit(200)``

## Notes

We also provide two commands to look up Wikidata IDs (for an `entity` search) and topic IDs (for a `topic` search.  

`find_wiki_id` _anything_ will perform a search of the database and return all entities and Wikidata IDs that partially match a given string.

`find_topic_id` _anything_ will perform a search of the database and return all topics and topic IDs that partially match a given string. The topic names are in all lower case. The command will convert search terms to lower case.

### Examples
- ```find_wiki_id "China" /* China Wikidata ID is Q148 */```

- ```find_topic_id "iraq"```
