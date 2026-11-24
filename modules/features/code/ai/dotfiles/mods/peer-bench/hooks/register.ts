import type { EngineInterface, Register } from 'claude-code'

// Test mod: how fast does a peer's busy/idle reach another session, by a
// consumed one-line message versus by polling ListAgents?
//
// Sender session:   /bench-run <receiver-name> [turns=20] [gap-ms=4000]
//   Runs short turns ("Reply with just: ok"). At each main turn start and end
//   it sends "peer-bench:v1 <seq> <busy|idle> <t0>" to the receiver alone.
// Receiver session: /bench-watch <sender-name> [poll-ms=250]
//   Polls ListAgents every poll-ms and notes when the sender's status changes;
//   consumes the sender's lines (no model reads them) and notes when each came.
//   /bench-report writes /tmp/peer-bench.csv and answers a summary.
//
// Lines go only to the receiver named in /bench-run, never to anyone else.

const PLUGIN = 'peer-bench'
const CSV = '/tmp/peer-bench.csv'
const ENVELOPE = /^<cross-session-message from="[^"]*" from-name="([^"]*)"[^>]*>\n([\s\S]*?)\n<\/cross-session-message>\s*$/
const BODY = /^peer-bench:v1 (\d+) (busy|idle) (\d+)$/

type State = 'busy' | 'idle'
type Push = { seq: number; state: State; t0: number; recvAt: number }
type Seen = { status: string; at: number }

// Sender
let target: string | undefined
let seq = 0
let turnDone: (() => void) | undefined
const sendMs: number[] = []

// Receiver
let watched: string | undefined
let poller: { cancel: () => void } | undefined
let lastStatus: string | undefined
const pushes: Push[] = []
const seen: Seen[] = []
const callMs: number[] = []

async function send($: EngineInterface, state: State): Promise<void> {
  if (target === undefined) return
  seq += 1
  const t0 = await $.clock.now()
  await $.session.send({ to: target, text: `peer-bench:v1 ${seq} ${state} ${t0}` })
  sendMs.push((await $.clock.now()) - t0)
}

async function run($: EngineInterface, turns: number, gapMs: number): Promise<void> {
  for (let i = 0; i < turns && target !== undefined; i += 1) {
    const done = new Promise<void>(resolve => {
      turnDone = resolve
    })
    await $.prompt.submit({ text: 'Reply with just: ok' })
    await done
    await $.clock.sleep(gapMs)
  }
  $.ui.toast(`bench-run done: ${seq} lines sent, send median ${median(sendMs)}ms`, { timeoutMs: 60_000 })
  target = undefined
}

async function poll($: EngineInterface): Promise<void> {
  if (watched === undefined) return
  const started = await $.clock.now()
  const result = await $.tool.call({ tool: 'ListAgents' })
  const at = await $.clock.now()
  callMs.push(at - started)
  const text = typeof result.text === 'string' ? result.text : ''
  const prefix = `  ${watched} [`
  const line = text.split('\n').find(one => one.startsWith(prefix))
  const status = line?.split(/ +· +/)[2]?.trim() ?? 'absent'
  if (status !== lastStatus) {
    lastStatus = status
    // The call's midpoint is the best guess of when the listing was read.
    seen.push({ status, at: Math.round((started + at) / 2) })
  }
}

function median(values: readonly number[]): string {
  if (values.length === 0) return '-'
  const sorted = [...values].sort((a, b) => a - b)
  return String(sorted[Math.floor(sorted.length / 2)])
}

function pct(values: readonly number[], p: number): string {
  if (values.length === 0) return '-'
  const sorted = [...values].sort((a, b) => a - b)
  return String(sorted[Math.min(sorted.length - 1, Math.floor((sorted.length * p) / 100))])
}

async function report($: EngineInterface): Promise<string> {
  const rows = ['seq,state,t0,push_ms,list_ms']
  const pushLat: number[] = []
  const listLat: number[] = []
  let missed = 0
  const ordered = [...pushes].sort((a, b) => a.seq - b.seq)
  ordered.forEach((push, i) => {
    const next = ordered[i + 1]
    const pushMs = push.recvAt - push.t0
    pushLat.push(pushMs)
    // The listing's first sight of this state after t0, before the next change.
    const hit = seen.find(one => one.status === push.state && one.at >= push.t0 && (next === undefined || one.at < next.t0))
    const listMs = hit === undefined ? undefined : hit.at - push.t0
    if (listMs === undefined) missed += 1
    else listLat.push(listMs)
    rows.push(`${push.seq},${push.state},${push.t0},${pushMs},${listMs ?? ''}`)
  })
  await $.fs.write(CSV, `${rows.join('\n')}\n`)
  return [
    `changes: ${ordered.length}`,
    `message: median ${median(pushLat)}ms, p90 ${pct(pushLat, 90)}ms, max ${pct(pushLat, 100)}ms`,
    `ListAgents: median ${median(listLat)}ms, p90 ${pct(listLat, 90)}ms, max ${pct(listLat, 100)}ms, missed ${missed}`,
    `ListAgents call: median ${median(callMs)}ms, p90 ${pct(callMs, 90)}ms (${callMs.length} calls)`,
    `statuses seen: ${[...new Set(seen.map(one => one.status))].join(', ')}`,
    `csv: ${CSV}`,
  ].join(' | ')
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'bench-run', description: 'peer-bench sender: <receiver> [turns] [gap-ms]' })
    await $.command.register({ name: 'bench-watch', description: 'peer-bench receiver: <sender> [poll-ms]' })
    await $.command.register({ name: 'bench-report', description: 'peer-bench receiver: write the CSV and summarize' })
    return next(e)
  })

  on('command.run', { command: 'bench-run' }, async ($, e) => {
    const [to, turns = '20', gap = '4000'] = e.args.trim().split(/\s+/)
    if (to === undefined || to === '') return { text: 'usage: /bench-run <receiver> [turns] [gap-ms]' }
    target = to
    seq = 0
    sendMs.length = 0
    // prompt.submit from this hook would wait on the command itself: start the
    // run from a timer of its own once the command is answered.
    $.clock.after(500, () => {
      void run($, Number(turns), Number(gap)).catch((error: unknown) => {
        target = undefined
        $.ui.toast(`bench-run failed: ${String(error).slice(0, 200)}`, { timeoutMs: 60_000 })
      })
    })
    return { text: `bench-run: ${turns} turns, lines to ${to}` }
  })

  on('command.run', { command: 'bench-watch' }, async ($, e) => {
    const [from, pollMs = '250'] = e.args.trim().split(/\s+/)
    if (from === undefined || from === '') return { text: 'usage: /bench-watch <sender> [poll-ms]' }
    watched = from
    lastStatus = undefined
    pushes.length = 0
    seen.length = 0
    callMs.length = 0
    poller?.cancel()
    poller = $.clock.every(Number(pollMs), () => {
      void poll($).catch(() => undefined)
    })
    return { text: `bench-watch: ${from} every ${pollMs}ms` }
  })

  on('command.run', { command: 'bench-report' }, async $ => ({ text: await report($) }))

  on('turn.start', async ($, e, next) => {
    if (e.agentId === undefined) await send($, 'busy').catch(() => undefined)
    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    if (e.agentId === undefined) {
      await send($, 'idle').catch(() => undefined)
      turnDone?.()
      turnDone = undefined
    }
    return result
  })

  on('session.receive', async ($, e, next) => {
    if (!('plugin' in e.origin) || e.origin.plugin !== PLUGIN) return next(e)
    const envelope = ENVELOPE.exec(e.text)
    const body = BODY.exec(envelope?.[2] ?? '')
    if (envelope === undefined || envelope === null || body === null) return next(e)
    const recvAt = await $.clock.now()
    pushes.push({ seq: Number(body[1]), state: body[2] as State, t0: Number(body[3]), recvAt })
    return { consumed: PLUGIN }
  }).catch(($, e, next) => next(e))
}
