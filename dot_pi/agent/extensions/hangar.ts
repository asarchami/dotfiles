// hangar: report pi's state to tmux-hangar (~/Projects/tmux-hangar).
//
// Each event is forwarded to `hangar hook pi <event>` with a small JSON
// payload on stdin. The child is detached and never awaited, and every
// failure is swallowed: this extension must never slow pi down or break it.
// Outside tmux ($TMUX_PANE unset) it does nothing.
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawn } from "node:child_process";

const EVENTS = [
  "session_start",
  "agent_start",
  "ui_prompt_start",
  "ui_prompt_end",
  "agent_settled", // final "done" (agent_end also fires before retries)
  "session_shutdown",
] as const;

function forward(event: string, payload: Record<string, unknown>): void {
  try {
    const child = spawn("hangar", ["hook", "pi", event], {
      detached: true,
      stdio: ["pipe", "ignore", "ignore"],
    });
    child.on("error", () => {}); // hangar not installed
    child.stdin?.on("error", () => {});
    child.stdin?.end(JSON.stringify(payload));
    child.unref();
  } catch {
    // never let reporting break pi
  }
}

export default function (pi: ExtensionAPI) {
  if (!process.env.TMUX_PANE) return;
  for (const name of EVENTS) {
    pi.on(name, (event: any, ctx: any) => {
      let sessionFile: string | undefined;
      try {
        sessionFile = ctx?.sessionManager?.getSessionFile?.();
      } catch {
        sessionFile = undefined;
      }
      forward(name, { kind: event?.kind, title: event?.title, sessionFile });
    });
  }
}
