import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization')!
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), { status: 401, headers: corsHeaders })
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser()
    if (userError || !user) throw new Error('Unauthorized')

    const { job_description_id, category } = await req.json()

    // 1. Caching Check
    const { data: cachedQuestions } = await supabaseClient
      .from('interview_questions')
      .select('*')
      .eq('user_id', user.id)
      .eq('job_description_id', job_description_id)
      .eq('category', category)
      .maybeSingle()

    if (cachedQuestions) {
      return new Response(JSON.stringify(cachedQuestions), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    // Note: No explicit daily limit for interview questions requested by user (only ATS, Cover Letter, Resume Improvement). Premium lock can be done in Flutter.

    // 2. Load Data
    const { data: jobDescription } = await supabaseClient.from('job_descriptions').select('description_text').eq('id', job_description_id).single()
    if (!jobDescription) throw new Error('Job Description not found')

    // 3. Gemini Call
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${geminiApiKey}`
    
    const prompt = `
    You are an expert technical recruiter. Based on the following Job Description, generate a list of ${category} interview questions.
    Format your response as a strict JSON object with a key "questions" mapping to an array of objects: [{"question": "...", "suggested_answer": "...", "difficulty": "Medium"}].

    Job Description:
    ${jobDescription.description_text}
    `

    const response = await fetch(geminiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { response_mime_type: "application/json" }
      })
    })

    if (!response.ok) throw new Error(`Gemini API Error: ${await response.text()}`)

    const aiData = await response.json()
    const rawJsonString = aiData.candidates[0].content.parts[0].text
    const analysisJson = JSON.parse(rawJsonString)

    // 4. Save Record
    const { data: insertedRecord, error: insertError } = await supabaseClient
      .from('interview_questions')
      .insert({
        user_id: user.id,
        job_description_id,
        category: category,
        questions_json: analysisJson
      })
      .select()
      .single()

    if (insertError) throw insertError

    return new Response(JSON.stringify(insertedRecord), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders })
  }
})
