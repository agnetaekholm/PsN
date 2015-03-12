#!/etc/bin/perl

use strict;
use warnings;
use File::Path 'rmtree';
use Test::More;
use File::Copy 'cp';
use FindBin qw($Bin);
use lib "$Bin/.."; #location of includes.pm
use includes; #file with paths to PsN packages and $path variable definition

our $tempdir = create_test_dir('system_vpc');
our $dir = "$tempdir/vpc_test";
my $model_dir = $includes::testfiledir;

my @commands = (
	get_command('vpc') . " -samples=20 $model_dir/mox1.mod -stratif=AGE -no_of_strata=3 -auto_bin=12 -dir=$dir",
	get_command('vpc') . " -samples=20 $model_dir/mox1.mod -stratif=AGE -no_of_strata=2 -bin_by_count=1 -no_of_bins=3 -dir=$dir",
	get_command('vpc') . " -samples=20 $model_dir/mox1.mod -stratif=AGE -no_of_strata=4 -bin_by_count=1 -single_bin_size=20 -dir=$dir",
	get_command('vpc') . " -samples=20 $model_dir/mox1.mod -stratif=AGE -bin_by_count=1 -single_bin_size=15 -overlap=4 -dir=$dir",
	get_command('vpc') . " -samples=20 $model_dir/mox1.mod -stratif=AGE -bin_by_count=0 -no_of_bins=3 -dir=$dir",
	get_command('vpc') . " -samples=20 $model_dir/mox1.mod -stratif=AGE -bin_by_count=0 -single_bin_size=5.5 -dir=$dir",
	get_command('vpc') . " -samples=20 $model_dir/mox1.mod -stratif=AGE -no_of_strata=3 -bin_by_count=0 -single_bin_size=3.2 -overlap=3 -dir=$dir",
	 );

foreach my $command (@commands){
	print "Running $command\n";
	my $rc = system($command);
	$rc = $rc >> 8;
	ok ($rc == 0, "$command, should run ok");
#	rmtree([$dir]); #do not remove here, want to reuse simulations
}

remove_test_dir($tempdir);

done_testing();
