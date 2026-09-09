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

    const { resume_version_id, job_description_id, tone } = await req.json()

    // 1. Caching Check
    const { data: cachedCoverLetter } = await supabaseClient
      .from('cover_letters')
      .select('*')
      .eq('user_id', user.id)
      .eq('resume_version_id', resume_version_id)
      .eq('job_description_id', job_description_id)
      .eq('tone', tone)
      .eq('is_deleted', false)
      .maybeSingle()

    if (cachedCoverLetter) {
      return new Response(JSON.stringify(cachedCoverLetter), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    // 2. Limit Check
    const { data: subData } = await supabaseClient.from('subscription_status').select('plan_type').eq('user_id', user.id).single()
    const planType = subData?.plan_type || 'free'

    if (planType === 'free') {
      const { data: limits } = await supabaseClient.from('user_usage_limits').select('cover_letters_used_today').eq('user_id', user.id).single()
      if (limits && limits.cover_letters_used_today >= 1) {
        return new Response(JSON.stringify({ error: 'Daily cover letter limit reached for Free plan.' }), { status: 403, headers: corsHeaders })
      }
    }

    // 3. Load Data
    const { data: resumeVersion } = await supabaseClient.from('resume_versions').select('content_text').eq('id', resume_version_id).single()
    const { data: jobDescription } = await supabaseClient.from('job_descriptions').select('description_text').eq('id', job_description_id).single()
    
    if (!resumeVersion || !jobDescription) throw new Error('Resume or JD not found')

    // 4. Gemini Call
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${geminiApiKey}`
    
    const prompt = `
    You are an expert career coach. Write a ${tone} cover letter using the candidate's Resume and the Job Description.
    Format your response as a strict JSON object with a single key "cover_letter_content" containing the text.
    Do not use markdown blocks inside the json value.

    Resume:
    ${resumeVersion.content_text}

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
    const coverLetterContent = analysisJson.cover_letter_content

    // 5. Save Record
    const { data: insertedRecord, error: insertError } = await supabaseClient
      .from('cover_letters')
      .insert({
        user_id: user.id,
        resume_version_id,
        job_description_id,
        tone: tone,
        content: coverLetterContent,
        status: 'active'
      })
      .select()
      .single()

    if (insertError) throw insertError

    // 6. Increment Limit
    if (planType === 'free') {
      const { data: currentLimits } = await supabaseClient.from('user_usage_limits').select('cover_letters_used_today').eq('user_id', user.id).single()
      await supabaseClient.from('user_usage_limits').update({ cover_letters_used_today: (currentLimits?.cover_letters_used_today || 0) + 1 }).eq('user_id', user.id)
    }

    return new Response(JSON.stringify(insertedRecord), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders })
  }
})
