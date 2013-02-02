#!/usr/bin/perl -w

#
# author:  Andriy Rudyk (arudyk.dev@gmail.com)
# date:    23.1.2013
# version: 1.4
#
# wcu_balance.pl <92-number>
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
my $user_agent   = "Mozzila/5.0";

#
# Checks the arguemts for the apropriate number and makes sure "92" is
# contained within the 92-number.
#
sub check_args {
    my $num_args = $#ARGV + 1;
    if ($num_args != 1 || $ARGV[0] !~ m/^92/) {
        print $usage_string;
        exit;
    }
}

#
# Reads in a user password withour echoing characters (for security measures).
#
# returns password as a string.
#
sub read_passwd {
    print "Enter your MyCat pin: ";
    ReadMode('noecho'); # dont echo password
    chomp(my $pass = <STDIN>);
    ReadMode(0);        # switch back to normal
    print "\n";
    return $pass;
}

#
# Logs-in into the website with the provided credentials (given by arguments).
#
# param1 username (92-number)
# param2 password (PIN)
#
# returns the html page after login.
#
sub login_get_page {
    my $mech = WWW::Mechanize->new();
    $mech->cookie_jar(HTTP::Cookies->new());
    $mech->agent($user_agent);
    $mech->get($mycat_url);

    my $page = $mech->submit_form(
        form_number => 3,
        fields => {
            id => $_[0],
            PIN => $_[1]
        },
        button => 'submit'
    );

    return $page->content();
}

#
# Parses the page for account information.
#
# param 1 html page
#
sub parse_page {
    my $tree = HTML::TreeBuilder->new();
    $tree->parse_content($_[0]);
    my @table_items = $tree->look_down('_tag' => 'strong');

    shift @table_items;
    while (my $element = shift @table_items) {
        if ((join "", $element->content_list) =~ m/Balance/) {
            $element = shift @table_items;
        }
        print $element->content_list;
        my $space_size = 21 - length(join "", $element->content_list);
        print " " x $space_size;
        $element = shift @table_items;
        print $element->content_list;
        print "\n";
    }

    $tree->delete;
}

#
# Runs the program. First checks arguments, then reads password, then attempts
# to login and parse the page.
#
sub main {

    check_args();
    my $username = $ARGV[0];
    my $password = read_passwd();
    my $content = login_get_page($username, $password);
    parse_page($content);
}

# Run main.
main();
