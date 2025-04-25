** AND
* http://api.foiarchive.org/documents?full_text=wfts.udeac%20asean&select=doc_id,title,authored,topic_names&limit=25
** OR
* http://api.foiarchive.org/documents?full_text=wfts.udeac%20or%20asean&select=doc_id,title,authored,topic_names&limit=25
capture program drop date_parse
capture program drop histlabapi
capture program drop get_id
capture program drop get_entity
capture program drop get_date
capture program drop get_text
capture program drop get_overview
capture program drop hlreshape
mata mata clear
** TO ADD:
*** multiple entities


*program drop histlabapi

program define clean_local , rclass 
args localvals
nois di "`localvals'"
local localvals : subinstr local localvals ", " ",", all
local localvals : subinstr local localvals " " "," , all
nois di "`localvals'"
return local localvals = "`localvals'"
end

program define histlabapi , rclass
syntax anything(name=option),  [ date(string) start(string) end(string)  text(string) id(string) COLlection(string) fields(string) entitytype(string) entityvalue(string) topicvalue(string) sort(string) overview(string) LIMit(int 25) orlist(string) norun]

	if ~regexm("`option'","^(id|date|text|entity|overview|topic)$") {
		nois di as error "`option' is not a valid option. Allowable options are id, date, text, entity, topics, and overview."
		exit
	}

	if (("`start'"~="" & "`end'"=="")|("`start'"=="" & "`end'"~="")){
		nois di as error "Please specify both a start and end date."
		exit
	}

	*** Checking inputs 
	if !inlist("`orlist'","or","and","") {
	    nois display as error "`orlist' is not recognized. Acceptable values are 'or' and 'and'"
	}

	if "`collection'"~="" {
		local collection : subinstr local collection ", " ",", all
		local collection : subinstr local collection " " "," , all
		*mata: check_collections("`collection'")
		mata: check_categories("`collection'", validcollections)
		if(scalar(ck)==0) {
			*nois di as error  "At least one of the collections you entered is incorrect"
			exit
		} 
	}

	if "`entitytype'"~="" {
		if "`collection'"!="" nois display as error "Entity type cannot be combined with a collection. Ignoring collection."
		local collection = ""
		local entitytype : subinstr local entitytype ", " ",", all
		local entitytype : subinstr local entitytype " " "," , all
		mata: check_categories("`entitytype'", validentities)
		if(scalar(ck)==0) {
			*nois di as error  "At least one of the entity types you entered is incorrect"
			exit
		} 
	}

	if "`fields'"~="" {
		local fields : subinstr local fields ", " ",", all
		local fields : subinstr local fields " " "," , all
		mata: check_categories("`fields'", validfields)
		if(scalar(ck)==0) {
			exit
		} 
		} 
		else if "`fields'"=="" {
			local fields = "doc_id,authored,title"
	}

	if "`limit'"=="0" & regexm("`option'","^(date|text|entity)$") {
		nois di "You did not specifiy a page limit. Defaulting to 25 results."
		local limit="25"
	}

	** SPECIFIC SEARCHES
	** overview search

	if "`option'"=="overview" {
		get_overview "`overview'" "`sort'" "`entitytype'"
		local search = r(search)
		if "`search'"=="" | "`search'"=="." exit
			}	

	** search by ID
	if "`option'"=="id" {
		if "`collection'"!="" nois display as error "Id search cannot be combined with a collection. Ignoring collection."
		local collection = ""
		get_id "`id'"
		local search = r(search)
		if "`search'"=="" | "`search'"=="." exit
	}

	** search by date
	if "`option'"=="date" {
		get_date "`date'" "`start'" "`end'" 
		local search = r(search)
		if "`=r(search)'"=="" exit
		if "`search'"=="" | "`search'"=="." exit
	}

	** full text search
	if "`option'"=="text" {
		get_text "`text'" "`date'" "`start'" "`end'" "`orlist'"
		local search = r(search)
		if "`search'"=="" | "`search'"=="." exit
	}

	** entity search
	if "`option'"=="entity" {
		get_entity "`entityvalue'" "`start'" "`end'" "`date'" "`orlist'"
		local search = r(search)
		if "`search'"=="" | "`search'"=="." exit
	}

	** topic search
	if "`option'"=="topic" {
		get_topics "`topicvalue'" "`start'" "`end'" "`date'" "`orlist'"
		local search = r(search)
		if "`search'"=="" | "`search'"=="." exit
	}

	** add collection - only id and overview-entities can not have collection
	if "`collection'"!="" local search = "`search'&corpus=in.(`collection')"

	** adding fields if search is not overview
	if "`option'"!="overview" local search = "`search'"+"&select=`fields'"
	
	** set limit
	if !inlist("`option'","id") if "`limit'"~="" local search = "`search'"+"&limit=`limit'"

			
qui{
clear
local url ="https://api.foiarchive.org/"
local url = "`url'`search'"
nois display "`url'"

if `c(version)'>=16{
    nois di "Using Python to parse JSON"
	python: from __main__ import HLjson
    python: HLjson("`url'")
}

if "`run'"=="" & `c(version)'<16 {
	mata: hl_api("`url'")
	compress
	hlreshape
}

}

end


*** SUBPROGRAMS
program def find_wiki_id , rclass
	args entities
	local url = "https://api.foiarchive.org/"
	local search = "entities?entity=ilike.*`entities'*&select=entity,entgroup,wikidata_id,doc_cnt"

	local url = "`url'`search'&order=doc_cnt.desc"
	*return(hlresults(url))
	return local url = "`url'"
	clear
	python: from __main__ import HLjson
    python: HLjson("`url'")
	*mata: hl_api("`url'")
	*compress
	*qui hlreshape

end

program def find_topic_id , rclass
	args topics
	local topics = "`=strlower("`topics'")'"
	nois di "`topics'"
	local url = "https://api.foiarchive.org/"
	local search = "topics?name=ilike.*`topics'*&select=corpus,topic_id,title,name"

	local url = "`url'`search'"
	*return(hlresults(url))
	return local url = "`url'"
	clear
	python: from __main__ import HLjson
    python: HLjson("`url'")
	*mata: hl_api("`url'")
	qui compress
	*qui hlreshape
end

program define get_entity , rclass
	args  entityvalue start end date  orlist
	if "`entityvalue'"=="" {
	    nois display as error "{p}Please enter a Wikidata ID for an entity search.{p_end}"
		exit
	}
	if "`orlist'"=="or" local or = "ov"
	if ("`orlist'"=="and"|"`orlist'"=="") local or = "cs"
	  
	local search = "documents?wikidata_ids=`or'.{`entityvalue'}"
	*if "`collection'"!="" local search = "`search'&corpus=eq.`collection'"

	if "`date'"!="" {
		date_parse `date'
		if "`=r(d)'"=="."  exit
		local search = "`search'&authored=eq.`=r(d)'"	
	}
	if "`start'"!="" {
		date_parse `start'
		if "`=r(d)'"=="."  exit
		local search = "`search'&authored=gte.`=r(d)'"	
	}

	if "`end'"!="" {
		date_parse `end'
		if "`=r(d)'"=="."  exit
		local search = "`search'&authored=lte.`=r(d)'"	
	}

	return local search = "`search'"

end


program define get_topics , rclass
	args  topicvalue start end date  orlist
	if "`topicvalue'"=="" {
	    nois display as error "{p}Please enter a topic ID for a topics search.{p_end}"
		exit
	}
	if "`orlist'"=="or" local or = "ov"
	if ("`orlist'"=="and"|"`orlist'"=="") local or = "cs"
	  
	local search = "documents?topic_ids=`or'.{`topicvalue'}"
	*if "`collection'"!="" local search = "`search'&corpus=eq.`collection'"

	if "`date'"!="" {
		date_parse `date'
		if "`=r(d)'"=="."  exit
		local search = "`search'&authored=eq.`=r(d)'"	
	}
	if "`start'"!="" {
		date_parse `start'
		if "`=r(d)'"=="."  exit
		local search = "`search'&authored=gte.`=r(d)'"	
	}

	if "`end'"!="" {
		date_parse `end'
		if "`=r(d)'"=="."  exit
		local search = "`search'&authored=lte.`=r(d)'"	
	}

	return local search = "`search'"

end


program define get_text, rclass
	args text date start end orlist
	** Multiple terms
	if "`text'"=="" {
	    nois di as error "Please enter text to search for."
		exit
	}
	local text : subinstr local text ", " ",", all
	** Phrases
	if inlist("`orlist'","and","") local ort = "and"
	if "`orlist'"=="or" local ort = "or"

	local search = "documents?`ort'=("
	tokenize "`text'" , parse(",")
	while "`1'"!="" {
	if "`1'"!="," {
		if ustrregexm("`1'","\s+") {
			local psearch = "`psearch'full_text.phfts.`:subinstr local 1 " " "%20", all',"
		}
		else {
			local tsearch = "`tsearch'full_text.wfts.`1',"
		}
	}
	macro shift
	}
	local psearch = "`=regexr("`psearch'",",$","")'"
	local tsearch = "`=regexr("`tsearch'",",$","")'"
	if "`psearch'"=="" 	local search = "`search'`tsearch')"
	if "`tsearch'"=="" 	local search = "`search'`psearch')"
	if "`psearch'"!=""&"`tsearch'"!="" 	local search = "`search'`psearch',`tsearch')"

	if "`date'"!="" {
		date_parse `date'
		if "`=r(d)'"=="."  exit
			local search = "`search'&authored=eq.`=r(d)'"	
	}
	if "`start'"!="" {
		date_parse `start'
		if "`=r(d)'"=="."  exit
		local search = "`search'&authored=gte.`=r(d)'"	
	}

	if "`end'"!="" {
		date_parse `end'
		if "`=r(d)'"=="."  exit
		local search = "`search'&authored=lte.`=r(d)'"	
	}
	
	return local search = "`search'"

end

program define get_overview, rclass
	args overview sort entitytype

	if "`overview'"=="" {
	    nois di as error "Please specify an option for the overview search. Allowable options are entities, topics, or collections."
		exit
	}
	if "`overview'"!="" {
		if ustrregexm("`overview'", ",|\s+"){
			nois di as error "Only one overview option is allowed."
			exit
		}
		if !ustrregexm("`overview'", "^(entities|topics|collections)$"){
			nois di as error "`overview' is not a valid overview option. Allowable options are entities, topics, or collections."
			exit
		}
	}
	
	if "`overview'"=="entities" {
		local search = "entities?"
		if "`entitytype'"!="" {
		if ustrregexm("`entitytype'",",") {
		    local search = "`search'&entgroup=in.(`entitytype')"
		}
		else {
		    local search = "`search'&entgroup=eq.`entitytype'"
		}
		}
		if "`sort'"~="" { 
			if !inlist("`sort'","A","D","N") {
				nois di as error "{p}`sort' is not a valid sort option. Allow sort options are A, D, and N."
				exit 
			} 
		else {
			if "`sort'"=="A" local search = "`search'"+ "&order=doc_cnt.asc"
			if "`sort'"=="D" local search = "`search'"+ "&order=doc_cnt.desc"
		}
		local search = "`search'&select=entity,entgroup,wikidata_id,doc_cnt"
	} 

	}
	if "`overview'"=="collections" local search = "corpora?select=corpus,title,begin_date,end_date,doc_cnt,pg_cnt,word_cnt,topic_cnt"
	if "`overview'"=="topics" local search = "topics?"
	return local search = "`search'"
	end


program define get_id , rclass
	args id  
	if "`id'"=="" {
		nois di as error "You selected the id option but provided no ids. Please list ids, separated by a comma."
		exit
	}
	local id : subinstr local id ", " ",", all
	local id : subinstr local id " " "," , all
	local search = "documents?"
	if "`id'"~="" local search = "`search'"+"doc_id=in.(`id')"
	return local search = "`search'"
end


program define get_date , rclass
args date start end 
		if ("`date'"=="" & ("`start'"=="" & "`end'"=="")) {
			nois di as error "You selected the date option but provided no dates. Please list a date or a start and end date."
			exit
		}
		if (("`start'"~="" & "`end'"=="")|("`start'"=="" & "`end'"~="")){
			nois di as error "Please specify both a start and end date."
			exit
		}
		foreach _d in date start end {
			if "``_d''"~="" {
				date_parse ``_d''
				if "`=r(d)'"=="." {
					exit
				}
				local `=substr("`_d'",1,1)' = "`=r(d)'"
				}
			}
			if ("`d'"==""&"`s'"==""&"`e'"=="") exit
			local search  "documents?"
			if "`date'"~="" local search = "`search'"+"authored=eq.`d'"
			if "`start'"~="" & "`end'"~="" local search = "`search'"+"authored=gte.`s'&authored=lte.`e'"

	return local search = "`search'"
end



program define date_parse , rclass
syntax anything
			if !ustrregexm("`anything'","^\d+(\.|\-|/)\d+(\.|\-|/)\d+$") {
			    nois di as error "Please format the date in numeric format with .,\, or - separators between each part."
				exit
			}
local d = ustrregexra("`anything'","(\.|\-|/)"," ",.)
tokenize `d'
local yr = ""
local mo = ""
local day = ""
if length("`3'")==4 {
    local yr = `3'
	if `1' >12 {
	    local day = `1'
		local mo = `2'
	}
	else if `1'<13 {
	    local mo = `1'
		local day = `2'
	}
}
else if length("`1'")==4 {
    local yr = `1'
		if `3' >12 {
	    local day = `3'
		local mo = `2'
	}
	else if `2'<13 {
	    local mo = `2'
		local day = `3'
	}
}
else if length("`2'")==4 {
local yr = `2'
		if `1' >12 {
	    local day = `1'
		local mo = `3'
	}
	else if `1'<13 {
	    local mo = `1'
		local day = `3'
	}

}
if "`yr'"=="" {
	nois di as error "Please provide a 4-digit year value."
	exit
} 

if `=date("`yr'-`mo'-`day'", "YMD")'==. {
    nois di as error "`anything' is not a valid date"
	exit
}
if length("`mo'")<2 local mo = "0"+"`mo'"
if length("`day'")<2 local day = "0"+"`day'"
return local d =  "`yr'-`mo'-`day'"
end

program define hlreshape , 
	//syntax anything
	replace value = trim(itrim(value))
	replace value = subinstr(value,"]}]","",.)
	replace value = subinstr(value,`""}]"',"",.)


	replace value = subinstr(value,`""|""',`"",""',.)
	replace value = subinstr(value,`"null|"',`"null,"',.)
	replace value = subinstr(value,`"|null"',`",null"',.)

	replace value = `"""'+value if ustrregexm(value,`""$"')
	replace value = `"""'+value if ustrregexm(value,"null$")


	replace key = ustrregexra(key,"(.+\{)|(:.+)","")
	replace key = subinstr(key,`"""',"",.)

	drop if value==""
	gen n = _n
	bysort rownum key (n): gen ct = _n
	sort n
	qui tab rownum 
	local r=`r(r)'
	if `r'==1 {
		drop n nested rownum
		reshape wide value ,i(ct) j(key) string
	drop ct
		}

	if `r'>1 {
		replace key = cond(nested!="0",key+string(ct),key)
		drop n nested ct
		reshape wide value ,i(rownum) j(key) string
		drop rownum
	}
		rename value* *
end


*** MATA SECTION

mata

validfields = "authored", "body", "wikidata_ids", "entgroups", "entities", "topic_titles", "topic_names", "topic_scores", "topic_ids", "title", "classification", "corpus", "doc_id"
validcollections = "frus","cia","clinton","briefing","cfpf","kissinger","nato","un","worldbank","cabinet","cpdoc"
validentities = "PERSON","ORG","LOC","GOVT","OTHER"

void function check_categories(string scalar f, string rowvector validcats) {
	tok = tokens(f,",")
	for (i=1;i<=length(tok);i++) {
		if (tok[i]!=",") {
			ck = anyof(validcats,tok[i])
			if (ck==0) errprintf("Unknown category: %s\n", tok[i])
			if (ck==0) break
		}
	}
	st_numscalar("ck", ck)
}


void function hladdobs(string matrix text) {
	// Add rows to Stata equal to returned number of results 
	st_addobs(rows(text))
	varnames = ("key","value","rownum","nested")
	varidx  = st_addvar("strL",varnames)
	st_sstore(.,varidx,text)
}

string scalar hl_read_json(string scalar url) {
	string scalar line, partial, combined
	partial = ""
	combined = ""
	f = fopen(url, "r")
	if (f < 1) {
		errprintf("Error: Unable to open URL: %s\n", url)
		exit(1)
	}
	while ((line=fget(f))!=J(0,0,"")) {
		line=strtrim(line)
		if (!regexm(line,"(\]},$)|(\]}$)|(}\]}\]$)|(},$)|(}\]$)")) {
			partial = partial+ " " + line
			continue
		} else {
				line = partial+" "+line
				partial=""
		}
		line=subinstr(line,`"":null}"',`"":"null"}"')
		line=subinstr(line,`"":null,"',`"":"null","')
		if (ustrregexm(strtrim(line),`"(.+":)(\d+)(.+)"')) line = ustrregexs(1) + `"""'+ustrregexs(2)+`"""'+ustrregexs(3)
		combined = combined + line
	}
	fclose(f)
	return(strtrim(combined))
}



void hl_api(string scalar url) {

	maindataset = hl_read_json(url)

	zt =tokeninit("",(`"",""',`""}, {""',"],"),"")
	zto=tokeninit("",(`"":""',`"":[]"',`"":[""'),"")

text =J(0,4,"")
j = 1
n=1
k=0
if (ustrregexm(maindataset,"\]\}\]$")) {
maindataset=strtrim(maindataset)
maindataset = ustrregexrf(maindataset,"^\[","")
z =tokeninit("",(`"]}, {"',"}, {"),"")
tokenset(z,maindataset)
while((token = tokenget(z)) != "") {
	
	u = " "
	test = token
	while(u!="") {
	u = ustrregexm(test,"((\[|^).+)(\[.+\])") ? ustrregexs(3) : ""
	if(u=="") u = ustrregexm(test,"((\[|^).+)(\[.+)") ? ustrregexs(3) : ""
	test = subinstr(test,u,"")
	u2 = subinstr(u,",","|",.)
	token = subinstr(token,u,u2)
	}
		tokenset(zt, token)
		while((tok = tokenget(zt)) != "") {
		if (tok~=`"",""'&tok!=`""}, {""'&tok!="],"&tok!=""&tok!="]}, {") {
		tokenset(zto,tok)
		xt=tokengetall(zto)
		if (regexm(xt[1,1],"\[{")&n>1) k=1
		if (length(xt)==3) x2 = xt[1,1],xt[1,3],strofreal(j),strofreal(k)
		if (length(xt)==1) x2 = xt[1,1],"",strofreal(j),strofreal(k)
	if (k!=0) ++k
		if (regexm(x2[1,2],"}")) k=0
		++n
	text = text\x2
		}
	}
	++j
	
}

} else  {
z =tokeninit("",`""},"',"")
zt =tokeninit("",(`"",""',`""}, {""',"],"),"")
zto=tokeninit("",(`"":""',`"":[]"'),"")
tokenset(z,maindataset)
while((token = tokenget(z)) != "") {
tokenset(zt,token)
while((nt = tokenget(zt)) != "") {
	if (nt==`"",""'|nt==`""},"') {
	continue
	} else {
	tokenset(zto,nt)
	nt2=tokengetall(zto)
	nt3 = nt2[1,1],nt2[1,3],strofreal(j),"0"
text=text\nt3
	}
}
}
}

text[,2] = regexr(text[,2],`"(]},$)|("},$)|(},$)"',"")
text[,2] = regexr(text[,2],`"("}$)|("}\]}\])"',"")
text[,1] = regexr(text[,1],`"(^{")"',"")
hladdobs(text)
}

	end



*** PYTHON
if `c(version)'>=16{
python
from sfi import Data, SFIToolkit, Scalar
import pandas as pd
import requests
import json
def HLjson(url):
	df  = pd.read_json(json.dumps(requests.get(url).json()))
	Data.setObsTotal(len(df))
	colnames = df.columns
	for i in range(len(colnames)):
		dtype =df.dtypes[i].name
		varname = SFIToolkit.makeVarName(colnames[i])
		varval = df[colnames[i]].values.tolist()
		if dtype == "int64":
			Data.addVarInt(varname)
			Data.store(varname,None,varval)
		if dtype == "float64":
			Data.addVarDouble(varname)
			Data.store(varname,None,varval)
		if dtype == "bool":
			Data.addVarByte(varname)
			Data.store(varname,None,varval)
		if (dtype!="int64" and dtype!="float64" and dtype!="bool"):
			Data.addVarStrL(varname)
			s = [str(i) for i in varval]
			Data.store(varname,None,s)
end
}
