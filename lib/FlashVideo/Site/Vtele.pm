# Part of get-flash-videos. See get_flash_videos for copyright.
=pod
   Uses Vtele-Specific way to get the brightcove metadata, 
    then forwards to the brightcove module.
 
   Vtele live streaming
   expects URL of the form
      http://vtele.ca/videos/ca-va-brasser/brasserie-dieu-du-ciel-montreal-et-st-jerome_44165.php
=cut
# Author: Olivier Bilodeau <olivier@bottomlesspit.org>
# inspired by FlashVideo::Site::Canoe
package FlashVideo::Site::Vtele;

use strict;
use FlashVideo::Utils;
use base 'FlashVideo::Site::Brightcove';

sub find_video {
  my ($self, $browser, $embed_url) = @_;

  # looking for the creator of the video object
  # something like:
  #     <script type="text/javascript">
  #     var idBC = 1613927319001;
  my $video_id  = ($browser->content =~ /idBC\s*=\s*(\d+);/i)[0];

  # I saw it as playerID but it's injected by external script
  # testing as hardcoded for now
  my $player_id = "1569527122001";

  debug "Extracted playerId: $player_id, videoId: $video_id"
    if $player_id or $video_id;

  if(!$video_id) {
    # Some pages use more complex video[x][3] type code..
    my $video_offset = ($browser->content =~ /player.SetVideo.\w+\[(\d+)/i)[0];
    $video_id = ($browser->content =~ /videos\[$video_offset\].+'(\d+)'\s*\]/)[0];
  }

  die "Unable to extract Brightcove IDs from page"
    unless $player_id and $video_id;

  return $self->amfgateway($browser, $player_id, { videoId => $video_id, } );
}

sub can_handle {
  my($self, $browser, $url) = @_;

  # XXX can_handle seems broken: $browser->content is empty when called
  return 1;

  return $browser->content =~ /var\s*idBC/i;
}

1;
