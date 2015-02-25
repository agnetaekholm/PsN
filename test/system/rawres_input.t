#!/etc/bin/perl

use strict;
use warnings;
use File::Path 'rmtree';
use Test::More tests=>6;
use File::Copy 'cp';
use FindBin qw($Bin);
use lib "$Bin/.."; #location of includes.pm
use includes; #file with paths to PsN packages and $path variable definition

#black box testing of rawres_input functionality

our $tempdir = create_test_dir('system_rawresinput');
copy_test_files($tempdir,["pheno.mod", "pheno.dta","pheno.lst","pheno.ext"]);
chdir($tempdir);
our $dir = "$tempdir"."rawres_test";
our $bootdir = "$tempdir"."boot_test";
our $ssedir = "$tempdir"."sse_test";
my $model_dir = $includes::testfiledir;

my @commands = 
	(get_command('bootstrap') . " -samples=5 pheno.mod -dir=$bootdir",
	 get_command('parallel_retries') . " pheno.mod -dir=$dir -samples=2 -rawres_input=$bootdir/raw_results_pheno.csv -no-display",
	 get_command('sir') . " pheno.mod -rawres_input=$bootdir/raw_results_pheno.csv -samples=3 -offset_rawres=1 -in_filter=minimization_successful.eq.1 -resamples=20 -with_replacement -dir=$dir",
	 get_command('sse') . " pheno.mod -rawres_input=$bootdir/raw_results_pheno.csv -samples=5 -no-est -dir=$dir",
	 get_command('sse') . " pheno.mod  -samples=20 -dir=$ssedir",
	 get_command('vpc') . " pheno.mod -rawres_input=$ssedir/raw_results_pheno.csv -offset=0 -samples=20 -auto_bin=unique -dir=$dir");

foreach my $command (@commands) {
	print "Running $command\n";
	my $rc = system($command);
	$rc = $rc >> 8;
	ok ($rc == 0, "$command, should run ok");
	rmtree([$dir]);
}

remove_test_dir($tempdir);

done_testing();
