import Audio from "resource:///com/github/Aylur/ags/service/audio.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";

const Volume = () =>
  Widget.Box({
    className: "volume",
    css: "min-width: 180px",
    children: [
      Widget.Stack({
        items: [
          // tuples of [string, Widget]
          ["101", Widget.Icon("audio-volume-overamplified-symbolic")],
          ["67", Widget.Icon("audio-volume-high-symbolic")],
          ["34", Widget.Icon("audio-volume-medium-symbolic")],
          ["1", Widget.Icon("audio-volume-low-symbolic")],
          ["0", Widget.Icon("audio-volume-muted-symbolic")],
        ],
        connections: [
          [
            Audio,
            (self) => {
              if (!Audio.speaker) return;

              if (Audio.speaker.isMuted) {
                self.shown = "0";
                return;
              }

              const show = [101, 67, 34, 1, 0].find(
                (threshold) => threshold <= Audio.speaker.volume * 100,
              );

              self.shown = `${show}`;
            },
            "speaker-changed",
          ],
        ],
      }),
      Widget.Slider({
        hexpand: true,
        drawValue: false,
        onChange: ({ value }) => (Audio.speaker.volume = value),
        connections: [
          [
            Audio,
            (self) => {
              self.value = Audio.speaker?.volume || 0;
            },
            "speaker-changed",
          ],
        ],
      }),
    ],
  });

export default Volume;
