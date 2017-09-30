#!/bin/sh

#  plot_all.sh
#  
#
#  Created by Johann on 02/09/13.
#
plot_D_over_U_vary_k_epstex.sh 0 0 off -10 20 0.500 1.000 2.000 3.000 4.000 5.000

plot_D_over_k_vary_U_epstex.sh 0 0 off -10 -5 -1 5 10 20

plot_D_over_U_vary_d_epstex.sh 0.500 200 on 0 1 2 3 4
plot_D_over_U_vary_d_epstex.sh 1.000 200 on 0 1 2 3 4
plot_D_over_U_vary_d_epstex.sh 2.000 200 on 0 1 2 3 4

plot_D_over_U_vary_p_epstex.sh 0 0.500 off LJ -20 20 0 1 2 3 5 9 
plot_D_over_U_vary_p_epstex.sh 0 1.000 off LJ -20 20 0 1 2 3 5 9 
plot_D_over_U_vary_p_epstex.sh 0 2.000 off LJ -20 20 0 1 2 3 5 9


plot_D_over_U_vary_p_epstex.sh 0 1.000 off steric -20 20 1 2 3 4 5 9
plot_D_over_U_vary_p_epstex.sh 0 1.000 off steric2 -20 20 1 2 3 4 5 9

plot_D_over_k_vary_p_const_U_epstex.sh 0 -10 off 0 1 2 3 5 9
plot_D_over_k_vary_p_const_U_epstex.sh 0 10 off 0 1 2 3 5 9

#plot_contour_Matrix_epstex.sh 00x 50 100 0 10 2.000 -3
plot_contour_Matrix_epstex.sh 00x 1 100 0 10 0 2.000 -3
plot_contour_Matrix_epstex.sh 110 1 100 0 10 0 2.000 -3
#plot_contour_Matrix_epstex.sh 00x 50 100 0 10 2.000 3
plot_contour_Matrix_epstex.sh 00x 1 100 0 10 0 2.000 3
plot_contour_Matrix_epstex.sh 110 1 100 0 10 0 2.000 3



#plot_contour_Matrix_epstex.sh 00x 50 100 0 10 2.000 -3 LJ 3
plot_contour_Matrix_epstex.sh 00x 1 100 0 10 3 2.000 -3
plot_contour_Matrix_epstex.sh 110 1 100 0 10 3 2.000 -3
#plot_contour_Matrix_epstex.sh 00x 50 100 0 10 2.000 3 LJ 3
plot_contour_Matrix_epstex.sh 00x 1 100 0 10 3 2.000 3
plot_contour_Matrix_epstex.sh 110 1 100 0 10 3 2.000 3


plot_D_over_p_vary_U_epstex.sh 0 0.500 off -3 -10 -20 10 20
plot_D_over_p_vary_U_epstex.sh 0 1.000 off -3 -10 -20 10 20
plot_D_over_p_vary_U_epstex.sh 0 2.000 off -3 -10 -20 10 20

plot_D_over_p_vary_sterictype_at_U0_epstex.sh 0 LJ steric steric2

plot_D_over_b_vary_U_epstex.sh 1 LJ -10 10

plot_D_over_U_vary_p_epstex.sh 0 200 0.500 off LJ -150 1 2 5

# random Pot
plot_D_over_U_vary_k_epstex.sh 0 0 ranPot 0 21 0.500 1.000 2.000
plot_D_over_k_vary_U_epstex.sh 0 0 ranPot 1 3 5 7 10
plot_D_over_U_vary_p_epstex.sh 0 1.000 ranPot LJ 0 30 0 1 2 5
plot_D_over_k_vary_p_const_U_epstex.sh 0 10 ranPot 0 1 2 3 5 9
plot_contour_Matrix_epstex.sh 00x 1 100 0 10 0 2.000 3 ranPot
plot_contour_Matrix_epstex.sh 110 1 100 0 10 0 2.000 3 ranPot
plot_contour_Matrix_epstex.sh 00x 1 100 0 10 3 2.000 3 ranPot
plot_contour_Matrix_epstex.sh 110 1 100 0 10 3 2.000 3 ranPot

# comparison Lai experiment
plot_D_over_U_vary_p_epstex.sh 0 200 0.500 off LJ -70 1 2 5   #not very good - too small for 500 nm particle
plot_D_over_U_vary_p_epstex.sh 0 200 1.000 off LJ -70 1 2 5

# comparison Jason
plot_D_over_C_vary_U_at_RT.sh 0 1 off 15 500 -7 7

# Bessel
plot_D_over_U_vary_p_epstex.sh 0 0.500 Bessel LJ -20 20 0 1 2 5  
plot_D_over_U_vary_p_epstex.sh 0 1.000 Bessel LJ -20 20 0 1 2 5
plot_D_over_U_vary_p_epstex.sh 0 2.000 Bessel LJ -20 20 0 1 2 5


# HPI
plot_D_over_k_vary_p_const_U_epstex.sh 5 -7 HPI 1 
plot_D_over_k_vary_p_const_U_epstex.sh 5 7 HPI 1 


# Paper
plot_D_over_p_vary_sterictype_at_U0_epstex.sh 0 LJ


# Epot
plot_Epot_over_U_vary_k_epstex.sh 0 0 off -10 20 0.500 1.000 2.000 3.000 4.000 5.000

plot_Epot_over_U_vary_p_epstex.sh 0 0.500 off LJ -20 20 0 1 2 3 5 9 
plot_Epot_over_U_vary_p_epstex.sh 0 1.000 off LJ -20 20 0 1 2 3 5 9
plot_Epot_over_U_vary_p_epstex.sh 0 2.000 off LJ -20 20 0 1 2 3 5 9 

plot_Epot_over_p_vary_U_epstex.sh 0 1.000 off -3 -10 -20 10 20
plot_Epot_over_p_vary_U_epstex.sh 0 0.500 off 0
