#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use DBI;
use DBDefs;
use MusicBrainz;

sub FindDuplicates
{
    my ($dbh) = @_;
    my ($id, $name, $album, $num);
    my ($last_artist);

    print "<& /comp/sidebar, title=>'Tracks which contain the word 'unknown'' &>\n";

    my $time = time;
    print "Generated on: <% \$m->comp('/comp/datetime', $time) %><br><br>";

    print 'All tracks which contain the word "unknown" ';
    print "are listed below:<p><br>\n";

    $sth = $dbh->prepare(qq\select track.id, track.name, sequence, 
                                   track.artist, artist.name 
                              from Track, AlbumJoin, Artist 
                             where AlbumJoin.Track = Track.id and 
                                   Track.Artist = Artist.id 
                          order by Artist.name, AlbumJoin.Album, Track.Name\);
    $sth->execute();
    if ($sth->rows)
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            $id = $row[0];
            $name = $row[1];
            $num = $row[2];
            $artist = $row[4];

            if ($name =~ /unknown/i)
            {
                if ($artist ne $last_artist)
                {
                   print "<p><a href=\"/showartist.html?artistid=$row[3]\">";
                   print "<font size=\"+1\">$artist</font></a><br>";
                }

                print "&nbsp;&nbsp;&nbsp;";
                print "$num: <a href=\"/showtrack.html?trackid=$id\">";
                print "$name</a><br>\n";

                $last_artist = $artist;
            }
        }
    }
    $sth->finish;
}

my ($arg, $mb, $host);

$mb = MusicBrainz->new;
$mb->Login;

FindDuplicates($mb->{DBH}, $host);

# Disconnect
$mb->Logout;
