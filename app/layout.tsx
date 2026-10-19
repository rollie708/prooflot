import type { Metadata } from 'next'
import './globals.css'
import { SiteHeader, SiteFooter } from '@/components/site'

export const metadata: Metadata = { title: { default: 'PROOFLOT — Real assets. Verifiable records.', template: '%s — PROOFLOT' }, description: 'Organize physical asset information and supporting evidence into clear, shareable records.' }
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="en"><body><SiteHeader />{children}<SiteFooter /></body></html> }
