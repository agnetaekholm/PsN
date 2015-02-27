#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
#use Test::More;
use Test::Exception;
use FindBin qw($Bin);
use lib "$Bin/.."; #location of includes.pm
use includes; #file with paths to PsN packages
use ext::Math::MatrixReal qw(all); 
use Math::Trig;	# For pi
use Math::Random;
use output;
use tool::sir;
use linear_algebra;





my $mat = new Math::MatrixReal(1,1);
my $mu = $mat->new_from_rows( [[1,2,3]] );
my $icm = $mat->new_from_rows( [[3.356398464199823e-01,-2.953461879245602e-03,-3.312096536011139e-02],
								[    -2.953461879245602e-03, 1.257330914307413e-01, -1.856461752668664e-02],
								[    -3.312096536011139e-02, -1.856461752668664e-02,  5.060967891650141e-01]]);
#print $mu;

my $k=3;
my $base=tool::sir::get_determinant_factor(inverse_covmatrix => $icm,
										   k => $k,
										   inflation => 1);

cmp_relative($base,9.222143261486744e-03,13,'well conditioned determinant factor');
my $nsamples=1;

#my $covar = [[3,0.1,0.2],[0.1,8,0.3],[0.2,0.3,2]];

my $gotsamples = [[0,1,2]];




my $relpdf=tool::sir::mvnpdf(inverse_covmatrix => $icm,
						  mu => $mu,
						  xvec_array => $gotsamples,
						  inflation => 1);

cmp_relative($relpdf->[0],6.510975388450209e-01,13,'well conditioned exponent');

cmp_relative(($base*$relpdf->[0]),6.004514780430216e-03,13,' matlab mvnpdf ');

cmp_relative(($base),9.222143261486746e-03,13,' matlab mvnpdf center ');
cmp_relative($relpdf->[0],6.510975388450211e-01,13,' matlab mvnpdf rel pdf ');


my $dir = $includes::testfiledir . "/sir/";
my $file = 'run1_noblock.lst';
my $output = output->new(filename => $dir . $file);


my $values = $output->get_filtered_values(parameter => 'theta');

cmp_ok($values->[0],'==',2.66825E+01,' theta 1');
cmp_ok($values->[1],'==',1.10274E+02,' theta 2');
cmp_ok($values->[2],'==',4.49611E+00,' theta 3');
cmp_ok($values->[3],'==',2.40133E-01,' theta 4');
cmp_ok($values->[4],'==',3.30597E-01,' theta 5');
cmp_ok($values->[5],'==',7.50245E-02,' theta 6');
cmp_ok($values->[6],'==',5.63377E-02,' theta 7');
cmp_ok($values->[7],'==',7.18895E-01,' theta 8');

my $hash = output::get_nonmem_parameters(output => $output);

cmp_ok($hash->{'values'}->[0],'==',2.66825E+01,'hash theta 1');
cmp_ok($hash->{'values'}->[1],'==',1.10274E+02,'hash theta 2');
cmp_ok($hash->{'values'}->[2],'==',4.49611E+00,'hash theta 3');

$values = $output->get_filtered_values(parameter => 'sigma');
cmp_ok(scalar(@{$values}),'==',0,' fixed sigma');

$values = $output->get_filtered_values(parameter => 'omega');
is_deeply($values,[2.81746E+00,1.46957E-02,5.06114E-01],'omega');
  

my $block_covar = tool::sir::get_nonmem_covmatrix(output => $output);

my $ref=[
[0.9271,2.27211,0.0275593,-0.000287334,0.00846576,-0.000618088,-0.00144621,0.0267219,0.103993,-0.000950558,0.027529],
[2.27211,15.718,0.655662,-0.00255354,0.0305418,0.00231333,-0.00930454,0.000530111,0.241725,0.00161953,0.168762],
[0.0275593,0.655662,1.87885,0.0042868,-0.0188686,-0.000476181,0.00183569,-0.0217546,0.97174,-6.89874E-005,0.13039],
[-0.000287334,-0.00255354,0.0042868,3.39565E-005,-5.09132E-005,3.51457E-006,-0.00000139695,-0.000120266,0.00278859,-0.00000351597,0.000341127],
[0.00846576,0.0305418,-0.0188686,-5.09132E-005,0.000710048,0.000029797,-5.58994E-005,0.000696781,-0.00712629,2.43304E-007,-0.000318354],
[-0.000618088,0.00231333,-0.000476181,3.51457E-006,0.000029797,0.000148953,1.18338E-005,0.000154661,0.00016596,-8.45776E-006,3.52465E-005],
[-0.00144621,-0.00930454,0.00183569,-0.00000139695,-5.58994E-005,1.18338E-005,0.000142996,3.19477E-005,0.00128481,9.76454E-006,-0.000460725],
[0.0267219,0.000530111,-0.0217546,-0.000120266,0.000696781,0.000154661,3.19477E-005,0.00581318,-0.00718936,3.62128E-005,0.000430627],
[0.103993,0.241725,0.97174,0.00278859,-0.00712629,0.00016596,0.00128481,-0.00718936,0.886165,-0.000513899,-0.0251719],
[-0.000950558,0.00161953,-6.89874E-005,-0.00000351597,2.43304E-007,-8.45776E-006,9.76454E-006,3.62128E-005,-0.000513899,2.36718E-005,0.000126788],
[0.027529,0.168762,0.13039,0.000341127,-0.000318354,3.52465E-005,-0.000460725,0.000430627,-0.0251719,0.000126788,0.0689168]
];
is_deeply($block_covar,$ref,'covariance matrix');

#my $mat = new Math::MatrixReal(1,1);
#my $mu = $mat->new_from_rows( [$output->get_filtered_values()] );

my $covar = [[3,0.1,0.2],[0.1,8,0.3],[0.2,0.3,2]];


#this destroys covar
my $err=linear_algebra::cholesky_transpose($covar);

my $matlabref =[
[1.732050807568877e+00,                         0,                         0],
[     5.773502691896259e-02,     2.827837807701613e+00,                         0],
[     1.154700538379252e-01,     1.037306073687962e-01,     1.405669458927513e+00]
	];
is_deeply($covar,$matlabref,'cholesky T');


my $root_determinant = $covar->[0][0];
for (my $i=1; $i< 3; $i++){
	$root_determinant = $root_determinant*$covar->[$i][$i];
}
cmp_float($root_determinant,6.884911037914724,'root determinant');
my $diff = [1,2,3];
$err = linear_algebra::upper_triangular_transpose_solve($covar,$diff);


is_deeply($diff,[5.773502691896258e-01,6.954665721317015e-01,2.035465838166839e+00],' solve R ');

my $sum = 0;
for (my $i=0; $i< scalar(@{$diff}); $i++){
	$sum = $sum + ($diff->[$i])**2;
}
cmp_float($sum,4.960128264630185,'vecotr prod ');
my $pdf = ((2*pi)**(-3/2))*(1/$root_determinant)*exp(-0.5*$sum);

cmp_float($pdf,7.722424963030007e-04,' chol pdf ');

$covar = [[3,0.1,0.2],[0.1,8,0.3],[0.2,0.3,2]];
$mu = [1,2,3];

my $xvectors=[[0,0,0],
	[1,2,3],
	[4,4,4],
	[0.1, -0.6, 8]];


#matlab code in sir.m
#inflation 1 relative no
my $results = linear_algebra::mvnpdf_cholesky($covar,$mu,$xvectors,1,0);

cmp_relative($results->[0],7.722424963030007e-04,12,'mvnpdf_chol vs matlab builtin mvnpdf 1');
cmp_relative($results->[1],9.222143261486746e-03,12,'mvnpdf_chol vs matlab builtin mvnpdf 2');
cmp_relative($results->[2],1.434657987390218e-03,12,'mvnpdf_chol vs matlab builtin mvnpdf 3');
cmp_relative($results->[3],6.415825193748951e-06,12,'mvnpdf_chol vs matlab builtin mvnpdf 4');

#relative yes
$results = linear_algebra::mvnpdf_cholesky($covar,$mu,$xvectors,1,1);

cmp_relative($results->[0],8.373785511747774e-02,12,'rel mvnpdf_chol vs matlab builtin mvnpdf 1');
cmp_relative($results->[1],1.000000000000000e+00,12,'rel mvnpdf_chol vs matlab builtin mvnpdf 2');
cmp_relative($results->[2],1.555666558967475e-01,12,'rel mvnpdf_chol vs matlab builtin mvnpdf 3');
cmp_relative($results->[3], 6.956978450489421e-04,12,'rel mvnpdf_chol vs matlab builtin mvnpdf 4');


#inflation 3 relative no
$results = linear_algebra::mvnpdf_cholesky($covar,$mu,$xvectors,3,0);
cmp_relative($results->[0],7.764686515437722e-04,12,'infl mvnpdf_chol vs matlab builtin mvnpdf 1');
cmp_relative($results->[1],1.774802298174889e-03,12,'infl mvnpdf_chol vs matlab builtin mvnpdf 2');
cmp_relative($results->[2],9.545283267243817e-04,12,'infl mvnpdf_chol vs matlab builtin mvnpdf 3');
cmp_relative($results->[3],1.572619060514979e-04,12,'infl mvnpdf_chol vs matlab builtin mvnpdf 4');

#relative yes
$results = linear_algebra::mvnpdf_cholesky($covar,$mu,$xvectors,3,1);
cmp_relative($results->[0],4.374958564918756e-01,12,'infl rel mvnpdf_chol vs matlab builtin mvnpdf 1');
cmp_relative($results->[1],1.000000000000000e+00,12,'infl rel mvnpdf_chol vs matlab builtin mvnpdf 2');
cmp_relative($results->[2],5.378223409480409e-01,12,'infl rel mvnpdf_chol vs matlab builtin mvnpdf 3');
cmp_relative($results->[3],8.860812621958941e-02,12,'infl rel mvnpdf_chol vs matlab builtin mvnpdf 4');

#check covar not destoryed
is_deeply($covar,[[3,0.1,0.2],[0.1,8,0.3],[0.2,0.3,2]],'covar not destryed ');
is_deeply($mu,[1,2,3],'mu not destoryed');
is_deeply($xvectors,[[0,0,0],[1,2,3],	[4,4,4],	[0.1, -0.6, 8]],'xvectors not destoryed');

my $file = 'moxo.lst';
my $output = output->new(filename => $dir . $file);


# matlab test code in moxonidine.m
my $moxo_covar = tool::sir::get_nonmem_covmatrix(output => $output);

my $ref=[
[0.873778,2.19014,0.13887,-2.98453E-005,-0.000785758,0.000235191,-0.00137167,0.148541,-0.00103326,0.0297615,0.0050723],
[2.19014,15.5223,0.622217,-0.0026337,0.000931442,-0.00686826,-0.0108224,0.212108,0.00116257,0.150677,0.0227413],
[0.13887,0.622217,0.887891,0.00247469,-0.000142814,-0.000284542,0.00131662,0.601221,-0.00019056,0.0850608,-0.00630654],
[-2.98453E-005,-0.0026337,0.00247469,3.10691E-005,3.33776E-006,-7.37406E-006,-2.46345E-006,0.00222128,-3.92063E-006,0.000279102,-2.62843E-005],
[-0.000785758,0.000931442,-0.000142814,3.33776E-006,0.0001542,7.27021E-005,1.88658E-005,0.000267381,-6.87112E-006,4.12506E-005,1.18544E-005],
[0.000235191,-0.00686826,-0.000284542,-7.37406E-006,7.27021E-005,0.000098852,8.18745E-005,0.000259973,7.13069E-006,-0.000147872,7.30389E-007],
[-0.00137167,-0.0108224,0.00131662,-2.46345E-006,1.88658E-005,8.18745E-005,0.000151409,0.00123871,1.15681E-005,-0.000440197,-4.17504E-005],
[0.148541,0.212108,0.601221,0.00222128,0.000267381,0.000259973,0.00123871,0.777145,-0.000582497,-0.0380049,-0.00324836],
[-0.00103326,0.00116257,-0.00019056,-3.92063E-006,-6.87112E-006,7.13069E-006,1.15681E-005,-0.000582497,2.41602E-005,0.000119454,-0.000000161],
[0.0297615,0.150677,0.0850608,0.000279102,4.12506E-005,-0.000147872,-0.000440197,-0.0380049,0.000119454,0.0672077,-0.000182254],
[0.0050723,0.0227413,-0.00630654,-2.62843E-005,1.18544E-005,7.30389E-007,-4.17504E-005,-0.00324836,-0.000000161,-0.000182254,0.000299476]
];
is_deeply($moxo_covar,$ref,'covariance matrix');

my $mu = [26.6826,110.274,4.49576,0.240133,0.0750256,0.0467377,0.056338,2.81718,0.0146954,0.506077,0.109295];


my $xvectors=[
[26.623,113.055,4.3679,0.247502,0.0796516,0.0395443,0.0568655,2.84291,0.0105876,0.385506,0.131366],
[26.9504,110.441,5.24368,0.240122,0.0686938,0.041067,0.0517129,2.0173,0.0121147,0.942027,0.100209],
[27.2189,106.401,6.39645,0.240122,0.0948644,0.0533097,0.0616498,4.31796,0.00736211,0.947794,0.110911],
[  28.038,109.534,3.54128,0.23322,0.0673617,0.0275188,0.0287049,1.65518,0.000104766,0.693002,0.116561],
[26.4126,107.534,5.35781,0.240122,0.0765838,0.0480814,0.0616885,3.65379,0.0164994,0.291707,0.0947614],
[26.3658,115.166,5.00756,0.238895,0.0911875,0.0553033,0.0610049,3.34658,0.0200679,0.557913,0.127942],
[26.7699,105.408,5.66196,0.240122,0.0673888,0.0381466,0.0382593,3.51061,0.00500059,0.908073,0.0822799],
[25.1499,106.82,4.42911,0.24821,0.0806821,0.0338323,0.0385349,3.25215,0.0130906,0.265113,0.0893015],
[28.0504,111.106,6.58429,0.240122,0.0578236,0.0300437,0.0303841,5.21521,0.00794128,0.616639,0.106735],
[27.9132,117.137,4.01264,0.238383,0.0755322,0.032908,0.0269704,1.16104,0.0115552,1.04045,0.128992],
[27.2229,114.4,5.66876,0.241196,0.0378813,0.021466,0.0281806,2.9152,0.0159949,0.578787,0.104014],
[27.2082,112.178,5.16698,0.244135,0.0902808,0.0542473,0.0447351,2.9452,0.0167429,0.655561,0.117871],
[26.4204,107.51,4.36827,0.239701,0.0607497,0.0399426,0.053148,3.18952,0.0185022,0.569186,0.0914089],
[28.2452,110.812,5.57434,0.24325,0.0812799,0.05597,0.063812,3.99574,0.00945897,0.28784,0.102739],
[27.4687,111.924,4.95307,0.231575,0.0723104,0.0456784,0.0403753,2.5557,0.0171464,0.715062,0.123952],
[26.2775,106.028,4.11019,0.249755,0.0667135,0.0519199,0.0793815,3.19723,0.0158766,0.584682,0.119545]  ];

#absolute
$results = linear_algebra::mvnpdf_cholesky($moxo_covar,$mu,$xvectors,1,0);

my $matlababs=[8.408615352278130e+06, 3.320492620781928e+07,1.363184286581484e+04,2.934253934734758e+04,8.543514599035780e+07,1.943559169652895e+07,
2.039801927640183e+05,6.082921464337746e+06, 2.313966448511987e+04,1.309139347567398e+06, 3.638346261905838e+04,1.528343354309707e+07,
2.941693435563622e+07, 1.522664659748737e+07, 5.170528396931276e+06, 4.348549251948097e+05];

for (my $i=0; $i< scalar(@{$results}); $i++){
	cmp_relative($results->[$i],$matlababs->[$i],12,'abs moxo mvnpdf_chol vs matlab builtin mvnpdf '.$i);
}

#relative
$results = linear_algebra::mvnpdf_cholesky($moxo_covar,$mu,$xvectors,1,1);
my $matlabrel=[ 9.923550589244195e-03, 3.918728009673332e-02, 1.608781905654550e-05, 3.462902766165926e-05, 1.008275391149960e-01, 2.293719826060845e-02, 
2.407302126799157e-04, 7.178848877348236e-03, 2.730861402454468e-05, 1.544999979150610e-03, 4.293847640613998e-05, 1.803696798916897e-02, 
3.471682602053407e-02, 1.796995004341245e-02, 6.102074832828437e-03, 5.132004103367098e-04];

for (my $i=0; $i< scalar(@{$results}); $i++){
	cmp_relative($results->[$i],$matlabrel->[$i],12,'rel moxo mvnpdf_chol vs matlab builtin mvnpdf '.$i);
}




done_testing();