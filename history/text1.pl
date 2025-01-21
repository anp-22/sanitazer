#!/bin/perl
use autodie;
use strict;
use utf8;
use v5.38;
use warnings;

my $num;
my $ascmsg;
my $ascii;
my $msgutf8;
my $msgascii;
my $lng;
my $utf2ascii;

#$ascmsg = decode('ar.AR_UTF8',$msgutf8);

$msgutf8  = q!الجماهيرية العربية الليبية الشعبية الاشتراكية العظمى!;

$msgascii = q^Why do Americans have so many different types of towels? We have beach towels, hand towels, bath towels, dish towels, camping towels, quick-dry towels, and let’s not forget paper towels. Would 1 type of towel work for each of these things? Let’s take a beach towel. It can be used to dry your hands and body with no difficulty. A beach towel could be used to dry dishes. Just think how many dishes you could dry with one beach towel. I’ve used a beach towel with no adverse effects while camping. If you buy a thin beach towel it can dry quickly too. I’d probably cut up a beach towel to wipe down counters or for cleaning other items, but a full beach towel could be used too. Is having so many types of towels an extravagant luxury that Americans enjoy or is it necessary? I’d say it's overkill and we could cut down on the many types of towels that manufacturers deem necessary.^;


#$ascmsg = decode('ar.AR_UTF8',$msgutf8);

# $ascii = substr($msgutf8, 0, 1);

# $num = ord($ascii);

# $lng = length($ascii);


# say $lng, " ", $ascii, " ", $num;


if ($msgutf8 =~ /[^\x00-\x7f]/ ) {

    say "not ascii";

} else {
    say "ascii";
}

if ($msgascii =~ /[^\x00-\x7f]/ ) {
    
    say "ascii";
} else {
    say "not ascii";
}
$utf2ascii = $msgutf8;
$utf2ascii =~ s/[^\x00-\x7f]/\./g;

say $utf2ascii;
say $msgutf8;



