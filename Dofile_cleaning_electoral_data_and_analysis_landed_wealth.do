import excel "D:\Forskning og undervisning\Lensafløsningen\Election_data_with_county_2.xlsx", sheet("Sheet1") firstrow


*Removal of non-conservative parties/candidates*
keep if pty==17 | pty==18


*Checking and removal of duplicates (instances of more than one candidates), since we are only interested in party-level data*
sort id cst
by id cst:  gen dup = cond(_N==1,0,_n)
list cst_n yr if dup>0
keep if dup<2

*Setting uncontested elections and missing data for relevant variables to missing*
destring pev1 vot1 vv1 pv1, replace force

*Collapsing by county and election*

collapse (sum) pev1 vot1 vv1 pv1 (mean) yr, by( county id)



*Addding the 1918 election*

append using "D:\Forskning og undervisning\Lensafløsningen\election_1918_2", force


*___________________________________________________________________________________*

*Merging with majorat data and initial data analysis*


*Merging of majorat data*

merge m:1 county using "D:\Forskning og undervisning\Lensafløsningen\majorat_data_county_2"

drop _merge

*Setting majorat data from missing to 0*

replace net_value_current_kr=0 if net_value_current_kr==.   
replace government_land_fund_kr=0 if government_land_fund_kr==.
replace successor_foundation_kr=0 if successor_foundation_kr==.   
replace owners_share_kr=0 if  owners_share_kr==.
replace land_expropriation_hectare=0 if land_expropriation_hectare==. 


*Merging of population data*

merge m:1 county yr using "D:\Forskning og undervisning\Lensafløsningen\population_data_2"

drop _merge

*Merging with landed wealth data*

merge m:1 county using "D:\Forskning og undervisning\Lensafløsningen\landed_wealth.dta"
 
 
 
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

*Alternative post reform dummy (before Supreme Court decision)*
generate post_reform2=0
replace post_reform2=1 if yr>1919

*Full franchise variable*
generate fullfranchise=0
replace fullfranchise=1 if yr>1915

*Secret ballot variable*
generate secret_ballot=0
replace secret_ballot=1 if yr>1900

*Generation of a turnout variable*
generate n_votes= vv1
replace n_votes= vot1 if vv1==0
replace n_votes=. if vot1==0 & vv1==0 

generate turnout= n_votes/pev1 

*Generation of conservative support variable (share of eligable voters)*
generate conservativesupport= pv1/ pev1

*Generation of  measure of conservative electoral support (share of votes)*
generate conservativesupport2= pv1/n_votes




*Generate entailed estate wealth as a share of total rural wealth*


generate entailed_wealth_share= net_value_current_kr/(1000*total_landed_wealth_1916_1000_dk)




*Appendix C*
tsset, clear

bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.entailed_wealth_share i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22 & county_n!=20
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.entailed_wealth_share logpop i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.entailed_wealth_share logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 



bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.entailed_wealth_share i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22 & county_n!=20
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.entailed_wealth_share logpop i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.entailed_wealth_share logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 



