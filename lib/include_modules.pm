package include_modules;
use Moose::Util::TypeConstraints;
use ext::Carp;
use ui;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(cluck longmess shortmess carp croak debugmessage warn_once);

our $debuglevel=0;
sub debugmessage{
	my $messagelevel=shift;
	my $message = shift;
	if ($messagelevel <= $debuglevel){
		ui->print(category => 'all', message => $message);
	} 
}

my %one_time_warnings;

sub warn_once
{
    # Takes two arguments. First the type of warning. Second the warning message
    my $type = shift;
    my $message = shift;

    if (not exists $one_time_warnings{$type}) {
        $one_time_warnings{$type}++;
        ui->print(category => 'all', message => $message);
    }
}

subtype 'PositiveInt',
	as 'Int',
	where { $_ > 0 },
	message { "This number ($_) is not a positive integer" };
no Moose::Util::TypeConstraints;

1;
