#!/usr/bin/perl
# use Modern::Perl '2023';
use autodie;
use strict;
use utf8;
use v5.38;
use Text::Unidecode;
use Date::Simple ( 'date', 'today' );
use File::Basename;
use Text::Capitalize;
use warnings;
use Cwd;
our $VERSION = ('0.6.0');

=pod
         ___  __ _ _ __ (_) |_ __ _ _______ _ __
        / __|/ _` | '_ \| | __/ _` |_  / _ \ '__|
        \__ \ (_| | | | | | || (_| |/ /  __/ |
        |___/\__,_|_| |_|_|\__\__,_/___\___|_|

=head1 NAME 

    sanitazer13         Clean filenames and title capitalize names in folders and files,
                  	removing non-ASCII characters
                        

=head1 SYNOPSIS 

    --name              folder name to sanitaze

=head1 VERSION

our $VERSION = qv('0.7.0');

   Date: Thu June  6 11:21:26 AM -04 2023


=head1 CHANGES :
 
  REF NO  VERSION  DATE    WHO     DETAIL
  001 01    070		260606	 anp		remplaze subroutine titlecase by Text::Capitalize from CPAN


=head1 License
    This program is free software: you can redistribute it and/or modify it under the terms
    of the GNU General Public License as published by the Free Software Foundation, either
    version 3 of the License, or (at your option) any later version.
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU General Public License for more details.
    You should have received a copy of the GNU General Public License along with this program.
    If not, see <https://www.gnu.org/licenses/>. 
 
Copyright (C) 2025 Agustin Navarro (agustin.navarro@gmail.com)
Copyright (C) 2026 Agustin Navarro (agustin.navarro@gmail.com)

=cut

#
#
my $blk = "  ";    # blank space
my $ext = "";
my $fdir;          # a directory entry workging area
my $file;          # a directory entry workging area
my $fname;         # a directory entry workging area
my $folder = undef;
my $help   = undef;
my $ofile;         # a directory name sanitazed
my $ofname;        # a directory name sanitazed
my $ofnamex;       # a directory name sanitazed

# takes a file name and copies or moves (if delete is selected)
# it to folder  without colision
#
#  $ARGV[0] can be a folder or a file
$file = "$ARGV[0]";
if ( $file eq "." or $file eq ".." ) {
    exit;
}

if ( !-f $file && !-d $file ) {
    say "incorrect $file";
    exit(1);
}

print("*");
$ofile = " ";
( $fname, $fdir, $ext ) = fileparse( $file, qr/\.[^.]*/ );
if ( length($ext) > 5 ) {
    $fname .= $ext;
    $ext = "";
}

$ofname = raccents("$fname");
$ofname =~ s/[-|_]/\ /g;
$ofname  = capitalize_title($ofname);
$ofname  = sanitaze("$ofname");
$ofnamex = $ofname;
if ( $ext ne "" ) {
    $ofnamex = $ofnamex . $ext;
}
$ofile = $fdir . $ofnamex;

if ( $file ne $ofile ) {
    movefile( $fdir, "$file", $ofname, $ext );
}

# sub xsystem {               #This is just for testing
#         print (@_, "\n");
#             return(0);
# }

# remove accents and especial characters from foreing words

sub raccents {
    my $odir;
    ($odir) = @_;

    $odir = unidecode($odir);
    $odir =~ s/\p{NonspacingMark}//g;
    return ($odir);
}

sub sanitaze {
    my $odir;
    ($odir) = @_;

    # This section was copied and modified from sanity.pl from git
    #    sanity.pl - Sanitize Filenames
    # Copyright (C) 2003-2005 Andreas Gohr <andi@splitbrain.org>
    #
    # This program is free software; you can redistribute it and/or
    # modify it under the terms of the GNU General Public License as
    # published by the Free Software Foundation; either version 2 of
    # the License, or (at your option) any later version.
    # See COPYING for details

    $odir =~ s/[^\x20-\x7e]/x/g;    #clean non ascii char

    $odir =~ s/['"`:|#]//g;         #remove these completely

    $odir =~ s/[\x20-\x23]/-/g;     # clean some special chars
    $odir =~ s/[\x25-\x2C]/-/g;
    $odir =~ s/\x2F/-/g;
    $odir =~ s/[\x3A-\x3f]/-/g;
    $odir =~ s/[\x5b-\x60]/-/g;
    $odir =~ s/[\x7b-\x7f]/-/g;

    $odir =~ s/-/\ /g;

    $odir =~ s/\\//g;               #remove backslases
    $odir =~ s/\*/x/g;              #windows doesn't like this at all :-)
    $odir =~ s/&/-and-/g;           #ampersand to english
    $odir =~ s/@/-at-/g;

    #some cleanup
    $odir =~ s/_+/-/g;              #Dashes should not be surounded by underscores
    $odir =~ s/--/-/g;              #Dashes should not be surounded by underscores
    $odir =~ s/\ -/-/g;
    $odir =~ s/-\ /-/g;
    $odir =~ s/--+/-/g;             #Reduce multiple dashes to one
    $odir =~ s/\ +$//g;             #Remove spaces at the end
    $odir =~ s/^\ +//g;             #Remove spaces at the front
    $odir =~ s/^\.+//g;             #Remove . at the front
    $odir =~ s/\.+$//g;             #Remove . at the end
    $odir =~ s/\;/-/g;              #remove ; from the filename
    $odir =~ s/\-$//g;              #remove - from the end of the filename
    $odir =~ s/^\-+//g;             #remove - from the front of the filename
    $odir =~ s/\ +/-/g;             #remove - one or more spaces to one -

    return ($odir);

}

sub movefile {

    # takes a file and moves it to folder  without colision
    # my $commandmv = "mv -n";
    my $commandmv = "mv -n -- ";
    my $ifile;
    my $ofile;
    my $rc;
    my $ver;
    my $vert;
    my $rest;
    my $ibk = "  ";
    my $oext;

    $folder = $_[0];    # folder name
    $ifile  = $_[1];    # FQDSN input file name
    $ofile  = $_[2];    # output sanitazed file name
    $oext   = $_[3];    # output file extension

    if ( -d $ifile ) {  # are we talking about a directory ?
        $ofile .= $oext;                    # $oext should not have anything
        $ifile =~ s!"!\\\"!g;
        unless ( -d $folder . $ofile ) {    # if does not exits

            $rc = system("$commandmv $ibk \"$ifile\" $ibk \"$folder$ofile\"");
            if ( $rc == 0 ) {
                print( $ifile, "  --->  ", $folder . $ofile, "\n" );
            }
            else {
                die "SAN01E: Error while copying $ifile \n";
            }
            return;
        }

        # there exits a folder with the same name
        #
        $folder .= $ofile . "/";            # try to make it a subfolder
        unless ( -d $folder . $ofile ) {    # if does not exits

            $rc = system("$commandmv  $ibk \"$ifile\" $ibk \"$folder$ofile\"");
            if ( $rc == 0 ) {

                # print( $ifile, "  --->  ", $folder . $ofile . "\n" );
            }
            else {
                die "SAN02E: Error while copying $ifile \n";
            }
            return;
        }

        # there exit a subfolder with the same name too. insert a version number
        $ver = 1;
        while (1) {
            $vert = "-" . $ver;
            unless ( -d $folder . $ofile . $vert ) {

                $rc = system("$commandmv $ibk \"$ifile\" $ibk \"$folder$ofile$vert\"");
                if ( $rc == 0 ) {

                    # print( $ifile, "  --->  ", $folder . $ofile . $vert,
                    # "\n" );
                }
                else {
                    die "SAN03E: Error while copying $ifile \n";
                }
                return;
            }
            $ver += 1;
        }
        return;
    }

    if ( -f $ifile ) {    # are we talking about a regular file ?

        $ifile =~ s!"!\\\"!g;
        unless ( -f $folder . $ofile . $oext ) {    # if it does not exist already
            $rc = system("$commandmv $ibk \"$ifile\" $ibk \"$folder$ofile$oext\"");
            if ( $rc == 0 ) {
                print( $ifile, "  --->  ", $folder . $ofile . $oext, "\n" );
            }
            else {
                die "SAN04E: Error while copying $ifile \n";
            }
            return;
        }

        #   the renamed file already exits append a version number
        $ver = 1;
        while (1) {
            $vert = "-" . $ver;
            unless ( -f $folder . $ofile . $vert . $oext ) {
                $rest = $vert . $oext;

                $rc = system("$commandmv $ibk \"$ifile\" $ibk \"$folder$ofile$rest\"");
                if ( $rc == 0 ) {
                    print( $ifile, "  --->  ", $folder . $ofile . $vert . $oext, "\n" );
                }
                else {
                    die "SAN05E: Error while copying $ifile \n";
                }
                return;
            }
            $ver += 1;
        }
        return;
    }
    say "SAN01W: ", $ifile, " FILE TYPE NOT SUPPORTED *******************";
}

## Make sure to do the backslash first!

# $text =~ s/\\/\\\\/g;
# $text =~ s/'/\\'/g;
# $text =~ s/"/\\"/g;
# $text =~ s/\s+$//g;
# $text =~ s/\s/\ /g;
# $text =~ s/\\0/\\\\0/g;
# return ($text);

# The name cannot include an ASCII control character, which is any byte with a
# value lower than \040 octal, or the DEL character (\177 octal).
