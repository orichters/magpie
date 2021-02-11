*** |  (C) 2008-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

*' @equations
*' The interface `vm_land` provides aggregated natveg land pools (`ac`) to other modules.

 q35_land_secdforest(j2) .. vm_land(j2,"secdforest") =e= sum(ac, v35_secdforest(j2,ac));

 q35_land_other(j2) .. vm_land(j2,"other") =e= sum(ac, v35_other(j2,ac));

*' Carbon stocks for primary forest, secondary forest or other natural land are calculated
*' as the product of respective area and carbon density.
*' Carbon stocks decline if the area decreases
*' (e.g. due to cropland expansion into forests).
*' In case of abandoned agricultural land (increase of other natural land),
*' natural succession, represented by age-class growth, results in increasing carbon stocks.

 q35_carbon_primforest(j2,ag_pools) .. vm_carbon_stock(j2,"primforest",ag_pools) =e=
           vm_land(j2,"primforest")
           *sum(ct, fm_carbon_density(ct,j2,"primforest",ag_pools));

 q35_carbon_secdforest(j2,ag_pools) .. vm_carbon_stock(j2,"secdforest",ag_pools) =e=
           sum(ac, v35_secdforest(j2,ac)
           *sum(ct, pm_carbon_density_ac(ct,j2,ac,ag_pools)));

 q35_carbon_other(j2,ag_pools)  .. vm_carbon_stock(j2,"other",ag_pools) =e=
           sum(ac, v35_other(j2,ac)
           *sum(ct, pm_carbon_density_ac(ct,j2,ac,ag_pools)));


*' NPI/NDC land protection policies are implemented as minium forest land and other land stock.

 q35_min_forest(j2) .. vm_land(j2,"primforest") + vm_land(j2,"secdforest")
                       =g=
 									     sum(ct, p35_min_forest(ct,j2));

 q35_min_other(j2) .. vm_land(j2,"other") =g= sum(ct, p35_min_other(ct,j2));

*' The following technical calculations are needed for reducing differences in land-use patterns between time steps.
*' The gross change in natural vegetation is calculated based on land expansion and
*' land contraction of other land, and land reduction of primary and secondary forest.
*' This information is then passed to the land module ([10_land]):

 q35_landdiff .. vm_landdiff_natveg =e=
 					sum((j2,ac),
 							v35_other_expansion(j2,ac)
 						  + v35_other_reduction(j2,ac)
 						  + v35_secdforest_expansion(j2,ac)
 						  + v35_secdforest_reduction(j2,ac)
 						  + v35_primforest_reduction(j2));

 q35_other_expansion(j2,ac_est) ..
 	v35_other_expansion(j2,ac_est) =e=
 		v35_other(j2,ac_est) - pc35_other(j2,ac_est);

 q35_other_reduction(j2,ac_sub) ..
 	v35_other_reduction(j2,ac_sub) =e=
 		pc35_other(j2,ac_sub) - v35_other(j2,ac_sub);

 q35_secdforest_expansion(j2,ac_est) ..
 	v35_secdforest_expansion(j2,ac_est) =e=
 		v35_secdforest(j2,ac_est) - pc35_secdforest(j2,ac_est);

 q35_secdforest_reduction(j2,ac_sub) ..
 	v35_secdforest_reduction(j2,ac_sub) =e=
 		pc35_secdforest(j2,ac_sub) - v35_secdforest(j2,ac_sub);

 q35_primforest_reduction(j2) ..
 	v35_primforest_reduction(j2) =e=
 		pcm_land(j2,"primforest") - vm_land(j2,"primforest");

*******************************************************************************
**** Natveg related equations used for production

*' Harvesting costs are paid everytime natural vegetation is harvested. The "real"
*' harvested area are received from the timber module [73_timber].


q35_cost_hvarea(i2)..
                    vm_cost_hvarea_natveg(i2)
                    =e=
                   sum((ct,cell(i2,j2),ac_sub), v35_hvarea_secdforest(j2,ac_sub)) * s35_timber_harvest_cost_secdforest
                  + sum((ct,cell(i2,j2),ac_sub), v35_hvarea_other(j2, ac_sub))     * s35_timber_harvest_cost_other
                  + sum((ct,cell(i2,j2)),        v35_hvarea_primforest(j2))        * s35_timber_harvest_cost_primforest
                    ;

** Secondary forest
*' Woody biomass production from secondary forests is calculated by multiplying the
*' area under production with corresponding yields of secondary forests, divided by the timestep length.

q35_prod_secdforest(j2)..
                           sum(kforestry, vm_prod_natveg(j2,"secdforest",kforestry))
                           =e=
						   sum(ac_sub, v35_hvarea_secdforest(j2,ac_sub) * sum(ct,pm_timber_yield(ct,j2,ac_sub,"secdforest"))) / m_timestep_length_forestry;

** Primary forest
*' Woody biomass production from primary forests is calculated by multiplying the
*' area under production with corresponding yields of primary forests, divided by the timestep length.

q35_prod_primforest(j2)..
                           sum(kforestry, vm_prod_natveg(j2,"primforest",kforestry))
                           =e=
                           v35_hvarea_primforest(j2) * sum(ct, pm_timber_yield(ct,j2,"acx","primforest")) / m_timestep_length_forestry;

** Other land
*' Wood-fuel production from other land is calculated by multiplying the area under
*' production with corresponding yields of other land, divided by the timestep length.
*' Wood production from other landis not allowed.

q35_prod_other(j2)..
                          vm_prod_natveg(j2,"other","woodfuel")
                          =e=
                          sum(ac_sub, v35_hvarea_other(j2,ac_sub) * sum(ct, pm_timber_yield(ct,j2,ac_sub,"other"))) / m_timestep_length_forestry
                          ;

*' Harvested area from secondary forest

q35_hvarea_secdforest(j2,ac_sub)..
                           v35_hvarea_secdforest(j2,ac_sub)
                           =l=
                           v35_secdforest_reduction(j2,ac_sub);


*' Harvested area from primary forest

q35_hvarea_primforest(j2)..
                           v35_hvarea_primforest(j2)
                           =l=
                           v35_primforest_reduction(j2);


*' Harvested area from other land

q35_hvarea_other(j2,ac_sub)..
                          v35_hvarea_other(j2,ac_sub)
                          =l=
                          v35_other_reduction(j2,ac_sub);


*' Harvested secondary forest is still considered secondary forests due to
*' restrictive NPI definitions. Also primary forest harvested will be considered
*' to be secondary forest.

q35_secdforest_conversion(j2)..
                          sum(ac_est, v35_secdforest(j2,ac_est))
                          =e=
                          sum(ac_sub,v35_hvarea_secdforest(j2,ac_sub))
                        + v35_hvarea_primforest(j2)
                          ;

*' Harvested other land is still considered other land

q35_other_conversion(j2)..
                          sum(ac_est, v35_other(j2,ac_est))
                          =g=
                          sum(ac_sub,v35_hvarea_other(j2,ac_sub))
                          ;

*' The following two constraints distribute additions to secdforest and other land
*' over ac_est, which depends on the time step length (e.g. ac0 and ac5 for a 10 year time step).

q35_secdforest_est(j2,ac_est) ..
v35_secdforest(j2,ac_est) =e= sum(ac_est2, v35_secdforest(j2,ac_est2))/card(ac_est2);

q35_other_est(j2,ac_est) ..
v35_other(j2,ac_est) =e= sum(ac_est2, v35_other(j2,ac_est2))/card(ac_est2);
