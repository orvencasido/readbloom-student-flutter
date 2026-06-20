import { createClient } from "npm:@supabase/supabase-js@2";

const bucket = "transcription-audio";
const maxFileBytes = 25 * 1024 * 1024;

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return json({ error: "Method not allowed." }, 405);
  }

  try {
    const authorization = request.headers.get("Authorization");
    if (!authorization) return json({ error: "Unauthorized." }, 401);

    const supabase = createClient(
      requiredEnvironmentVariable("SUPABASE_URL"),
      requiredEnvironmentVariable("SUPABASE_ANON_KEY"),
      { global: { headers: { Authorization: authorization } } },
    );
    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData.user) {
      return json({ error: "Unauthorized." }, 401);
    }

    const body = await request.json();
    const audioPath = body?.audioPath;
    if (
      typeof audioPath !== "string" ||
      !audioPath.startsWith(`${userData.user.id}/`) ||
      !audioPath.toLowerCase().endsWith(".m4a")
    ) {
      return json({ error: "Invalid transcription audio path." }, 400);
    }

    try {
      const { data: recording, error: downloadError } = await supabase.storage
        .from(bucket)
        .download(audioPath);
      if (downloadError) throw downloadError;
      if (recording.size > maxFileBytes) {
        return json(
          { error: "Extracted audio exceeds the transcription limit of 25 MB." },
          413,
        );
      }

      const form = new FormData();
      form.append(
        "file",
        new File([recording], "reading.m4a", { type: "audio/mp4" }),
      );
      form.append("model", "gpt-4o-mini-transcribe");
      form.append("response_format", "json");

      const transcriptionResponse = await fetch(
        "https://api.openai.com/v1/audio/transcriptions",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${requiredEnvironmentVariable("OPENAI_API_KEY")}`,
          },
          body: form,
        },
      );
      const transcription = await transcriptionResponse.json();
      if (!transcriptionResponse.ok) {
        console.error("Transcription failed", transcription);
        return json({ error: "Transcription service failed." }, 502);
      }

      return json({ transcript: transcription.text?.trim() ?? "" });
    } finally {
      const { error: cleanupError } = await supabase.storage
        .from(bucket)
        .remove([audioPath]);
      if (cleanupError) console.error("Temporary audio cleanup failed", cleanupError);
    }
  } catch (error) {
    console.error("transcribe-recording failed", error);
    return json({ error: "Could not transcribe the recording." }, 500);
  }
});

function requiredEnvironmentVariable(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`${name} is not configured.`);
  return value;
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
