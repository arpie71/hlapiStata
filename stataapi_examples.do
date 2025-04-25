
** OVERVIEW

histlabapi overview, overview(entities)
histlabapi overview, overview(topics)
histlabapi overview, overview(collections)

histlabapi overview, overview(entities) entitytype(PERSON)
histlabapi overview, overview(entities) entitytype(PERSON) sort(D)


** IDs
histlabapi id , id("frus1969-76ve05p1d11")
histlabapi id , id("frus1969-76ve05p1d11") fields("doc_id,body,title")

histlabapi id, id("frus1969-76ve05p1d11,frus1958-60v03d47")

histlabapi id, id("frus1969-76ve05p1d11,frus1958-60v03d47") fields("doc_id,body,title,topic_titles,entities")


** DATES

histlabapi date, start("1947-01-01") end("12/01/1948")
histlabapi date, start("1947-01-01") end("12/01/1948") limit(100)
histlabapi date, start("1947-01-01") end("12/01/1948") fields("doc_id,title,entities")
histlabapi date , date("1980-09-15") fields("doc_id,classification, title")  collection("frus")

** ENTITIES
find_wiki_id "China" /* China Wikidata ID is Q148 */
find_wiki_id "Kissinger" /* Henry Kissinger Wikidata ID is Q66107 */
histlabapi entity , entityvalue("Q148") collection("cfpf") fields("doc_id,authored,title,body") limit(200)

histlabapi entity , entityvalue("Q148,Q66107") collection("frus") limit(200)

find_wiki_id "Clinton" /* Hillary Clinton Wikidata ID is Q6294 */
histlabapi entity , entityvalue("Q6294,Q66107") orlist("or") fields("entities,doc_id, wikidata_ids")


** TOPICS

find_topic_id "iraq"
histlabapi topic, topicvalue("25") collection("un") fields("doc_id,title,authored,topic_names")

hlapi_topics(topics.value='25', coll.name='un', fields=c('doc_id','title','authored','topic_names'))
find.topics.id('soviet')
hlapi_topics(topics.value=c('80','102','103'), coll.name='cia', fields=c('doc_id','title','authored','topic_names'), limit=100)


** TEXT

histlabapi text , text("udeac") collection("cfpf,frus")
histlabapi text , text("udeac, asean") collection("cfpf,frus")
histlabapi text , text("league of  nations") collection("cfpf,frus")



/*
hlapi_search(c('udeac','asean'), coll.name=c('cfpf','frus'))

hlapi_search(c('udeac','asean'))
hlapi_search(c('udeac','asean'), or=TRUE)
hlapi_search(c('ford','asean'))
hlapi_search(c('asean'))

hlapi_search(c('udeac','asean'), fields=c('doc_id','title','authored','topic_titles'))
hlapi_search(c('udeac','asean'),  or=TRUE,fields=c('doc_id','title','authored','topic_titles'))
h<-hlapi_search(c('united nations'), limit = 5000, fields=c('doc_id','title'))

hlapi_search(c('league of nations'),  limit = 5000, fields=c('doc_id','title'))

hlapi_search('udeac', coll.name=c('cfpf','frus'),  start.date="1950-01-01", end.date="2000-12-31", fields=c('body'))

hlapi_search('udeac', coll.name=c('cfpf','frus'),  start.date="1974-01-01", end.date="1979-12-31")
hlapi_search('united nations', coll.name=c('cfpf','frus'),  start.date="1974-01-01", end.date="1979-12-31")
hlapi_search('united nations', coll.name=c('cfpf','frus'),  start.date="1974-01-01", end.date="1979-12-31")
*/


** ERROR TEXTS
** wrong collection
histlabapi topic, topicvalue("25") collection("uno") fields("doc_id,title,authored,topic_names")
histlabapi id , id("frus1969-76ve05p1d11") collection("un")

histlabapi text , text("udeac") fields("doc") collection("cfpf frus")


** date problems
* end date and no start date
histlabapi date, end(12/01/1948)
* start date and no end date
histlabapi date, start(12/01/1948)

* end date before start -- NEED TO CREATE ERROR
histlabapi date, start(12/01/1948) end(12/01/1947)

* date and end date
histlabapi date, date(12/01/1948) end(12/01/1947)
* date and start date
histlabapi date, start(12/01/1948) date(12/01/1947)

* malformed date
histlabapi date, date(13/15/1947)


* IDs
** wrong id - only returns correct id
histlabapi id, id("frus1969-76ve05p1d11,frus1969") fields("doc_id,body,title,topic_titles,entities")
** no results AND NO ERROR MESSAGE
histlabapi id, id("frus1969") fields("doc_id,body,title,topic_titles,entities")

* text
** no search term

histlabapi text , collection("cfpf,frus")
