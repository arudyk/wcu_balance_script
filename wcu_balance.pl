#!/usr/bin/perl -w

# 
# author:  Andriy Rudyk (arudyk.dev@gmail.com)
# date:    22.1.2013
# version: 1.0 alpha
#
# wcu_balance.pl <92-number> <PIN>
#
# Retrives WCU mycat balance using the login credentials provided.
#

use strict;
use WWW::Mechanize;
use WWW::Mechanize::TreeBuilder;
use HTTP::Cookies;
use Crypt::SSLeay;

my $num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "usage: ./wcu_balance.pl <92-number> <pin>\n";
    exit;
}

my $mech = WWW::Mechanize->new();
WWW::Mechanize::TreeBuilder->meta->apply($mech);
$mech->cookie_jar(HTTP::Cookies->new());
$mech->agent('Mozilla/5.0');
$mech->get("http://www.wcu.edu/11407.asp");

my $result=$mech->submit_form(
        form_number => 3,
        fields      => {
            id    => $ARGV[0],
            PIN  => $ARGV[1]
        },
        button     => 'submit'
    );
#sleep(4);
#print $result->content();

my @rray = $mech->find('strong');

while (my $token = shift @rray) {
    if ($token->as_text() =~ "Board Meals") {
        $token = shift @rray;
        print "Board Meals:" . $token->as_text() . "\n";
    }
    if ($token->as_text() =~ "Meal Points") {
        $token = shift @rray;
        print "Meal Points: " . $token->as_text() . "\n";
    }
    if ($token->as_text() =~ "Cat Cash") {
        $token = shift @rray;
        print "Cat Cash:    " . $token->as_text() . "\n";
    }
}

#foreach (@rray) {
#    if ($_->as_text() =~ "Board Meals") {
#        print "board meals found";
#    }
#    #print $_->as_text();
#    print "\n"
#}
