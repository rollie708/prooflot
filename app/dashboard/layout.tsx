import { redirect } from 'next/navigation'
import { supabaseServer } from '@/lib/supabase'
import { signOut } from '@/app/actions'
import Link from 'next/link'
export default async function DashboardLayout({children}:{children:React.ReactNode}){const db=await supabaseServer();if(!db)redirect('/login');const{data:{user}}=await db.auth.getUser();if(!user)redirect('/login');return <><div className="dashbar"><div className="dashbar-inner"><Link href="/dashboard" className="brand"><span className="mark"><i/><b/></span><span className="wordmark">PROOF<span>LOT</span></span></Link><nav><Link href="/dashboard">Overview</Link><Link href="/dashboard/assets/new">Register asset</Link></nav><div className="dash-user"><span>{user.email}</span><form action={signOut}><button className="button button-outline button-sm">Sign out</button></form></div></div></div>{children}</>}
