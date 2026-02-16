import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8"
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const { user_id, purchased_at } = await req.json()
    const krwangCharacterId = '2dacd2ae-bd33-4c84-81ba-4dd19516f2e4';

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // 프리미엄 업데이트
    const { error: updateError } = await supabase
      .from('user')
      .update({ is_premium: true, premium_purchased_at: purchased_at })
      .eq('id', user_id)
    if (updateError) throw updateError

    // 캐릭터 지급
    const { data: existing } = await supabase
      .from('user_characters')
      .select('id')
      .eq('user_id', user_id)
      .eq('character_id', krwangCharacterId)
      .maybeSingle()

    if (!existing) {
      const { error: charError } = await supabase.from('user_characters').insert({
        user_id: user_id,
        character_id: krwangCharacterId,
        experience: 0,
        is_active: false,
        stage: 'egg',
      })
      if (charError) throw charError
    }

    return new Response(JSON.stringify({ success: true }), { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 
    })
  }
})