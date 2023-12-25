import Mpris from "resource:///com/github/Aylur/ags/service/mpris.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";

const Media = () => {
  const mpris = Mpris.getPlayer("");

  if (!mpris) {
    return null; // or any other fallback behavior if mpris is not available
  }
  return Widget.Button({
    className: "media",
    onPrimaryClick: () => mpris.playPause(),
    onScrollUp: () => mpris.next(),
    onScrollDown: () => mpris.previous(),
    child: Widget.Label({
      connections: [
        [
          Mpris,
          (self) => {
            // mpris player can be undefined
            if (mpris)
              self.label = `${mpris.trackArtists.join(", ")} - ${
                mpris.trackTitle
              }`;
            else self.label = "";
          },
        ],
      ],
    }),
  });
};

export default Media;
