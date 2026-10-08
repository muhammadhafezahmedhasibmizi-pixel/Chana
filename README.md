# মিস্ত্রি খুঁজুন — Mistri Khujun

A production-ready Bengali service marketplace starter built with Next.js + TypeScript + Tailwind CSS + Supabase.

## Run locally

1. Install Node.js 20+.
2. `npm install`
3. Copy `.env.example` to `.env.local` and set Supabase URL/key.
4. Create a Supabase project.
5. Run `supabase/schema.sql` in Supabase SQL Editor.
6. `npm run typecheck`
7. `npm run build`
8. `npm run dev`

## Supabase

The SQL creates profiles, technicians, categories, Bangladesh location hierarchy, reviews, favorites, contact requests, hero banners and admin users. RLS is enabled and public technician visibility is limited to verified records.

### Make a user admin

After registering a user, run:

```sql
insert into public.admin_users(user_id) values ('USER_UUID');
update public.profiles set role='admin' where id='USER_UUID';
```

## Deployment

Deploy to Vercel, add `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, and `NEXT_PUBLIC_SITE_URL` environment variables, then deploy.

## Notes

The included UI has a polished demo dataset so the marketplace remains navigable before Supabase data is populated. Once Supabase is configured, authentication, technician applications, contact submissions, reviews and protected admin data use the real backend.
