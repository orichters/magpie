

* land conversion costs just as the sum of the two parts (land clearing and establishing costs)


q39_cost_landcon_annuity(j2,land) .. v39_cost_landcon_annuity(j2,land)
                         =g=
(vm_landexpansion(j2,land)*sum(cell(i2,j2),pc39_establish_costs(i2,land)) +
vm_landreduction(j2,land)*pc39_landclear_costs(j2,land))
/sum(cell(i2,j2),pm_annuity_due(i2));

* this calculates the costs as the annutiy costs from the past + the share of costs of land conversion that are paid today
q39_cost_landcon(j2,land) .. vm_cost_landcon(j2,land)
                         =e=
v39_cost_landcon_annuity(j2,land) + pc39_cost_landcon_past(j2,land);
