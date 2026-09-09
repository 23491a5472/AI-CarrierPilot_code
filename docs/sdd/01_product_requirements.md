# Product Requirements Document (PRD)

## Product Vision
CareerPilot is a premium, AI-driven career optimization application designed to feel like a high-end personal career coach. Unlike generic "ATS Checker" utilities, CareerPilot provides an emotionally engaging, beautiful, and deeply functional experience for job seekers.

## Core Features (Phase 1-7)
1. **Resume Analysis (ATS):** Upload resumes and job descriptions to get an ATS match score and actionable coaching.
2. **Skill Gap Reporting:** Identify missing skills required for target roles and receive course recommendations.
3. **Cover Letter Generation:** Generate tailored cover letters using selected emotional tones (Confident, Humble, Enthusiastic).
4. **Mock Interviews:** Conduct audio-based mock interviews with AI-generated questions based on the target job.
5. **Resume Library:** Store and manage multiple variations of resumes.
6. **Job Tracker:** A Kanban-style board to track active applications.

## Monetization & Limits
- **Free Tier:** 
  - 2 ATS Scans / day
  - 1 Cover Letter / day
  - 1 Resume Improvement / day
  - Max 2 stored resumes.
- **Premium Tier:** Unlimited access to all features.

## Technical Requirements
- **Frontend:** Flutter (iOS/Android compatible).
- **Backend/Database:** Supabase (PostgreSQL).
- **AI Provider:** Google Gemini (via Supabase Edge Functions).
- **State Management:** Riverpod.
