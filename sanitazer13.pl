#!/usr/bin/perl
# use Modern::Perl '2023';
use autodie;
use strict;
use utf8;
use v5.38;
use Text::Unidecode;
use Date::Simple ( 'date', 'today' );
use File::Basename;
use warnings;
use Cwd;

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

our $VERSION = qv('0.6.0');

   Date: Thu Dec  7 01:36:31 PM -04 2023

=head1 CHANGES :
 
  REF NO  VERSION DATE    WHO     DETAIL


=head1 License
    This program is free software: you can redistribute it and/or modify it under the terms
    of the GNU General Public License as published by the Free Software Foundation, either
    version 3 of the License, or (at your option) any later version.
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU General Public License for more details.
    You should have received a copy of the GNU General Public License along with this program.
    If not, see <https://www.gnu.org/licenses/>. 
 

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

# print ($file, "\n");
print("*");
$ofile = " ";
( $fname, $fdir, $ext ) = fileparse( $file, qr/\.[^.]*/ );
if ( length($ext) > 5 ) {
    $fname .= $ext;
    $ext = "";
}

# say "|X|", $file, "||", $fname, "||", $fdir, "||", $ext, "||";
$ofname  = raccents("$fname");
$ofname  =~ s/[-|_]/\ /g;
$ofname  = titlecase($ofname);
$ofname  = sanitaze("$ofname");
$ofnamex = $ofname;
if ( $ext ne "" ) {
    $ofnamex = $ofnamex . $ext;
}
$ofile = $fdir . $ofnamex;

# say "||Z||", $file, "||", $ofile, "||";
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

sub titlecase {

# 	This filter changes all words to Title Caps, and attempts to be clever
#	about *un*capitalizing small words like a/an/the in the input.
#
#	The list of "small words" which are not capped comes from
#	the New York Times Manual of Style, plus 'vs' and 'v'.
#
#	10 May 2008
#	Original version by John Gruber:
#	http://daringfireball.net/2008/05/title_case
#
#	28 July 2008
#	Re-written and much improved by Aristotle Pagaltzis:
#	http://plasmasturm.org/code/titlecase/
#
#   Full change log at __END__.
#
#	License: http://www.opensource.org/licenses/mit-license.php
# Changes:
# Thu, 06 Nov 2014
# - Removed /o switch from substitutions; it's out-dated and described now as only "pretending" to optimize
# - Special cases for small words in two-word compounds, like "stand0-in" and "in-flight" (but not "man-in-the-middle")
# Mon, 26 Oct 2020
# - Removed the while(<>) loop. now is a subroutine. agustin.navarro@gmail.com
#
    my @small_words =
      qw( (?<!q&)a an and as at(?!&t) but by en for if in of on or the to v[.]? via vs[.]? );
    my $small_re = join '|', @small_words;
    my $apos     = qr/ (?: ['’] [[:lower:]]* )? /x;
    $_ = qq{@_};
    s/\-/\ /g;
    s{\A\s+}{};
    s{\s+\z}{};
    $_ = lc $_ if not /[[:lower:]]/;
    s{
        \b (_*) (?:
            ( (?<=[ ][/\\]) [[:alpha:]]+ [-_[:alpha:]/\\]+ |   # file path or
              [-_[:alpha:]]+ [@.:] [-_[:alpha:]@.:/]+ $apos )  # URL, domain, or email
            |
            ( (?i: $small_re ) $apos )                         # or small word (case-insensitive)
            |
            ( [[:alpha:]] [[:lower:]'’()\[\]{}]* $apos )       # or word w/o internal caps
            |
            ( [[:alpha:]] [[:alpha:]'’()\[\]{}]* $apos )       # or some other word
        ) (_*) \b
    }{
        $1 . (
          defined $2 ? $2         # preserve URL, domain, or email
        : defined $3 ? "\L$3"     # lowercase small word
        : defined $4 ? "\u\L$4"   # capitalize word w/o internal caps
        : $5                      # preserve other kinds of word
        ) . $6
    }xeg;

    # Exceptions for small words: capitalize at start and end of title
    s{
        (  \A [[:punct:]]*         # start of title...
        |  [:.;?!][ ]+             # or of subsentence...
        |  [ ]['"“‘(\[][ ]*     )  # or of inserted subphrase...
        ( $small_re ) \b           # ... followed by small word
    }{$1\u\L$2}xig;
    s{
        \b ( $small_re )      # small word...
        (?= [[:punct:]]* \Z   # ... at the end of the title...
        |   ['"’”)\]] [ ] )   # ... or of an inserted subphrase?
    }{\u\L$1}xig;

    # Exceptions for small words in hyphenated compound words
    ## e.g. "in-flight" -> In-Flight
    s{
        \b
        (?<! -)					# Negative lookbehind for a hyphen; we don't want to match man-in-the-middle but do want (in-flight)
        ( $small_re )
        (?= -[[:alpha:]]+)		# lookahead for "-someword"
    }{\u\L$1}xig;
    ## # e.g. "Stand-in" -> "Stand-In" (Stand is already capped at this point)
    s{
        \b
        (?<!…)					# Negative lookbehind for a hyphen; we don't want to match man-in-the-middle but do want (stand-in)
        ( [[:alpha:]]+- )		# $1 = first word and hyphen, should already be properly capped
        ( $small_re )           # ... followed by small word
        (?!	- )					# Negative lookahead for another '-'
    }{$1\u$2}xig;

    # print "%","$_ \n";
    return ($_);
}

sub sanitaze {
    my $odir;
    ($odir) = @_;

    # say "||Y||", $odir, "||",  "||";

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
    $odir =~ s/_+/-/g;     #Dashes should not be surounded by underscores
    $odir =~ s/--/-/g;     #Dashes should not be surounded by underscores
    $odir =~ s/\ -/-/g;
    $odir =~ s/-\ /-/g;
    $odir =~ s/--+/-/g;    #Reduce multiple dashes to one
    $odir =~ s/\ +$//g;    #Remove spaces at the end
    $odir =~ s/^\ +//g;    #Remove spaces at the front
    $odir =~ s/^\.+//g;    #Remove . at the front
    $odir =~ s/\.+$//g;    #Remove . at the end
    $odir =~ s/\;/-/g;     #remove ; from the filename
    $odir =~ s/\-$//g;     #remove - from the end of the filename
    $odir =~ s/^\-+//g;    #remove - from the front of the filename
    $odir =~ s/\ +/-/g;    #remove - one or more spaces to one -

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

    # say "|0|", $ifile, "||", $folder, "||", $ofile, "||", $oext, "||";
    if ( -d $ifile ) {    # are we talking about a directory ?
        $ofile .= $oext;                    # $oext should not have anything
        $ifile =~ s!"!\\\"!g;
        unless ( -d $folder . $ofile ) {    # if does not exits

            # say "|1|", $ifile, "||", $folder, "||", $ofile, "||";
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

            # say "|1|", $ifile, "||", $folder, "||", $ofile, "||", $oext, "||";
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

            # say "|2|", $ifile, "||", $folder, "||", $ofile, "||", $vert, "||";
                $rc = system(
                    "$commandmv $ibk \"$ifile\" $ibk \"$folder$ofile$vert\"");
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

    # say "|3|", $ifile, "||", $folder, "||", $ofile, "||", $oext, "||";
    if ( -f $ifile ) {    # are we talking about a regular file ?

        $ifile =~ s!"!\\\"!g;
        unless ( -f $folder . $ofile . $oext ) {  # if it does not exist already
            $rc =
              system("$commandmv $ibk \"$ifile\" $ibk \"$folder$ofile$oext\"");
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

        # say "|4|",$ifile, "||", $folder, "||", $ofile, "||", $rest,"||", "||";
                $rc = system(
                    "$commandmv $ibk \"$ifile\" $ibk \"$folder$ofile$rest\"");
                if ( $rc == 0 ) {
                    print( $ifile, "  --->  ",
                        $folder . $ofile . $vert . $oext, "\n" );
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
