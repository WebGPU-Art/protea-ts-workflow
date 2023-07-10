import { renderControl, startControlLoop } from "@triadica/touch-control";

import { setupInitials } from "@triadica/protea";

import { loadRenderer } from "./app.mjs";

let instanceRenderer: Awaited<ReturnType<Awaited<typeof loadRenderer>>>;

let canvas = document.querySelector("#canvas-container") as HTMLCanvasElement;

window.__skipComputing = false;

window.onload = async () => {
  await setupInitials(canvas);

  instanceRenderer = await loadRenderer(canvas);

  let t = 0;
  let renderer = () => {
    t++;
    setTimeout(() => {
      requestAnimationFrame(renderer);
    }, 10);
    if (!window.stopped) {
      instanceRenderer(t, window.__skipComputing);
    }
  };

  renderer();
};

if (import.meta.hot) {
  import.meta.hot.accept("./app", async (newModule) => {
    if (newModule) {
      // newModule is undefined when SyntaxError happened
      instanceRenderer = await newModule.loadRenderer(canvas);
    }
  });
}
