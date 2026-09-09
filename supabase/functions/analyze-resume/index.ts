import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Authenticate user request
    const authHeader = req.headers.get('Authorization')!
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), { status: 401, headers: corsHeaders })
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser()

    if (userError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized', details: userError }), { status: 401, headers: corsHeaders })
    }

    // Parse request body
    const { resume_version_id, job_description_id, resume_hash, job_description_hash } = await req.json()

    // 2. Resume hash + JD hash caching check
    const { data: cachedAnalysis } = await supabaseClient
      .from('ats_analyses')
      .select('*')
      .eq('user_id', user.id)
      .eq('resume_hash', resume_hash)
      .eq('job_description_hash', job_description_hash)
      .eq('is_deleted', false)
      .maybeSingle()

    if (cachedAnalysis) {
      // Return cached version
      return new Response(JSON.stringify(cachedAnalysis), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    // 3. Free/Premium usage limit check
    const { data: subData } = await supabaseClient
      .from('subscription_status')
      .select('plan_type')
      .eq('user_id', user.id)
      .single()

    const planType = subData?.plan_type || 'free'

    if (planType === 'free') {
      const { data: limits } = await supabaseClient
        .from('user_usage_limits')
        .select('ats_scans_used_today')
        .eq('user_id', user.id)
        .single()
        
      if (limits && limits.ats_scans_used_today >= 2) {
        return new Response(JSON.stringify({ error: 'Daily ATS scan limit reached for Free plan. Watch an Ad or Upgrade.' }), { status: 403, headers: corsHeaders })
      }
    }

    // 4. Load Resume + JD from Supabase
    const { data: resumeVersion } = await supabaseClient
      .from('resume_versions')
      .select('content_text')
      .eq('id', resume_version_id)
      .single()

    const { data: jobDescription } = await supabaseClient
      .from('job_descriptions')
      .select('description_text')
      .eq('id', job_description_id)
      .single()

    if (!resumeVersion || !jobDescription) {
      return new Response(JSON.stringify({ error: 'Resume or Job Description not found' }), { status: 404, headers: corsHeaders })
    }

    // 5. Gemini request
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiApiKey) {
      throw new Error('GEMINI_API_KEY is not configured')
    }

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${geminiApiKey}`
    
    // Strict JSON schema for Gemini 2.5 Flash
    const prompt = `
    You are an expert ATS (Applicant Tracking System) Analyzer.
    Analyze the following Resume against the Job Description.
    Provide a strict JSON response containing the exact keys below.
    Weighting: Keyword (30%), Skills (25%), Experience (20%), Education (10%), Formatting (15%).
    
    Format:
    {
      "total_score": <int 0-100>,
      "keyword_score": <int 0-100>,
      "skill_score": <int 0-100>,
      "experience_score": <int 0-100>,
      "education_score": <int 0-100>,
      "formatting_score": <int 0-100>,
      "matched_keywords": ["..."],
      "missing_keywords": ["..."],
      "matched_skills": ["..."],
      "missing_skills": ["..."],
      "strengths": ["..."],
      "weaknesses": ["..."],
      "improvement_suggestions": ["..."],
      "formatting_issues": ["..."]
    }

    Resume:
    ${resumeVersion.content_text}
    
    Job Description:
    ${jobDescription.description_text}
    `

    const response = await fetch(geminiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          response_mime_type: "application/json",
        }
      })
    })

    if (!response.ok) {
      const errText = await response.text()
      throw new Error(`Gemini API Error: ${errText}`)
    }

    const aiData = await response.json()
    const rawJsonString = aiData.candidates[0].content.parts[0].text
    const analysisJson = JSON.parse(rawJsonString)

    const atsScore = analysisJson.total_score ?? 0

    // 6. Store full analysis_json & direct ats_score
    const { data: insertedAnalysis, error: insertError } = await supabaseClient
      .from('ats_analyses')
      .insert({
        user_id: user.id,
        resume_version_id,
        job_description_id,
        status: 'completed',
        ats_score: atsScore,
        resume_hash,
        job_description_hash,
        analysis_json: analysisJson
      })
      .select()
      .single()

    if (insertError) {
      throw insertError
    }

    // 7. Increment usage limits if free
    if (planType === 'free') {
      const { data: currentLimits } = await supabaseClient
        .from('user_usage_limits')
        .select('ats_scans_used_today')
        .eq('user_id', user.id)
        .single()
        
      await supabaseClient
        .from('user_usage_limits')
        .update({ ats_scans_used_today: (currentLimits?.ats_scans_used_today || 0) + 1 })
        .eq('user_id', user.id)
    }

    // 8. Create career_health_snapshots entry
    // A simple heuristic for resume strength and skill completeness based on the scores
    const resumeStrength = Math.round((analysisJson.experience_score + analysisJson.education_score + analysisJson.formatting_score) / 3) || 0;
    const skillCompleteness = analysisJson.skill_score || 0;

    await supabaseClient
      .from('career_health_snapshots')
      .insert({
        user_id: user.id,
        ats_score: atsScore,
        resume_strength: resumeStrength,
        skill_completeness: skillCompleteness,
      })

    // 9. Return saved analysis result
    return new Response(JSON.stringify(insertedAnalysis), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })

  } catch (err) {
    console.error(err)
    return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders })
  }
})
