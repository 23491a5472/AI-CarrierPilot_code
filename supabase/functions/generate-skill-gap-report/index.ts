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

    const { ats_analysis_id } = await req.json()

    // 1. Caching Check
    const { data: cachedReport } = await supabaseClient
      .from('skill_gap_reports')
      .select('*')
      .eq('user_id', user.id)
      .eq('ats_analysis_id', ats_analysis_id)
      .maybeSingle()

    if (cachedReport) {
      return new Response(JSON.stringify(cachedReport), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    // 2. Load ATS Analysis Data
    const { data: atsData } = await supabaseClient
      .from('ats_analyses')
      .select('analysis_json')
      .eq('id', ats_analysis_id)
      .single()

    if (!atsData) throw new Error('ATS Analysis not found')

    // 3. Gemini Call
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${geminiApiKey}`
    
    const prompt = `
    You are an expert career strategist. Based on the following ATS analysis missing skills, generate a detailed Skill Gap Report.
    Provide an actionable learning plan to acquire these skills.
    Format your response as a strict JSON object matching this structure:
    {
      "missing_skills_analysis": [{"skill": "...", "importance": "High/Medium/Low", "time_to_learn": "..."}],
      "recommended_courses": [{"title": "...", "platform": "..."}],
      "action_plan": ["..."]
    }

    Missing Skills Data:
    ${JSON.stringify(atsData.analysis_json.missing_skills || [])}
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
    const gapJson = JSON.parse(rawJsonString)

    // 4. Save Record
    const { data: insertedRecord, error: insertError } = await supabaseClient
      .from('skill_gap_reports')
      .insert({
        user_id: user.id,
        ats_analysis_id: ats_analysis_id,
        gap_json: gapJson
      })
      .select()
      .single()

    if (insertError) throw insertError

    return new Response(JSON.stringify(insertedRecord), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders })
  }
})
