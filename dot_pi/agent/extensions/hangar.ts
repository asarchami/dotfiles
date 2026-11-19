// hangar: report pi's state to tmux-hangar (~/Projects/tmux-hangar).
//
// Each event is forwarded to `hangar hook pi <event>` with a small JSON
// payload on stdin. Forwards run one at a time, in the order pi fired them
// (events like ui_prompt_end and agent_settled can arrive milliseconds
// apart, and whichever write lands last wins), but pi never waits for them.
// Every failure is swallowed: this extension must never slow pi down or
// break it. Outside tmux ($TMUX_PANE unset) it does nothing.
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawn } from "node:child_process";

const EVENTS = [
  "session_start",
  "agent_start",
  "ui_prompt_start",
  "ui_prompt_end",
  "agent_settled", // final "done" (agent_end also fires before retries)
  "session_shutdown",
];

// A hangar call that has not exited after this long is abandoned so a
// wedged tmux cannot stall the queue.
const TIMEOUT_MS = 3000;

let queue: Promise<void> = Promise.resolve();

function run(event: string, payload: string): Promise<void> {
  return new Promise((resolve) => {
    try {
      const child = spawn("hangar", ["hook", "pi", event], { stdio: ["pipe", "ignore", "ignore"] });
      const timer = setTimeout(resolve, TIMEOUT_MS);
      timer.unref?.();
      const done = () => {
        clearTimeout(timer);
        resolve();
      };
      child.on("exit", done);
      child.on("error", done); // hangar not installed
      child.stdin?.on("error", () => {});
      child.stdin?.end(payload);
      child.unref();
    } catch {
      resolve();
    }
  });
}

function forward(event: string, payload: Record<string, unknown>): void {
  const body = JSON.stringify(payload);
  queue = queue.then(() => run(event, body)).catch(() => {});
}

function sessionFile(ctx: any): string | undefined {
  try {
    return ctx?.sessionManager?.getSessionFile?.();
  } catch {
    return undefined;
  }
}

export default function (pi: ExtensionAPI) {
  if (!process.env.TMUX_PANE) return;
  for (const name of EVENTS) {
    try {
      (pi as any).on(name, (event: any, ctx: any) => {
        try {
          forward(name, { kind: event?.kind, title: event?.title, sessionFile: sessionFile(ctx) });
        } catch {
          // never let reporting break pi
        }
      });
    } catch {
      // this pi version does not know the event; skip it
    }
  }
}
