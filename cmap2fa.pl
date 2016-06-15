# $Id: cmap2fa.pl 5078 2016-06-14 22:27:29Z xzhou $
#!/usr/bin/perl -w
########################################################################
# File: cmap2fa.pl                                                     #
# Date: 06/14/2016                                                     #
# Purpose: Transform BioNano cmap file to fasta format (Color-aware)   #
#                                                                      #
# Author: Xiang Zhou, Computational Biologist                          #
# Email : xzhou@bionanogenomics.com                                    #
# Affiliation: Research Department, BioNano Genomics Inc.              #
#                                                                      #
# Usage:                                                               #
#   cmap2fa.pl [options] <Args>                                        #
# Options:                                                             #
#   -h : This help message                                             #
#   -i : Input cmap file (Required)                                    #
#   -o : Output folder (Default: the same as the input file)           #
#   -v : Output the version information                                #
#                                                                      #
# NOTE: CMAP index is 1-based, and is color-aware.                     #
########################################################################

use strict;
use warnings;
use POSIX;
use File::Basename;
use File::Path qw(make_path);
use File::Spec::Functions;
use Getopt::Long qw(:config no_ignore_case);

my ($CMAP, $FASTA);
my ($filename_fasta, $input, $output, $help, $version);
my ($CMapId_last, $Position_last) = (0, 1);
my ($string, $enzyme_last) = ("", "");
my @enzymes;

my $ret = GetOptions(
	'help|h|?'        => \$help,
	'version|v'       => \$version,
	'input|i=s'       => \$input,
	'output|o=s'      => \$output,
);
Usage() if $help;
ShowVersion() if $version;

if(!$ret){
	die("ERROR: Missing or invalid parameter(s)!\n");
}
if(!$input){
	die("ERROR: Missing input filename!\n");
}
else{
	$filename_fasta = $input;
	die ("ERROR! Can't open input file: $!\n") unless (-f $input);
}
if($output){
	my ($nothing, $out_dir) = fileparse($output."/");
	make_path($out_dir) unless (-d $out_dir);
	
	$filename_fasta = basename($input);
	$filename_fasta = catfile($out_dir, $filename_fasta);
}

$filename_fasta =~ s/(\S+)\.\w+$/$1.fa/;
open($CMAP, $input) || die ("ERROR! Can't open input file: $!\n");
if(-f $filename_fasta){
	die("Warning! Output file ($filename_fasta) already exists!\n");
}
open($FASTA, ">".$filename_fasta) || die ("ERROR! Can't open output file: $!\n");
while(my $line = <$CMAP>){
	chomp $line;
	$line =~ s/\r//g;

# Nickase Recognition Site 1:	AAAAAAACCCCC
# Nickase Recognition Site 2:	GGGTTGATATGA
	if($line =~ /^#/){
		if($line =~ /^# Nickase Recognition Site (\d):\t(\w+)$/){
			$enzymes[$1-1] = $2;
		}
		next;
	}
	
	my @data = split("\t", $line);
	my ($CMapId, $ContigLength, $NumSites, $SiteID, $LabelChannel, $Position, $StdDev, $Coverage, $Occurrence) = @data[0..8];
	$Position = int($Position + 0.5);
	
	if($CMapId != $CMapId_last){
		print $FASTA(">", $CMapId, "\n");
		$CMapId_last = $CMapId;
	}
	
	if($LabelChannel == 1){
		$string .= ("N" x ($Position - length($enzyme_last) - $Position_last) . $enzymes[0]);
		$enzyme_last = $enzymes[0];
		$Position_last = $Position;
	}
	elsif($LabelChannel == 2){
		$string .= ("N" x ($Position - length($enzyme_last) - $Position_last) . $enzymes[1]);
		$enzyme_last = $enzymes[1];
		$Position_last = $Position;
	}
	elsif($LabelChannel == 0){
		$string .= ("N" x ($Position - length($enzyme_last) - $Position_last + 1));
		
		print $FASTA( Format_string($string) );
		$enzyme_last = "";
		$Position_last = 1;
		$string = "";
	}
}
close($CMAP);
close($FASTA);

sub Usage{
	print << "EOF";

Usage: $^X $0 [options] <Args>
Options:
  -h : This help message
  -i : Input cmap file (Required)
  -o : Output folder (Default: the same as the input file)
  -v : Output the version information
NOTE: CMAP index is 1-based, and is color-aware.
EOF
	exit 0;
}

sub ShowVersion{
	my $REV = '$Id: cmap2fa.pl 5078 2016-06-14 22:27:29Z xzhou $';
	($REV) = $REV =~ /\$Id: (.*)\$/;
	if($REV){
		print $REV, "\n";
	}
	else{
		print "No version # was found!", "\n";
	}
	exit 0;
}

sub Format_string{
	my ($seq, $N) = @_;
	my $result = "";
	$N //= 80;
	
	for(my $i = 0; $i <= (length($seq)-1) / $N; $i++){
		$result .= (substr($seq, $N*$i, $N) . "\n");
	}
	return ($result);
}

__END__

