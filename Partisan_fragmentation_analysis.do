
import excel "D:\Forskning og undervisning\Lensafløsningen\Election_data_with_county.xlsx", sheet("Sheet1") firstrow


replace pty=17 if pty==18

*Setting uncontested elections and missing data for relevant variables to missing*
destring pev1 vot1 vv1 pv1, replace force

*Collapsing by county, party and election*

collapse (sum) pev1 vot1 vv1 pv1 (mean) yr, by( pty county id)

*Adding the 1918 elections for the 4 parties*
append using "D:\Forskning og undervisning\Lensafløsningen\cons1918", force 
append using "D:\Forskning og undervisning\Lensafløsningen\radikal1918", force 
append using "D:\Forskning og undervisning\Lensafløsningen\soc1918", force 
append using "D:\Forskning og undervisning\Lensafløsningen\venstre1918", force 

replace id=198.5 if id==.


*Generation of numeric variables*
encode county, gen(county_n)

rename pty party_numeric


*Generation of voting variables 
generate n_votes= vv1
replace n_votes= vot1 if vv1==0
replace n_votes=. if vot1==0 & vv1==0 

generate turnout= n_votes/pev1 



*Generation of  measure of  electoral support (share of votes)*
generate voteshare= pv1/n_votes






sort  county_n party_numeric id


generate county_n_n=. 
replace county_n_n= 7 if county_n==1
replace county_n_n= 11 if county_n==2
replace county_n_n= 13 if county_n==3
replace county_n_n= 17 if county_n==4
replace county_n_n= 19 if county_n==5
replace county_n_n= 23 if county_n==6
replace county_n_n= 29 if county_n==7
replace county_n_n= 31 if county_n==8
replace county_n_n= 37 if county_n==9
replace county_n_n= 41 if county_n==10
replace county_n_n= 43 if county_n==11
replace county_n_n= 47 if county_n==12
replace county_n_n= 53 if county_n==13
replace county_n_n= 59 if county_n==14
replace county_n_n= 61 if county_n==15
replace county_n_n= 67 if county_n==16
replace county_n_n= 71 if county_n==17
replace county_n_n= 73 if county_n==18
replace county_n_n= 79 if county_n==19
replace county_n_n= 83 if county_n==20
replace county_n_n= 89 if county_n==21
replace county_n_n= 97 if county_n==22
replace county_n_n= 101 if county_n==23




generate county_party = county_n_n * party_numeric 


*Checking and removal of duplicates (instances of more than one candidates), since we are only interested in party-level data*
sort id county_party
by id county_party:  gen dup = cond(_N==1,0,_n)
list county_party yr if dup>0
keep if dup==0

sort  county_n party_numeric id

replace id= id+1 if id>198.5
replace id= id+0.5 if id==198.5

xtset county_party id


generate vote_share_squared= voteshare^2



collapse (sum) vote_share_squared (mean) yr, by( county id)




*Merging with majorat data and initial data analysis*


*Merging of majorat data*

merge m:1 county using "D:\Forskning og undervisning\Lensafløsningen\majorat_data_county"

drop _merge

*Setting majorat data from missing to 0*

replace net_value_current_kr=0 if net_value_current_kr==.   
replace government_land_fund_kr=0 if government_land_fund_kr==.
replace successor_foundation_kr=0 if successor_foundation_kr==.   
replace owners_share_kr=0 if  owners_share_kr==.
replace land_expropriation_hectare=0 if land_expropriation_hectare==. 


*Merging of population data*

merge m:1 county yr using "D:\Forskning og undervisning\Lensafløsningen\population_data"

drop _merge


 
*Generation of log of entailed value*
generate logvalue= log(net_value_current_kr)
replace logvalue=0 if net_value_current_kr==0

*Generation of millions of estate values
generate millvalue= net_value_current_kr/1000000

*Generation of numeric county variable*
encode county, gen(county_n)


*Dropping irrelevant county-election*
drop if county_n==1 


*generate new id*
generate election_id= id*10 


*Generation of log of population*
generate logpop= log(pop_total)

*generate urbanization*
 generate urbanization= pop_city /pop_total

*setting time frame*
xtset county_n election_id


 *Generate post reform dummy*
generate post_reform=0
replace post_reform=1 if yr>1920
 

 
*setting time frame*
xtset county_n id



*Electoral volatility analysis*
tsset, clear

bootstrap, cluster(county_n) rep(1000) seed(123): areg  vote_share_squared  c.post_reform##c.logvalue i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915   & county_n!=6 & county_n!=21 & county_n!=24
bootstrap, cluster(county_n) rep(1000) seed(123): areg  vote_share_squared  c.post_reform##c.logvalue logpop i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915
bootstrap, cluster(county_n) rep(1000) seed(123): areg  vote_share_squared  c.post_reform##c.logvalue logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 


