---
tags:
  - case-study-note
case_study: PressReader
created: 2026-09-09
---

# Confirming the outgoing XML write path

## Question / goal

[[Discovering-The-Core-XML-Protocol]] left `bp.m1.m()` unread — JADX couldn't decompile it ("Method
dump skipped"), so the method that actually assembles and sends the XML envelope built by `e()`/`f()`
was only inferred from its neighbors. Does `m()` really send that XML body over the
`HttpURLConnection` opened by `a(String)`, and if so, exactly how — as raw bytes, or through some
wrapper?

## How this was found

The starting hypothesis (not this case study's own; carried over from general Java knowledge) was
mechanical: `HttpURLConnection` has no `setBody(String)` method, so sending a body is always
`setDoOutput(true)` → `getOutputStream()` → convert the string to bytes → `write(byte[])`. That gives
a concrete, searchable prediction: `write([B)V` should appear somewhere in `m1.smali`.

It doesn't. Grepping the file for `write([B)V` turns up nothing at all — the first sign the
byte-array hypothesis was wrong, not that the search target was missing. Broadening the search to the
bare substring `write(` instead of guessing a second hypothesis blind turns up exactly one candidate:

```smali
invoke-virtual {v15, v8}, Ljava/io/Writer;->write(Ljava/lang/String;)V
```

`Ljava/io/Writer;->write(Ljava/lang/String;)V` takes a `String` directly, not a `byte[]` — which
raises the next question rather than answering it: `getOutputStream()` on a `URLConnection` is
documented to return a raw `java.io.OutputStream`, which has no such overload. So either this `write`
call belongs to something other than the connection's stream, or there's a wrapper bridging the two.
Reading the raw smali immediately around both the `getOutputStream()` call and this `write` line
(rather than trusting the method name in isolation) settles it — the full sequence is right there,
uninterrupted, in `m()`:

```smali
    .line 91
    invoke-virtual {v10, v8}, Ljava/net/URLConnection;->setDoOutput(Z)V
    ...
    .line 161
    invoke-virtual {v10}, Ljava/net/URLConnection;->getOutputStream()Ljava/io/OutputStream;
    .line 164
    move-result-object v11

    .line 167
    new-instance v15, Ljava/io/OutputStreamWriter;
    .line 168
    const-string v8, "UTF-8"
    .line 170
    invoke-direct {v15, v11, v8}, Ljava/io/OutputStreamWriter;-><init>(Ljava/io/OutputStream;Ljava/lang/String;)V

    .line 174
    invoke-virtual/range {p0 .. p0}, Lbp/m1;->f()Ljava/lang/String;
    .line 177
    move-result-object v8
    .line 178
    invoke-virtual/range {p0 .. p1}, Lbp/m1;->e(Lcom/newspaperdirect/pressreader/android/core/Service;)Ljava/lang/String;
    .line 181
    move-result-object v12
    .line 182
    filled-new-array {v7, v12}, [Ljava/lang/Object;
    .line 185
    move-result-object v12
    .line 186
    invoke-static {v8, v12}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    .line 189
    move-result-object v8

    .line 190
    invoke-virtual {v15, v8}, Ljava/io/Writer;->write(Ljava/lang/String;)V

    .line 193
    invoke-virtual {v15}, Ljava/io/OutputStreamWriter;->close()V
    .line 196
    if-eqz v11, :cond_c8
    invoke-virtual {v11}, Ljava/io/OutputStream;->close()V
```

(full method: [[m1.smali]], `bp.m1.m()`; line numbers are the `.line` debug directives at each
instruction, per [[Methods]] — see [[PressReader]] for the file's location under
`Case-Studies/pressreader/source/`)

## Relevant source

- [[m1.smali]] — `bp.m1.m()`, lines ~2787-3059.

## Excerpt

See the smali block under "How this was found" above — it's the complete, unedited chain, not a
reconstruction.

## Analysis

The mechanical hypothesis was right about *why* a wrapper has to exist (`getOutputStream()` really
does return a plain `OutputStream`, which has no `String`-taking `write`), but wrong about which
wrapper: `m()` doesn't manually convert the XML string to a `byte[]` and call `OutputStream.write`
directly. Instead it wraps the stream once, explicitly with `UTF-8`:

```smali
new-instance v15, Ljava/io/OutputStreamWriter;
invoke-direct {v15, v11, v8}, Ljava/io/OutputStreamWriter;-><init>(Ljava/io/OutputStream;Ljava/lang/String;)V
```

— exactly the standard `new OutputStreamWriter(outputStream, "UTF-8")` idiom — and then calls
`write(String)` on it once, resolved statically to `Ljava/io/Writer;->write(Ljava/lang/String;)V`
(`OutputStreamWriter`'s own superclass method; see [[Classes]] on why an inherited, non-overridden
method can still show up under the parent type in the `invoke-virtual` descriptor). The byte
conversion still happens — `Writer`/`OutputStreamWriter` do it internally per the charset — it's just
never a smali-visible `write([B)V`, which is exactly why that search came back empty and wasn't a dead
instrumentation lead.

One more thing this excerpt settles beyond the original question: **how the final payload is
assembled**, not just how it's written. `v8` (the string actually passed to `write`) is the result of

```smali
invoke-static {v8, v12}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
```

where the format string is `f()`'s return value (the `<nd version='1.0'><request id='0'
type='%s'>%s</request></nd>` template from [[Discovering-The-Core-XML-Protocol]]) and the argument
array is `filled-new-array {v7, v12}` — `v12` being `e(Service)`'s return value (the
`<authentication>` block). So the payload is `String.format(f(), new Object[]{v7, e(service)})`: a
plain two-slot `%s` fill, not manual `StringBuilder` concatenation. `v7`'s own origin (almost
certainly the request's command type, matching `f()`'s first `%s`) hasn't been traced yet — see Open
questions.

## Generalizing the pattern

When a Java-API-shaped hypothesis about *what instruction must exist* comes back with zero grep
matches, the right next move is to broaden the search (`write(` instead of `write([B)V`) before
discarding the hypothesis outright — the mechanism can be real while the specific overload guessed is
wrong. The same "search by the thing that's guaranteed to appear literally, then read the surrounding
lines in full" discipline [[Registers]] already documents for field descriptors
(`Lclass;->field:T`) applies just as well to method descriptors
(`Lclass;->method(Args)Ret;`) when tracing a call chain cold.

## Related concepts

- [[Discovering-The-Core-XML-Protocol]] — the note this one directly continues; confirms its deferred
  "read `m()`'s raw smali" open item.
- [[Registers]] — "search by field, not by eye"; the same technique applied here to a method
  descriptor instead.
- [[Classes]] — direct vs. virtual method resolution, relevant to why `write` resolves to `Writer`
  (the declaring supertype) rather than `OutputStreamWriter`.
- [[Reading-Raw-Dalvik]] — reading a JADX-unparseable method cold, the fallback this note is an
  instance of.

## Open questions / next steps

- [ ] Trace `v7`'s origin backward from the `filled-new-array` at `.line 182` — almost certainly the
      request's command-type string (`f()`'s first `%s`), but not yet confirmed against the method's
      parameters (`p2`/`p3`/`p4`) or a constant.
- [ ] Run [[inspect-api.ts]] (already hooking `e`/`f`/`m` directly) against the running app to capture
      a real, populated XML payload and cross-check it against this static trace.
- [ ] Confirm whether the response side (`getInputStream()`, consumed by the SAX parser named in
      [[Discovering-The-Core-XML-Protocol]]) follows the same read-via-wrapped-stream shape, or reads
      raw bytes directly.

## See also

- [[Case-Studies]]
