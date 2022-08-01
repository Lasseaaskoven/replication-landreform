import excel "D:\Forskning og undervisning\Lensafløsningen\Election_data_with_county.xlsx", sheet("Sheet1") firstrow

*Indicator for uncontested election*
g uncontested=1 if pv1=="Uncontested"
replace uncontested=0 if uncontested==. 



*Setting uncontested elections and missing data for relevant variables to missing*
destring pev1 vot1 vv1 pv1, replace force

*Conservative vote share*
g h=pv1  if pty==17 | pty==18


*Erstat højre's andel af stemmerne med 0 hvis det ikke er en højre-kandidat*
replace h=0 if h==. 




*Checking and duplicates*
g d=1 if h!=0
bys cst id: egen sum=sum(d)


list cst_n yr if sum>1 


*Average conservative vote share*
sort cst id
by cst id: egen conservative= sum(h)

replace conservative= conservative/sum if sum>0 


*Keeping only one candidate per constituency*
sort id cst
by id cst:  gen dup = cond(_N==1,0,_n)
list cst_n yr if dup>0
keep if dup<2


*Collapsing by county and election*

collapse (sum)  conservative pev1 vot1 vv1 (mean)  yr, by( county id)


rename conservative pv1

*Addding the 1918 election*

append using "D:\Forskning og undervisning\Lensafløsningen\election_1918"


*___________________________________________________________________________________*

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




*Descriptive statistics*
xtsum conservativesupport2 turnout  logvalue millvalue logpop urbanization if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22  & county_n!=20 & election_id!=. & conservativesupport2!=. 

sum millvalue, detail

*Vizualisation: conservative vote share* 
bysort yr : egen year_mean2 = mean(conservativesupport2)

bysort yr : egen mean_non_entailed2 = mean(conservativesupport2) if net_value_current_kr==0

bysort yr : egen mean_entailed2 = mean(conservativesupport2) if net_value_current_kr!=0  


bysort yr : egen mean_above_entailed_mean = mean(conservativesupport2) if logvalue> 14.434
bysort yr : egen mean_below_entailed_mean = mean(conservativesupport2) if logvalue<= 14.434


bysort yr : egen mean_above_entailed_median = mean(conservativesupport2) if millvalue>   6.697178
bysort yr : egen mean_below_entailed_median = mean(conservativesupport2) if millvalue<= 6.697178


bysort yr : egen mean_above_entailed_m = mean(conservativesupport2) if millvalue>   17.87092
bysort yr : egen mean_below_entailed_m = mean(conservativesupport2) if millvalue<=  17.87092


twoway (line year_mean2 yr),graphregion(color(white))legend (off) ytitle(Conservative vote share) xtitle (Year) xline(1921, lstyle(grid) lcolor(gs8) lpattern(dash)) xlabel( 1866 1901 1918 1921  1929 1939),  if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22  & county_n!=20

twoway (line mean_non_entailed2 yr),graphregion(color(white))legend (off) ytitle(Conservative vote share) xtitle (Year) xline(1921, lstyle(grid) lcolor(gs8) lpattern(dash)) xlabel( 1866 1901 1918  1929 1939),  if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
 
twoway (line mean_entailed2 yr),graphregion(color(white))legend (off) ytitle(Conservative vote share) xtitle (Year) xline(1921, lstyle(grid) lcolor(gs8) lpattern(dash)) xlabel( 1866 1901 1918   1929 1939),  if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20

twoway (line year_mean2 yr),graphregion(color(white))legend (off) ytitle(Conservative vote share) xtitle (Year) xline(1915, lstyle(grid) lcolor(gs8)  lpattern(dash))  xlabel( 1866 1901 1918   1939),  if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20


twoway (line mean_non_entailed2 yr),graphregion(color(white))legend (off) ytitle(Conservative support) xtitle (Year) xline(1915, lstyle(grid) lcolor(gs8) lpattern(dash))
twoway (line mean_entailed2 yr),graphregion(color(white))legend (off) ytitle(Conservative support) xtitle (Year) xline(1915, lstyle(grid) lcolor(gs8) lpattern(dash))

twoway (line mean_above_entailed_mean yr),graphregion(color(white))legend (off) ytitle(Conservative vote share) xtitle (Year) xline(1915, lstyle(grid) lcolor(gs8) lpattern(dash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash)) xlabel(  1901 1915"Franchise"  1921 "Reform"  1929 1939),  if yr>1900 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20

twoway (line mean_below_entailed_mean yr) ,graphregion(color(white))legend (off) ytitle(Conservative vote share) xtitle (Year) xline(1915, lstyle(grid) lcolor(gs8) lpattern(dash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash)) xlabel(  1901 1915"Franchise"  1921 "Reform"  1929 1939),  if yr>1900 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20

twoway (line mean_below_entailed_mean yr,lcolor(gs8) lpattern(solid)) (line mean_above_entailed_mean yr,lcolor(gs8) lpattern(dash)),legend(lab(1 "Below mean estate value") lab(2 "Above mean estate value")) graphregion(color(white)) ytitle(Conservative vote share) xtitle("") xline(1915, lstyle(grid) lcolor(gs8) lpattern(longdash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))  ylabel( 0.1 0.2 0.3 0.4 0.5, format(%9.1f)) xlabel(  1901 1910 1915"Franchise"  1921 "Reform"  1929 1939),  if yr>1900 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22  & county_n!=20

twoway (line mean_below_entailed_median yr,lcolor(gs8) lpattern(solid)) (line mean_above_entailed_median yr,lcolor(gs8) lpattern(dash)),legend(lab(1 "Below median estate value") lab(2 "Above median estate value")) graphregion(color(white)) ytitle(Conservative vote share) xtitle("") xline(1915, lstyle(grid) lcolor(gs8) lpattern(longdash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))  ylabel( 0.1 0.2 0.3 0.4 0.5, format(%9.1f)) xlabel(  1901 1910 1915"Franchise"  1921 "Reform"  1929 1939),  if yr>1900 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22  & county_n!=20


twoway (line mean_below_entailed_m yr,lcolor(gs8) lpattern(solid)) (line mean_above_entailed_m yr,lcolor(gs8) lpattern(dash)),legend(lab(1 "Below mean estate value") lab(2 "Above mean estate value")) graphregion(color(white)) ytitle(Conservative vote share) xtitle("") xline(1915, lstyle(grid) lcolor(gs8) lpattern(longdash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))  ylabel( 0.1 0.2 0.3 0.4 0.5, format(%9.1f)) xlabel(  1901 1910 1915"Franchise"  1921 "Reform"  1929 1939),  if yr>1900 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22  & county_n!=20

twoway (line mean_below_entailed_m yr,lcolor(gs8) lpattern(solid)) (line mean_above_entailed_m yr,lcolor(gs8) lpattern(dash)),legend(lab(1 "Below mean estate value") lab(2 "Above mean estate value")) graphregion(color(white)) ytitle(Conservative vote share) xtitle("")xline(1901, lstyle(grid) lcolor(gs8) lpattern(longdash))  xline(1915, lstyle(grid) lcolor(gs8) lpattern(longdash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))  ylabel( 0.1 0.2 0.3 0.4 0.5, format(%9.1f)) xlabel( 1866 1876 1887 1895 1901"Secret ballot" 1909 1915"Franchise"  1921 "Reform"  1929 1939, angle(45)),  if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22  & county_n!=20



*Main results with cluster bootstrapped standard errors + Appendix D*
tsset, clear

bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22 & county_n!=20
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue logpop i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue fullfranchise logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
margins, dydx(fullfranchise ) at(logvalue=(0 (5) 15)) noestimcheck 
marginsplot, level(90)xtitle (Log of entailed estate value) ytitle (Effect of franchise extension) yline(0, lstyle(grid) lcolor(gs8) lpattern(dash))graphregion(color(white))legend (off) scheme(s2mono) recastci(rline) recast(line) title("") xlabel(, format(%9.2f)) ylabel(, format(%9.1f))


bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 yr##c.logvalue  logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
margins, dydx(logvalue ) over (yr) noestimcheck 
marginsplot, level(95)xtitle (Year) ytitle (Effect of entailed estate value) yline(0, lstyle(grid) lcolor(gs8) lpattern(dash))graphregion(color(white))legend (off) scheme(s2mono) recastci(rline) recast(line) title("") xlabel(, format(%9.0f)) ylabel(, format(%9.3f))

bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 i.yr#c.logvalue  logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
margins, dydx(logvalue ) over (i.yr) noestimcheck 
marginsplot, level(95)xtitle (Year) ytitle (Effect of entailed estate value) yline(0, lstyle(grid) lcolor(gs8) lpattern(dash))graphregion(color(white))legend (off) scheme(s2mono) recastci(rline) recast(line) title("") xlabel( 1865 1880 1890 1901 1910 1921 "Reform" 1930 1939, format(%9.0f)) ylabel(, format(%9.2f)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))

bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 i.yr#c.logvalue  logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
margins, dydx(logvalue ) over (i.yr) noestimcheck 
marginsplot, level(95)xtitle (Year) ytitle (Effect of entailed estate value) yline(0, lstyle(grid) lcolor(gs8) lpattern(dash))graphregion(color(white))legend (off) scheme(s2mono) recastci(rline) recast(line) title("") xlabel(, format(%9.0f)) ylabel(, format(%9.2f)) xlabel( 1865 1880 1890 1901 1910 1921 "Reform" 1930 1939, format(%9.0f)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))



bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22 & county_n!=20
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue logpop i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue fullfranchise logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 

bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout yr##c.logvalue  logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
margins, dydx(logvalue ) over (yr) noestimcheck 
marginsplot, level(95)xtitle (Year) ytitle (Effect of entailed estate value) yline(0, lstyle(grid) lcolor(gs8) lpattern(dash))graphregion(color(white))legend (off) scheme(s2mono) recastci(rline) recast(line) title("") xlabel(, format(%9.0f)) ylabel(, format(%9.3f))

bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout i.yr#c.logvalue  logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
margins, dydx(logvalue ) over (i.yr) noestimcheck 
marginsplot, level(95)xtitle (Year) ytitle (Effect of entailed estate value) yline(0, lstyle(grid) lcolor(gs8) lpattern(dash))graphregion(color(white))legend (off) scheme(s2mono) recastci(rline) recast(line) title("") xlabel(, format(%9.0f)) ylabel(, format(%9.2f)) xlabel( 1865 1880 1890 1901 1910 1921 "Reform" 1930 1939, format(%9.0f)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))

bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout i.yr#c.logvalue  logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
margins, dydx(logvalue ) over (i.yr) noestimcheck 
marginsplot, level(95)xtitle (Year) ytitle (Effect of entailed estate value) yline(0, lstyle(grid) lcolor(gs8) lpattern(dash))graphregion(color(white))legend (off) scheme(s2mono) recastci(rline) recast(line) title("") xlabel(, format(%9.0f)) ylabel(, format(%9.2f)) xlabel( 1865 1880 1890 1901 1910 1921 "Reform" 1930 1939, format(%9.0f)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))


*Not excluding 1915 election*
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue i.election_id  , absorb(county_n), if yr>1865 & yr<1940  & county_n!=6 & county_n!=22 & county_n!=20
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue logpop i.election_id  , absorb(county_n), if yr>1865 & yr<1940  
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue fullfranchise logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 

bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue i.election_id  , absorb(county_n), if yr>1865 & yr<1940  & county_n!=6 & county_n!=22 & county_n!=20
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue logpop i.election_id  , absorb(county_n), if yr>1865 & yr<1940  
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue fullfranchise logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 



*Excluding Copenhagen
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22 & county_n!=20 & county_n!=9
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue logpop i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9

bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue fullfranchise logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9



bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22 & county_n!=20 & county_n!=9
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue logpop i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9

bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue fullfranchise logpop urbanization  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9


*Footnote. Turnout with county-specific time trends*

bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logvalue logpop urbanization  i.election_id  c.election_id#i.county_n , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 



xtset county_n election_id
xtreg turnout c.post_reform##c.logvalue logpop urbanization  c.election_id#i.county_n  i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915






*Simple  diff-in-diff for conservative support (vote share)*
xtreg conservativesupport2 c.post_reform##c.logvalue i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22 & county_n!=20

xtreg conservativesupport2 c.post_reform##c.logvalue logpop i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915 

xtreg conservativesupport2 c.post_reform##c.logvalue logpop urbanization  i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport2 c.fullfranchise c.post_reform##c.logvalue logpop urbanization  i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport2 c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization  i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915



xtreg conservativesupport2 c.fullfranchise##c.logvalue c.post_reform##c.logvalue logpop urbanization  i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport2 c.post_reform##c.logvalue c.fullfranchise##c.logvalue c.election_id#i.county_n logpop urbanization  i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915


*simple diff-in-diff for turnout*
xtreg turnout c.post_reform##c.logvalue i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
xtreg turnout c.post_reform##c.logvalue logpop  i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
xtreg turnout c.post_reform##c.logvalue logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
xtreg turnout c.post_reform##c.logvalue fullfranchise logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
xtreg turnout c.fullfranchise##c.logvalue c.post_reform##c.logvalue logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

xtreg turnout c.fullfranchise##c.logvalue c.post_reform##c.logvalue c.election_id#i.county_n  logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915


bysort yr : egen above_entailed_turnout = mean(turnout) if logvalue> 14.434
bysort yr : egen below_entailed_turnout = mean(turnout) if logvalue<= 14.434



bysort yr : egen above_entailed_turnout = mean(turnout) if logvalue> 14.434
bysort yr : egen below_entailed_turnout = mean(turnout) if logvalue<= 14.434


bysort yr : egen mabove_entailed_turnout = mean(turnout) if millvalue>   17.87092
bysort yr : egen mbelow_entailed_turnout = mean(turnout) if millvalue<= 17.87092


twoway (line above_entailed_turnout yr),graphregion(color(white))legend (off) ytitle(Mean turnout rate) xtitle (Year) xline(1915, lstyle(grid) lcolor(gs8) lpattern(dash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash)) xlabel(  1901 1915"Franchise"  1921 "Reform"  1929 1939),  if yr>1900 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20

twoway (line below_entailed_turnout yr),graphregion(color(white))legend (off) ytitle(Mean turnout rate) xtitle (Year) xline(1915, lstyle(grid) lcolor(gs8) lpattern(dash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash)) xlabel(  1901 1915"Franchise"  1921 "Reform"  1929 1939),  if yr>1900 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20

twoway (line below_entailed_turnout yr,lcolor(gs8) lpattern(solid)) (line above_entailed_turnout yr,lcolor(gs8) lpattern(dash)),legend(lab(1 "Below mean estate value") lab(2 "Above mean estate value")) graphregion(color(white)) ytitle(Average turnout rate) ylabel(, format(%9.2f)) xtitle("") xline(1915, lstyle(grid) lcolor(gs8) lpattern(longdash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))  xlabel(  1901 1910 1915"Franchise"  1921 "Reform"  1929 1939),  if yr>1900 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20


twoway (line below_entailed_turnout yr,lcolor(gs8) lpattern(solid)) (line above_entailed_turnout yr,lcolor(gs8) lpattern(dash)),legend(lab(1 "Below mean estate value") lab(2 "Above mean estate value")) graphregion(color(white)) ytitle(Average turnout rate) ylabel(, format(%9.2f)) xtitle("") xline(1915, lstyle(grid) lcolor(gs8) lpattern(longdash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))  xlabel(  1901 1910 1915"Franchise"  1921 "Reform"  1929 1939),  if yr>1900 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20



twoway (line mbelow_entailed_turnout yr,lcolor(gs8) lpattern(solid)) (line mabove_entailed_turnout yr,lcolor(gs8) lpattern(dash)),legend(lab(1 "Below mean estate value") lab(2 "Above mean estate value")) graphregion(color(white)) ytitle(Average turnout rate) ylabel(, format(%9.2f)) xtitle("") xline(1915, lstyle(grid) lcolor(gs8) lpattern(longdash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))  xlabel(  1901 1910 1915"Franchise"  1921 "Reform"  1929 1939),  if yr>1900 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20

twoway (line mbelow_entailed_turnout yr,lcolor(gs8) lpattern(solid)) (line mabove_entailed_turnout yr,lcolor(gs8) lpattern(dash)),legend(lab(1 "Below mean estate value") lab(2 "Above mean estate value")) graphregion(color(white)) ytitle(Average turnout rate) xtitle("")xline(1901, lstyle(grid) lcolor(gs8) lpattern(longdash))  xline(1915, lstyle(grid) lcolor(gs8) lpattern(longdash)) xline(1921, lstyle(grid) lcolor(gs8) lpattern(longdash))  ylabel(, format(%9.1f)) xlabel( 1866 1876 1887 1895 1901"Secret ballot" 1909 1915"Franchise"  1921 "Reform"  1929 1939, angle(45)),  if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22  & county_n!=20


*Only effect of the land expropriation*
generate logland= log( land_expropriation_hectare)
replace logland=0 if land_expropriation_hectare==0

xtreg conservativesupport c.post_reform##c.logland i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
xtreg conservativesupport c.post_reform##c.logland logpop  i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
xtreg conservativesupport c.post_reform##c.logland logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
xtreg conservativesupport c.post_reform##c.logland fullfranchise logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport c.post_reform##c.logland i.election_id c.fullfranchise##c.logland  logpop urbanization, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
xtreg conservativesupport c.post_reform##c.logland c.election_id#i.county_n i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=23


xtreg conservativesupport2 c.post_reform##c.logland i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
xtreg conservativesupport2 c.post_reform##c.logland logpop  i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
xtreg conservativesupport2 c.post_reform##c.logland logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
xtreg conservativesupport2 c.post_reform##c.logland logpop urbanization fullfranchise i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport2 c.post_reform##c.logland i.election_id c.fullfranchise##c.logland , fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
xtreg conservativesupport2 c.post_reform##c.logland c.election_id#i.county_n i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20


xtreg turnout c.post_reform##c.logland i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
xtreg turnout c.post_reform##c.logland  logpop i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
xtreg turnout c.post_reform##c.logland logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940  & yr!=1915
xtreg turnout c.post_reform##c.logland fullfranchise logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915


xtreg turnout c.post_reform##c.logland  c.fullfranchise##c.logland i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
xtreg turnout c.post_reform##c.logland c.election_id#i.county_n  i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
 
 
 
 tsset, clear

bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logland i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logland  logpop  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logland logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logland fullfranchise logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.logland c.fullfranchise##c.logland logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 

bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logland  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logland  logpop  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logland logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logland fullfranchise logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.logland c.fullfranchise##c.logland logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 


 
 xtset county_n election_id
 

*Alternative measure of estate wealth. In millions of Danish kroner. Other results but not robust to the exclusion of Copenhagen*


xtreg conservativesupport2 c.post_reform##c.millvalue c.fullfranchise##c.millvalue logpop urbanization  i.election_id, fe cluster( county_n ), if yr>1865 & yr<1940 & yr!=1915 
xtreg turnout c.fullfranchise##c.millvalue c.post_reform##c.millvalue logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915 

xtreg conservativesupport2 c.post_reform##c.millvalue c.fullfranchise##c.millvalue logpop urbanization  i.election_id, fe cluster( county_n ), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9
xtreg turnout c.fullfranchise##c.millvalue c.post_reform##c.millvalue logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9

tsset, clear

bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.millvalue  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.millvalue  logpop  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.millvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.millvalue fullfranchise logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.millvalue c.fullfranchise##c.millvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 

bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.millvalue  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.millvalue  logpop  i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.millvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.millvalue fullfranchise logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 
bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.millvalue c.fullfranchise##c.millvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 


bootstrap, cluster(county_n) rep(1000) seed(123): areg  conservativesupport2 c.post_reform##c.millvalue c.fullfranchise##c.millvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9

bootstrap, cluster(county_n) rep(1000) seed(123): areg  turnout c.post_reform##c.millvalue c.fullfranchise##c.millvalue logpop urbanization i.election_id  , absorb(county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9



*From 1901 to 1939*
xtreg conservativesupport2 c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization  i.election_id, fe cluster( county_n), if yr>1900 & yr<1940 & yr!=1915 

xtreg turnout c.fullfranchise##c.logvalue c.post_reform##c.logvalue logpop urbanization i.election_id, fe cluster( county_n), if yr>1900 & yr<1940 & yr!=1915 



*Appendix: Results without fixed effects 

reg conservativesupport2 c.post_reform##c.logvalue , cluster( county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22 & county_n!=20

reg conservativesupport2 c.post_reform##c.logvalue logpop ,  cluster( county_n), if yr>1865 & yr<1940 & yr!=1915 

reg conservativesupport2 c.post_reform##c.logvalue logpop urbanization  ,  cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

reg conservativesupport2 c.fullfranchise c.post_reform##c.logvalue logpop urbanization ,  cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

reg conservativesupport2 c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization  ,  cluster( county_n), if yr>1865 & yr<1940 & yr!=1915


reg turnout c.post_reform##c.logvalue , cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
reg turnout c.post_reform##c.logvalue logpop  ,  cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
reg turnout c.post_reform##c.logvalue logpop urbanization , cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
reg turnout c.post_reform##c.logvalue fullfranchise logpop urbanization ,  cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
reg turnout c.fullfranchise##c.logvalue c.post_reform##c.logvalue logpop urbanization ,  cluster( county_n), if yr>1865 & yr<1940 & yr!=1915


*Appendix C: Exclusion of Copenhagen *
xtreg conservativesupport2 c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization  i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9

xtreg turnout c.fullfranchise##c.logvalue c.post_reform##c.logvalue logpop urbanization i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915 & county_n!=9

*With bootstrapped standard errors instead*

xtreg conservativesupport2 c.post_reform##c.logvalue i.election_id, fe vce( bootstrap), if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22 & county_n!=20

xtreg conservativesupport2 c.post_reform##c.logvalue logpop i.election_id, fe vce( bootstrap), if yr>1865 & yr<1940 & yr!=1915 

xtreg conservativesupport2 c.post_reform##c.logvalue logpop urbanization  i.election_id, fe vce( bootstrap), if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport2 c.fullfranchise c.post_reform##c.logvalue logpop urbanization  i.election_id, fe vce( bootstrap), if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport2 c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization  i.election_id, fe vce( bootstrap), if yr>1865 & yr<1940 & yr!=1915


xtreg turnout c.post_reform##c.logvalue i.election_id, fe vce( bootstrap), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
xtreg turnout c.post_reform##c.logvalue logpop  i.election_id, fe vce( bootstrap), if yr>1865 & yr<1940 & yr!=1915
xtreg turnout c.post_reform##c.logvalue logpop urbanization i.election_id, fe vce( bootstrap), if yr>1865 & yr<1940 & yr!=1915
xtreg turnout c.post_reform##c.logvalue fullfranchise logpop urbanization i.election_id, fe vce( bootstrap), if yr>1865 & yr<1940 & yr!=1915
xtreg turnout c.fullfranchise##c.logvalue c.post_reform##c.logvalue logpop urbanization i.election_id, fe vce( bootstrap), if yr>1865 & yr<1940 & yr!=1915


bootstrap: xtreg conservativesupport2 c.post_reform##c.logvalue i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22 & county_n!=20

bootstrap: xtreg conservativesupport2 c.post_reform##c.logvalue logpop i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915 

bootstrap: xtreg conservativesupport2 c.post_reform##c.logvalue logpop urbanization  i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915

bootstrap: xtreg conservativesupport2 c.fullfranchise c.post_reform##c.logvalue logpop urbanization  i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915

bootstrap:xtreg conservativesupport2 c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization  i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915


bootstrap: xtreg turnout c.post_reform##c.logvalue i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
bootstrap: xtreg turnout c.post_reform##c.logvalue logpop  i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915
bootstrap:xtreg turnout c.post_reform##c.logvalue logpop urbanization i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915
bootstrap: xtreg turnout c.post_reform##c.logvalue fullfranchise logpop urbanization i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915
bootstrap: xtreg turnout c.fullfranchise##c.logvalue c.post_reform##c.logvalue logpop urbanization i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915




*Without clustered standard errors*
xtreg conservativesupport2 c.post_reform##c.logvalue i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915 & county_n!=6 & county_n!=22 & county_n!=20

xtreg conservativesupport2 c.post_reform##c.logvalue logpop i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915 

xtreg conservativesupport2 c.post_reform##c.logvalue logpop urbanization  i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport2 c.fullfranchise c.post_reform##c.logvalue logpop urbanization  i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport2 c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization  i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915


xtreg turnout c.post_reform##c.logvalue i.election_id, fe  , if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20
xtreg turnout c.post_reform##c.logvalue logpop  i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915
xtreg turnout c.post_reform##c.logvalue logpop urbanization i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915
xtreg turnout c.post_reform##c.logvalue fullfranchise logpop urbanization i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915
xtreg turnout c.fullfranchise##c.logvalue c.post_reform##c.logvalue logpop urbanization i.election_id, fe , if yr>1865 & yr<1940 & yr!=1915





*Alternative diff-in-diff for conservative support (share of eligable voters)*
xtreg conservativesupport c.post_reform##c.logvalue i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915  & county_n!=6 & county_n!=22 & county_n!=20

xtreg conservativesupport c.post_reform##c.logvalue i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
xtreg conservativesupport fullfranchise logpop urbanization c.post_reform##c.logvalue i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
xtreg conservativesupport fullfranchise logpop urbanization c.post_reform##c.logvalue i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915
xtreg conservativesupport c.fullfranchise##c.logvalue logpop urbanization c.post_reform##c.logvalue i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport logpop urbanization c.fullfranchise##c.logvalue c.post_reform##c.logvalue i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport c.post_reform##c.logvalue c.election_id#i.county_n i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

xtreg conservativesupport c.post_reform##c.logvalue c.fullfranchise##c.logvalue logpop urbanization c.election_id#i.county_n i.election_id, fe cluster( county_n), if yr>1865 & yr<1940 & yr!=1915

*Visual over over time*
bysort yr : egen year_mean = mean(conservativesupport)

bysort yr : egen mean_non_entailed = mean(conservativesupport) if net_value_current_kr==0

bysort yr : egen mean_entailed = mean(conservativesupport) if net_value_current_kr!=0

twoway (line year_mean yr),graphregion(color(white))legend (off) ytitle(Conservative support) xtitle (Year) xline(1921, lstyle(grid) lcolor(gs8) lpattern(dash))

twoway (line mean_non_entailed yr),graphregion(color(white))legend (off) ytitle(Conservative support) xtitle (Year) xline(1921, lstyle(grid) lcolor(gs8) lpattern(dash))

twoway (line mean_entailed yr),graphregion(color(white))legend (off) ytitle(Conservative support) xtitle (Year) xline(1919, lstyle(grid) lcolor(gs8) lpattern(dash))

twoway (line year_mean yr),graphregion(color(white))legend (off) ytitle(Conservative support) xtitle (Year) xline(1915, lstyle(grid) lcolor(gs8) lpattern(dash))

twoway (line mean_non_entailed yr),graphregion(color(white))legend (off) ytitle(Conservative support) xtitle (Year) xline(1915, lstyle(grid) lcolor(gs8) lpattern(dash))
twoway (line mean_entailed yr),graphregion(color(white))legend (off) ytitle(Conservative support) xtitle (Year) xline(1915, lstyle(grid) lcolor(gs8) lpattern(dash))

