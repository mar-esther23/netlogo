# netlogo
Netlogo code examples
==============

CompetenciaColorHSB.nlogo
--------------
Agent model for netlogo 4.04
Organisms alter the environment , however they don't have the same impact on all ecological variables. Given the complex relationships between organisms and their ecosystem is not trivial to predict the effects of the organims in the environment. 
A predator -prey model with a motionless prey (grass ) and a mobile predator ( turtle) was constructed. Both predator and prey where assigned a color in the HSB scale and the restriction that predators can only consume a grass with a similar color. The simulation assigning random colors to initial agents. It can be noted that subpopulations of specific colors are generated, and that individuals with intermediate colors disappear.



CompetenciaRGBsexual.nlogo
--------------
Agent model for netlogo 4.1
This program is very similar to competenciaHSB. The main difference is that now the organisms have a genome with 3 colors corresponding to the RGB scale (genotype). From there, the genome is mapped to HSB (phenotype).
This is a predator-prey system with the peculiarity that each turtle has a color in the RGB scale. The turtles can only eat grass that is similar to their color.
Different types of reproduction are included:
- asexual, turtle inherits the color of the parent with a probability of mutation
- sexual, turtle inherits the color of average of each RGB color of the parents with a probability of mutation
The grass is asexual.



CompetenciaSirSas.nlogo
--------------
Agent model for netlogo 4.1
Model made as part of "Epigenator" for the 1st Synthetic Biology Workshop 2010 in the CINVESTAV Irapuato.
This model illustrates the competition between the epigenetic silencing caused by deacetylase SIR2 (blue) and activation caused by SAS2 acetyltransferase (red).
Assumes that the DNA is a laticce that can be in two states silenced (cyan) and active (yellow). Proteins travel randomly, until they find the DNA and stick with a given probability. Sir2 (blue) and SAS2 (red) compete for the deacetylated sites (cyan). Sir2 deacetylates its neighbors, while SAS2 acetylated its neighbors. There is a strong cooperativity caused bySir2, which means that if a protein is attached to the DNA in the neighborhood the chance to join the DNA increases.



DispersionEscarabajosPinos.nlogo
--------------
Agent model for netlogo 4.1
Predator-prey model where beetles invade pine trees. Includes a soil quality parameter that restricts the growth of the pines and beetle's migration.



Higado0.nlogo
--------------
Agent model for netlogo 4.1
A model that (kind of) reproduces cirrhosis. Sick cells produce cytokines that increase the colagen and cause cirrhosis.



PD N-Person Iterated Evolution.nlogo
--------------
Agent model for netlogo 4.1
Iterated prisoner's dilemma, with hatching and death. See evolution in action!



Random_Boolean_Network_Robustness.nlogo
--------------
The model generates random boolean networks and their functions using links. It can iterate the network and perturb both the state of the network and the function. The model also tracks the effects of the perturbations.
The model includes three posible views of the network:
- The nodes colored depending on their state.
- A table trough time depending of the nodes.
- Average nodes states.



Th_rules.nlogo
--------------
Each agent represent a CD4+ T cell whose differentiation state depends on an internal gene regulatory network. Includes cytokine production and diffusion, Th differentiation and subset determination. The model implements the GRN as a set of rules.



ThDynamics_rules.nlogo
--------------
Each agent represent a CD4+ T cell whose differentiation state depends on an internal gene regulatory network. Includes reproduction, cytokine production and diffusion, Th differentiation and subset determination. The model implements the GRN as a list. The results are explosive.





Incomplete
==============
Forever and ever...


CompetenciaColorHSB.0.nlogo
--------------
Agent model for netlogo 4.04
Old (and error-prone) version of CompetenciaColorHSB.nlogo


FlockingAnts.nlogo
--------------
Agent model for netlogo 4.0.4
A (bad) mix of the Ants and Flocking models. The best thing is the model name. Really, this one was one of my first experiments with Netlogo, and it shows.


Higado1.nlogo
--------------
Agent model for netlogo 4.1
It diffuses? Maybe?


MigracionLeucocitosPericitos.nlogo
--------------
Agent model for netlogo 5.0
Periocites migrate towards an injury and get confused by chronic inflamation.


FlockingAnts.nlogo
--------------
Agent model for netlogo 4.0.4
Classic predator-prey model, in Africa!


Percolation.nlogo
--------------
Agent model for netlogo 4.0.4
Percolation model with cute colors. 


Random_Network_Practica.nlogo
--------------
Small example of generating random boolean networks.


Zombiees.nlogo
--------------
Agent model for netlogo 4.1
Humans Vs. Zombies


ZombiesCasas.nlogo
--------------
Agent model for netlogo 4.1
Humans Vs. Zombies. Except that the humans can stay home, if there is food of course.