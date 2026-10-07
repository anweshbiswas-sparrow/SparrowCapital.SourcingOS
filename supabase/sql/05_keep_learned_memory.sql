-- Keep what the brain has learned when the nightly memory rebuild runs.
-- refresh_brain_docs() rebuilds brain_docs from the synced Notion/Tracxn tables and used to delete every
-- document it didn't rebuild, which wiped worked examples (from upvotes) and saved insights.
-- This patch limits that delete to synced kinds, then restores examples from brain_feedback.
do $$ declare d text; begin
  select pg_get_functiondef('public.refresh_brain_docs'::regproc) into d;
  if position('kind not in (''answer_example'', ''insight'')' in d) = 0 then
    d := replace(d, 'from brain_docs where id not in (select id from _nd);',
                    'from brain_docs where id not in (select id from _nd) and kind not in (''answer_example'', ''insight'');');
    execute d;
  end if;
end $$;
select public.brain_memory_doc('answer_example', id) from brain_feedback where rating = 1;
