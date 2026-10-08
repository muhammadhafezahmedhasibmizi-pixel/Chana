import './globals.css'
import type {Metadata} from 'next'
import {Navbar,Footer} from '@/components/site'
export const metadata:Metadata={title:{default:'মিস্ত্রি খুঁজুন — আপনার প্রয়োজনের বিশ্বস্ত মিস্ত্রি',template:'%s | মিস্ত্রি খুঁজুন'},description:'বাংলাদেশের স্থানীয় বিশ্বস্ত ও যাচাই করা মিস্ত্রি খুঁজুন—ইলেকট্রিশিয়ান, প্লাম্বার, AC মিস্ত্রি, রাজমিস্ত্রি, রং মিস্ত্রি ও আরও অনেক সেবা।',openGraph:{title:'মিস্ত্রি খুঁজুন',description:'আপনার প্রয়োজনের বিশ্বস্ত মিস্ত্রি এক জায়গায়।',type:'website'},icons:{icon:'/icon.svg'}}
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="bn"><body><Navbar/><main>{children}</main><Footer/></body></html>}
