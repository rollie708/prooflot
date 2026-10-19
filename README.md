# PROOFLOT

PROOFLOT is an asset-record and evidence application built with Next.js App Router, TypeScript, Tailwind CSS 4, Supabase, and viem. It includes public product pages, Supabase authentication, an authenticated owner dashboard, private evidence uploads with SHA-256 fingerprints, shareable record pages, and a Solidity registry contract.

## Local setup

1. Install Node.js 24 LTS (also specified in `.nvmrc`).
2. Copy `.env.example` to `.env.local` and set `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, and `NEXT_PUBLIC_SITE_URL`.
3. In the Supabase SQL editor, run `supabase/schema.sql`.
4. In Supabase Auth, enable email/password and add the local and deployed callback URLs (`/auth/callback`) to the allowed redirect URLs. Set the email confirmation and password recovery templates to use the `{{ .ConfirmationURL }}` action link.
5. Run `npm install`, `npm run dev`.

Without configured Supabase credentials, the public marketing and information pages work; account, database, evidence, verification, and early-access features require a configured Supabase project and the included schema.

## Database and privacy

The schema enables row-level security on application tables and creates the private `asset-evidence` storage bucket. Shared records use narrowly scoped SQL functions that return public asset fields and evidence fingerprints without exposing owner IDs or storage paths. Evidence bytes are not made public. Review and adapt the schema and policies to your operational requirements before production use. Do not place a Supabase service-role key in `NEXT_PUBLIC_*` variables.

## On-chain registry

`contracts/src/ProoflotRegistry.sol` anchors a record ID and evidence digest once per record ID. Build and deploy it with Foundry from the `contracts` directory (`forge build`). Set `NEXT_PUBLIC_REGISTRY_ADDRESS` and `NEXT_PUBLIC_CHAIN_ID` after deploying to a chosen network. `lib/registry.ts` provides viem clients and a wallet transaction helper. Wallet/network selection and transaction fees are explicit operator/user responsibilities; the contract does not verify the physical asset or claims.

## Deployment

Deploy the project root `prooflot/` to Vercel, configure the environment variables, apply the SQL schema, and set Supabase Auth redirect URLs for the production domain. Run `npm run typecheck` and `npm run build` before deployment.

### Netlify

The GitHub repository contains the app at its root. Leave Netlify's base directory blank; do not set it to `prooflot`. The committed `netlify.toml` sets `npm run build`, the `.next` publish directory, and Node.js 24. Netlify automatically applies its Next.js runtime for server rendering, route handlers, and Server Actions. This application needs that runtime; it is not a static export.

Add the variables from `.env.example` in Netlify's environment settings and use the deployed HTTPS origin for `NEXT_PUBLIC_SITE_URL`. Configure that origin in Supabase Auth as well. Never commit `.env.local`.

The initial deployment failed during dependency installation with `ETARGET: No matching version found for postcss@8.5.31`. PostCSS is now explicitly pinned to `8.5.23`, matching Next.js's dependency, with a Tailwind override to prevent its broad range from selecting `8.5.31`. The lockfile is regenerated from the package manifest without reusing local `node_modules`. To reproduce dependency installation, run `npm ci` before `npm run build`. When retrying the failed Netlify deployment, use **Clear cache and deploy site**.
