#!/usr/bin/perl -w

# 
# author:  Andriy Rudyk (arudyk.dev@gmail.com)
# date:    22.1.2013
# version: 1.1 beta
#
# wcu_balance.pl <92-number> <PIN>
#
# Retrives WCU mycat balance using the login credentials provided.
#

use strict;
use warnings;

use HTTP::Cookies;
use HTML::TreeBuilder;
use Term::ReadKey;
use WWW::Mechanize;

my $usage_string = "usage: ./wcu_balance.pl <92-number>\n";
my $mycat_url    = "http://www.wcu.edu/11407.asp";

sub check_args {
    my $num_args = $#ARGV + 1;
    if ($num_args != 1 || $ARGV[0] !~ m/92/) {
        print $usage_string;
        print "Make sure the value you entered is a valid WCU 92 number!\n";
        exit;
    }
}

sub read_passwd {
    print "Enter your MyCat pin: ";
    ReadMode('noecho'); # dont echo password
    chomp(my $pass = <STDIN>);
    ReadMode(0);        # switch back to normal
    print "\n";
    return $pass;
}

sub login_get_page {
    my $user_agent = WWW::Mechanize->new();
    $user_agent->cookie_jar(HTTP::Cookies->new());
    $user_agent->agent('Mozilla/5.0');
    $user_agent->get("http://www.wcu.edu/11407.asp");

    my $page = $user_agent->submit_form(
        form_number => 3,
        fields => {
            id => $_[0],
            PIN => $_[1]
        },
        button => 'submit'
    );

    return $page->content();
}

sub parse_page {
    my $tree = HTML::TreeBuilder->new();
    $tree->parse_content($_[0]);
    my @table_items = $tree->look_down('_tag' => 'strong');

    #foreach (@table_items) {
    #    print $_->content_list;
    #    print "\n";
    #}
    shift @table_items;
    while (my $element = shift @table_items) {
        if (grep /Balance/, $element->content_list) {
            $element = shift @table_items;
        }
        print $element->content_list;
        print " => ";
        $element = shift @table_items;
        print $element->content_list;
        print "\n";
    }

    $tree->delete;
}

check_args();
my $us = $ARGV[0];
my $pa = read_passwd();
my $con = login_get_page($us, $pa);
parse_page($con);
