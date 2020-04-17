#usr/bin/perl

use strict;
use warnings;
use Benchmark; # entrega cuando demora el proceso, cuanto de CPU utilizó, etc
#
my $tiempo_inicial = new Benchmark; #funcion para el tiempo de ejecucion del programa
my $input_file     = $ARGV[0];
# leer directorio solo los archivos .out o .log
my $time_step   = $ARGV[1];
my @array_energy = ();
my @array_coords = ();
my @array_files  = ();
# numero de atomos 
my $atom_numb;
############# 
# Main
my @Secuencias = ();
# coodenadas
my @coords;
# 
my $file = $input_file;
my $seqlinea;
# # # #
open (IN, "<$file")||die "cannot open $file in readseq subroutine:$!\n";
while ($seqlinea = <IN>) {
	chomp($seqlinea);
	push (@Secuencias, $seqlinea);
}
close IN;
#
my @columns_1N =();
#
my @EKinC     =();
my @EKinPA    =();
my @EKinPB    =();
#
my @EKin       =();     
my @EPot       =();
my @ETot       =();
#
my @ETot_EKinP =();
#
my @columns_5N =();
my @columns_6N =();
#
my $count_lines = 0;
foreach my $a_1 (@Secuencias){
	# Summary information for step
	if ( ($a_1=~/Summary/gi ) && ($a_1=~/information/gi ) && ($a_1=~/step/gi ) ){
		my @array_tabs = ();
		@array_tabs = split ('\s+',$a_1);
		push (@columns_1N  ,$array_tabs[5]);
	}
	# EKinC      =      0.0710268; EKinPA =      0.0000000; EKinPB =      0.0000000
	if ( ($a_1=~/EKinC/gi ) && ($a_1=~/EKinPA/gi ) && ($a_1=~/EKinPB/gi ) ){
		my @array_tabs = ();
		@array_tabs = split ('\s+',$a_1);
		chop ($array_tabs[3]);
		chop ($array_tabs[6]);
		push (@EKinC  ,$array_tabs[3]);
		push (@EKinPA ,$array_tabs[6]);
		push (@EKinPB ,$array_tabs[9]);
	}
	# EKin       =      0.0710268; EPot   =      0.3620333; ETot   =      0.4330601
	if ( ($a_1=~/EKin/gi ) && ($a_1=~/EPot/gi ) && ($a_1=~/ETot/gi ) ){
		my @array_tabs = ();
		@array_tabs = split ('\s+',$a_1);
		chop ($array_tabs[3]);
		chop ($array_tabs[6]);
		push (@EKin ,$array_tabs[3]);
		push (@EPot ,$array_tabs[6]);
		push (@ETot ,$array_tabs[9]);
	}
	# ETot-EKinP =      0.4330601
	if ( ($a_1=~/ETot-EKinP/gi ) ){
		my @array_tabs = ();
		@array_tabs = split ('\s+',$a_1);
		push (@ETot_EKinP  ,$array_tabs[3]);
	}	
	###################
	# Input orientation:
	if ( ($a_1=~/Input/gi ) && ($a_1=~/orientation/gi ) && ($a_1=~/:/gi ) ){
		push (@columns_5N  ,$count_lines);
	}
	# NAtoms=
	if ( ($a_1=~/NAtoms/gi ) && ($a_1=~/=/gi ) ){
		my @array_tabs = ();
		@array_tabs = split ('\s+',$a_1);
		push (@columns_6N  ,$array_tabs[2]);
	}
	$count_lines++;
}
#
for (my $i=0; $i < scalar (@columns_1N); $i++){
	my $start  = $columns_5N[$i] + 5;
	my $end    = $start + $columns_6N[0] - 1;
	$atom_numb = $columns_6N[0];
	my $step   = $columns_1N[$i];
	@coords = ();
	foreach my $j (@Secuencias[$start..$end]){
		push (@coords,$j);				
	}
	my @total_coords = ();
	foreach my $i (@coords){
		my @tmp = ();
		@tmp =  split (/\s+/,$i);
		push (@total_coords,"$tmp[2]\t$tmp[4]\t$tmp[5]\t$tmp[6]");
	}
	push(@array_energy,$step);	
	push(@array_coords,[@total_coords]);
}
#
my @value_energy_sort = @array_energy;
my @value_coords_sort = @array_coords;
#
open(EKinC ,     ">EKinC_result_$time_step.txt")  or 
die "Could not open file EKinC_result_$time_step.txt $!";
open(EKinPA,     ">EKinPA_result_$time_step.txt") or 
die "Could not open file EKinPA_result_$time_step.txt $!";
open(EKinPB,     ">EKinPB_result_$time_step.txt") or 
die "Could not open file EKinPB_result_$time_step.txt $!";
open(EKin,       ">EKin_result_$time_step.txt") or 
die "Could not open file EKin_result_$time_step.txt $!";
open(EPot,       ">EPot_result_$time_step.txt") or 
die "Could not open file EPot_result_$time_step.txt $!";
open(ETot,       ">ETot_result_$time_step.txt") or 
die "Could not open file ETot_result_$time_step.txt $!";
open(ETot_EKinP, ">ETot_EKinP_result_$time_step.txt") or 
die "Could not open file ETot_EKinP_result_$time_step.txt $!";
#
my $filename = "Trajectory_BOMD_$time_step.xyz";
open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
for (my $i=0; $i < scalar (@value_energy_sort); $i=$i+$time_step){
	#
	my $convert_pico_second = ($value_energy_sort[$i] / 1000);
	#
	print EKinC      "$convert_pico_second\t".($EKinC[$i]).     "\n"; 
	print EKinPA     "$convert_pico_second\t".($EKinPA[$i]).    "\n";
	print EKinPB     "$convert_pico_second\t".($EKinPB[$i]).    "\n";
	print EKin       "$convert_pico_second\t".($EKin[$i]).      "\n";
	print EPot       "$convert_pico_second\t".($EPot[$i]).      "\n";
	print ETot       "$convert_pico_second\t".($ETot[$i]).      "\n";
	print ETot_EKinP "$convert_pico_second\t".($ETot_EKinP[$i])."\n";
	# 1 Hartree = 27,2114 ev
	# 1 Hartree = 627,509 Kcal/mol	
	my $eV      = sprintf("%06f",(27.2114 * $EPot[$i] ));
	my $Kcalmol = sprintf("%06f",(627.509 * $EPot[$i] ));
	my $Hartree = sprintf("%06f",$EPot[$i]);
	print $fh "$atom_numb\n"; 
	print $fh "$Kcalmol Kcal/mol $eV eV $Hartree H\n";
	for (my $j=0; $j < $atom_numb; $j++){
		print $fh "$value_coords_sort[$i][$j]\n";
	}
}
close $fh;
close(EKinC); 
close(EKinPA);
close(EKinPB);
close(EKin);
close(EPot);
close(ETot);
close(ETot_EKinP);
##############################################################
my $tiempo_final = new Benchmark;
my $tiempo_total = timediff($tiempo_final, $tiempo_inicial);
print "\n\tTiempo de ejecucion: ",timestr($tiempo_total),"\n";
print "\n";
