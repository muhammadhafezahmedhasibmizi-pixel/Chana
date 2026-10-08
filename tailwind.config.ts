import type {Config} from 'tailwindcss'
const config:Config={content:['./app/**/*.{ts,tsx}','./components/**/*.{ts,tsx}','./lib/**/*.{ts,tsx}'],theme:{extend:{colors:{brand:'#0B5ED7',accent:'#F59E0B',ink:'#0f172a',surface:'#F8FAFC'},fontFamily:{bengali:['var(--font-bengali)','sans-serif']},boxShadow:{soft:'0 12px 35px rgba(15,23,42,.08)'}}},plugins:[]}
export default config
