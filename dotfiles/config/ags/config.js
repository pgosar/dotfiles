// importing
import App from "resource:///com/github/Aylur/ags/app.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";

// widgets can be only assigned as a child in one container
// so to make a reuseable widget, just make it a function
// then you can use it by calling simply calling it

import Workspaces from "./modules/workspaces.js";
import Clock from "./modules/clock.js";
import Notification from "./modules/notification.js";
import Media from "./modules/media.js";
import Volume from "./modules/volume.js";
import BatteryLabel from "./modules/battery.js";
import SysTray from "./modules/systray.js";

// layout of the bar
const Left = () =>
  Widget.Box({
    children: [Workspaces()],
  });

const Center = () =>
  Widget.Box({
    children: [Media(), Notification()],
  });

const Right = () =>
  Widget.Box({
    hpack: "end",
    children: [Volume(), BatteryLabel(), Clock(), SysTray()],
  });

const Bar = ({ monitor } = {}) =>
  Widget.Window({
    name: `bar-${monitor}`, // name has to be unique
    className: "bar",
    monitor,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      startWidget: Left(),
      centerWidget: Center(),
      endWidget: Right(),
    }),
  });

// exporting the config so ags can manage the windows
export default {
  style: App.configDir + "/style.css",
  windows: [
    Bar(),

    // you can call it, for each monitor
    // Bar({ monitor: 0 }),
    // Bar({ monitor: 1 })
  ],
};
